-- DEIS Spatial Analysis
-- 01_setup.sql
-- Creates all tables used in the project

-- Raw CSO small area boundaries (loaded via ogr2ogr)
-- See 02_import.sql for import commands

-- Cleaned small areas
CREATE TABLE small_areas_clean AS
SELECT DISTINCT ON (sa_geogid_2022) *
FROM sa_boundaries
WHERE LENGTH(sa_geogid_2022) = 10
ORDER BY sa_geogid_2022, objectid ASC;

-- Add centroid column
ALTER TABLE small_areas_clean
ADD COLUMN centroid GEOMETRY(Point, 2157);

UPDATE small_areas_clean
SET centroid = ST_Centroid(geom);

-- Spatial indexes
CREATE INDEX idx_sa_geom ON small_areas_clean USING GIST (geom);
CREATE INDEX idx_sa_centroid ON small_areas_clean USING GIST (centroid);

-- Deprivation tables
CREATE TABLE deprivation_raw (
  ed_id_str TEXT,
  ed_english TEXT,
  totpop22 TEXT,
  agedep22 TEXT,
  lonepa22 TEXT,
  edlow_22 TEXT,
  edhigh22 TEXT,
  hlprof22 TEXT,
  lclass22 TEXT,
  unempm22 TEXT,
  unempf22 TEXT,
  ownocc22 TEXT,
  prrent22 TEXT,
  larent22 TEXT,
  peroom22 TEXT,
  index22_ed_std_rel_wt TEXT,
  index22_ed_std_abs_wt TEXT,
  index22_ed_rel_wt_cat TEXT,
  index22_ed_rel_wt_lab TEXT
);

CREATE TABLE deprivation (
  ed_id_str VARCHAR(30),
  ed_english VARCHAR(100),
  population INTEGER,
  deprivation_score NUMERIC,
  deprivation_category VARCHAR(50)
);

-- Schools tables
CREATE TABLE schools_raw (
  id INTEGER,
  roll_number VARCHAR(20),
  school_name VARCHAR(100),
  address1 VARCHAR(100),
  address2 VARCHAR(100),
  address3 VARCHAR(100),
  address4 VARCHAR(100),
  county VARCHAR(50),
  eircode VARCHAR(10),
  local_authority VARCHAR(100),
  itm_east NUMERIC,
  itm_north NUMERIC,
  latitude NUMERIC,
  longitude NUMERIC
);

CREATE TABLE deis_raw (
  roll_number VARCHAR(20),
  school_name VARCHAR(100),
  address1 VARCHAR(100),
  address2 VARCHAR(100),
  address3 VARCHAR(100),
  address4 VARCHAR(100),
  county VARCHAR(50),
  extra VARCHAR(50)
);