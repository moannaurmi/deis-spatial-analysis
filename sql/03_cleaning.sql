-- DEIS Spatial Analysis
-- 03_cleaning.sql
-- Data cleaning and preparation

-- Rename geometry column for consistency
ALTER TABLE sa_boundaries RENAME COLUMN shape TO geom;
ALTER TABLE ed_boundaries RENAME COLUMN shape TO geom;

-- Build schools table with PostGIS geometry
CREATE TABLE schools AS
SELECT
  id,
  roll_number,
  school_name,
  address1,
  address2,
  county,
  eircode,
  local_authority,
  latitude,
  longitude,
  ST_Transform(
    ST_SetSRID(ST_MakePoint(longitude, latitude), 4326),
    2157
  ) AS geom
FROM schools_raw
WHERE latitude IS NOT NULL
AND longitude IS NOT NULL;

-- Add spatial index on schools
CREATE INDEX idx_schools_geom ON schools USING GIST (geom);

-- Add DEIS status flag to schools
ALTER TABLE schools ADD COLUMN deis_status BOOLEAN DEFAULT FALSE;

UPDATE schools
SET deis_status = TRUE
WHERE roll_number IN (SELECT roll_number FROM deis_raw);

-- Spatial join: assign deprivation to small areas via ED containment
-- Uses DISTINCT ON to ensure one match per small area
CREATE TABLE small_areas2 AS
SELECT DISTINCT ON (sa.sa_geogid_2022)
  sa.sa_geogid_2022,
  sa.county_english,
  sa.ed_english,
  sa.geom,
  sa.centroid,
  ed.county_english AS ed_county,
  ed.ed_english AS ed_name_from_boundary,
  d.deprivation_score,
  d.deprivation_category,
  d.population
FROM small_areas_clean sa
LEFT JOIN ed_boundaries ed
  ON ST_Within(sa.centroid, ed.geom)
LEFT JOIN deprivation d
  ON UPPER(ed.ed_english) = UPPER(d.ed_english)
ORDER BY sa.sa_geogid_2022, d.deprivation_score NULLS LAST;

-- Spatial indexes on main working table
CREATE INDEX idx_small_areas2_centroid ON small_areas2 USING GIST (centroid);
CREATE INDEX idx_small_areas2_geom ON small_areas2 USING GIST (geom);