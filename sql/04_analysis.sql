-- DEIS Spatial Analysis
-- 04_analysis.sql
-- All analysis queries

-- ANALYSIS 1: Deprivation distribution baseline
SELECT
  deprivation_category,
  COUNT(*) AS area_count,
  ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 1) AS pct_of_total
FROM small_areas2
WHERE deprivation_category IS NOT NULL
GROUP BY deprivation_category
ORDER BY area_count DESC;

-- ANALYSIS 2: DEIS schools per county
SELECT
  county,
  COUNT(*) AS deis_school_count
FROM schools
WHERE deis_status = TRUE
GROUP BY county
ORDER BY deis_school_count DESC;

-- ANALYSIS 3: Extremely deprived areas per county
SELECT
  county_english,
  COUNT(*) AS extremely_deprived_count
FROM small_areas2
WHERE deprivation_category = 'Extremely Disadvantaged'
GROUP BY county_english
ORDER BY extremely_deprived_count DESC;

-- ANALYSIS 4: Calculate distances to nearest DEIS and non-DEIS school
CREATE TABLE distances2 AS
SELECT
  sa.sa_geogid_2022,
  sa.county_english,
  sa.deprivation_category,
  sa.population,
  ROUND(
    (ST_Distance(sa.centroid, deis.geom) / 1000)::NUMERIC, 2
  ) AS nearest_deis_distance_km,
  ROUND(
    (ST_Distance(sa.centroid, nondeis.geom) / 1000)::NUMERIC, 2
  ) AS nearest_school_distance_km
FROM small_areas2 sa
CROSS JOIN LATERAL (
  SELECT geom FROM schools
  WHERE deis_status = TRUE
  ORDER BY sa.centroid <-> geom
  LIMIT 1
) deis
CROSS JOIN LATERAL (
  SELECT geom FROM schools
  WHERE deis_status = FALSE
  ORDER BY sa.centroid <-> geom
  LIMIT 1
) nondeis
WHERE sa.centroid IS NOT NULL;

-- ANALYSIS 4a: Average distance by deprivation category
SELECT
  deprivation_category,
  ROUND(AVG(nearest_deis_distance_km)::NUMERIC, 2) AS avg_deis_km,
  ROUND(AVG(nearest_school_distance_km)::NUMERIC, 2) AS avg_any_school_km
FROM distances2
WHERE deprivation_category IS NOT NULL
GROUP BY deprivation_category
ORDER BY avg_deis_km DESC;

-- ANALYSIS 4b: Median and 75th percentile distance
SELECT
  deprivation_category,
  ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY nearest_deis_distance_km)::NUMERIC, 2) AS median_km,
  ROUND(PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY nearest_deis_distance_km)::NUMERIC, 2) AS p75_km
FROM distances2
WHERE deprivation_category IS NOT NULL
GROUP BY deprivation_category
ORDER BY median_km DESC;

-- ANALYSIS 5: Coverage table (5km buffer)
CREATE TABLE coverage2 AS
SELECT
  sa.sa_geogid_2022,
  sa.county_english,
  sa.deprivation_category,
  sa.population,
  CASE WHEN d.nearest_deis_distance_km <= 5 THEN TRUE ELSE FALSE END AS covered_by_deis
FROM small_areas2 sa
LEFT JOIN distances2 d ON sa.sa_geogid_2022 = d.sa_geogid_2022;

-- ANALYSIS 5: Coverage by deprivation category
SELECT
  deprivation_category,
  COUNT(*) AS total_areas,
  SUM(CASE WHEN covered_by_deis THEN 1 ELSE 0 END) AS covered_areas,
  ROUND(
    100.0 * SUM(CASE WHEN covered_by_deis THEN 1 ELSE 0 END) / COUNT(*), 1
  ) AS coverage_pct
FROM coverage2
WHERE deprivation_category IS NOT NULL
GROUP BY deprivation_category
ORDER BY coverage_pct DESC;

-- ANALYSIS 6: County coverage gap
SELECT
  county_english,
  COUNT(*) AS deprived_areas,
  SUM(CASE WHEN covered_by_deis THEN 1 ELSE 0 END) AS covered_areas,
  ROUND(
    100.0 * SUM(CASE WHEN covered_by_deis THEN 1 ELSE 0 END) / COUNT(*), 1
  ) AS coverage_pct
FROM coverage2
WHERE deprivation_category IN (
  'Extremely Disadvantaged',
  'Very Disadvantaged'
)
GROUP BY county_english
ORDER BY coverage_pct ASC;

-- ANALYSIS 7: Population weighted coverage
SELECT
  ROUND(
    100.0 * SUM(
      CASE WHEN covered_by_deis THEN population ELSE 0 END
    ) / SUM(population), 1
  ) AS population_coverage_pct
FROM coverage2
WHERE deprivation_category IN (
  'Extremely Disadvantaged',
  'Very Disadvantaged'
);

-- ANALYSIS 8: Uncovered deprived areas (policy gaps)
SELECT
  c.sa_geogid_2022,
  c.county_english,
  d.nearest_deis_distance_km,
  sa.population
FROM coverage2 c
JOIN distances2 d ON c.sa_geogid_2022 = d.sa_geogid_2022
JOIN small_areas2 sa ON c.sa_geogid_2022 = sa.sa_geogid_2022
WHERE c.deprivation_category IN ('Extremely Disadvantaged', 'Very Disadvantaged')
AND c.covered_by_deis = FALSE
ORDER BY d.nearest_deis_distance_km DESC;