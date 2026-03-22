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

-- ANALYSIS 9: Join quality audit
-- Measures match rate between small areas and deprivation data
SELECT
  COUNT(*) AS total_small_areas,
  COUNT(deprivation_score) AS matched_with_deprivation,
  COUNT(*) - COUNT(deprivation_score) AS unmatched,
  ROUND(
    100.0 * COUNT(deprivation_score) / COUNT(*), 1
  ) AS match_rate_pct
FROM small_areas2;
-- Result: 16,837 total, 16,763 matched, 74 unmatched, 99.6% match rate

-- ANALYSIS 10: Duplicate ED name check
-- Identifies ED names appearing in multiple counties in deprivation table
-- These create ambiguity in the name-based join stage
SELECT ed_english, COUNT(*) AS occurrences
FROM deprivation
GROUP BY ed_english
HAVING COUNT(*) > 1
ORDER BY occurrences DESC;
-- Result: 193 duplicate ED names found
-- NEWTOWN appears 8 times, CASTLETOWN 8 times, KILBRIDE 7 times
-- This confirms the hybrid join has real ambiguity at the ED name stage
-- DISTINCT ON likely resolved most cases but county assignment
-- for common placenames cannot be guaranteed

-- ANALYSIS 11: Priority ranking for uncovered deprived areas
-- Normalised inputs — all variables scaled 0-1 before combining
-- Weights: distance 0.6, deprivation 0.4 — illustrative, adjustable
WITH ranges AS (
  SELECT
    MIN(d.nearest_deis_distance_km) AS min_dist,
    MAX(d.nearest_deis_distance_km) AS max_dist,
    MIN(sa.deprivation_score) AS min_dep,
    MAX(sa.deprivation_score) AS max_dep
  FROM small_areas2 sa
  JOIN distances2 d USING (sa_geogid_2022)
  WHERE sa.deprivation_category IN (
    'Very Disadvantaged',
    'Extremely Disadvantaged'
  )
)
SELECT
  sa.sa_geogid_2022,
  sa.county_english,
  sa.deprivation_score,
  d.nearest_deis_distance_km,
  ROUND(
    ((d.nearest_deis_distance_km - r.min_dist) /
    NULLIF(r.max_dist - r.min_dist, 0) * 0.6) +
    ((sa.deprivation_score - r.max_dep) /
    NULLIF(r.min_dep - r.max_dep, 0) * 0.4)
  , 3) AS priority_score
FROM small_areas2 sa
JOIN distances2 d USING (sa_geogid_2022)
CROSS JOIN ranges r
WHERE sa.deprivation_category IN (
  'Very Disadvantaged',
  'Extremely Disadvantaged'
)
AND sa.sa_geogid_2022 NOT IN (
  SELECT sa_geogid_2022
  FROM coverage2
  WHERE covered_by_deis = TRUE
)
ORDER BY priority_score DESC;
-- Results:
-- A157040001 Mayo    -23.06  16.20km  0.649 (highest priority)
-- A157114001 Mayo    -24.97  11.47km  0.504
-- A127123005 Limerick -23.01 10.97km  0.454
-- A127123002 Limerick -23.01 10.67km  0.443
-- A127123004 Limerick -23.01 10.66km  0.442
-- A127123003 Limerick -23.01 10.54km  0.438
```

Save with Cmd+S then push to GitHub:
```
git add .
git commit -m "Add join audit, duplicate check and normalised priority ranking queries"
git push origin main