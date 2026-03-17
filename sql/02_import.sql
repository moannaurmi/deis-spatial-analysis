-- DEIS Spatial Analysis
-- 02_import.sql
-- Data import commands

-- 1. Load small area boundaries (run in terminal, not pgAdmin)
-- ogr2ogr -f "PostgreSQL" "PG:host=localhost dbname=deis_project user=postgres password=YOUR_PASSWORD" "path/to/Small_Area_National_Statistical_Boundaries_2022.gpkg" -nln sa_boundaries -t_srs EPSG:2157

-- 2. Load Electoral Division boundaries (run in terminal, not pgAdmin)
-- ogr2ogr -f "PostgreSQL" "PG:host=localhost dbname=deis_project user=postgres password=YOUR_PASSWORD" "path/to/CSO_Electoral_Divisions_National_Statistical_Boundaries_2022.gpkg" -nln ed_boundaries -t_srs EPSG:2157

-- 3. Import deprivation CSV (run in pgAdmin)
-- First copy file to /tmp/deprivation.csv then run:
COPY deprivation_raw
FROM '/tmp/deprivation.csv'
DELIMITER ','
CSV HEADER
ENCODING 'LATIN1';

-- Extract cleaned deprivation data
INSERT INTO deprivation (ed_id_str, ed_english, population, deprivation_score, deprivation_category)
SELECT
  ed_id_str,
  ed_english,
  ROUND(REPLACE(totpop22, ',', '')::NUMERIC) AS population,
  index22_ed_std_rel_wt::NUMERIC AS deprivation_score,
  index22_ed_rel_wt_lab AS deprivation_category
FROM deprivation_raw;

-- 4. Convert schools Excel to CSV (run in terminal)
-- python3 -c "
-- import openpyxl, csv
-- wb = openpyxl.load_workbook('path/to/post_primary_schools_ireland_2016.xlsx')
-- ws = wb.active
-- with open('/tmp/schools.csv', 'w', newline='') as f:
--     writer = csv.writer(f)
--     for row in ws.iter_rows(values_only=True):
--         writer.writerow(row)
-- "

-- Import schools CSV
COPY schools_raw
FROM '/tmp/schools.csv'
DELIMITER ','
CSV HEADER;

-- Import DEIS schools list
-- First copy file to /tmp/deis_schools.csv then run:
COPY deis_raw
FROM '/tmp/deis_schools.csv'
DELIMITER ','
CSV HEADER;

-- Remove duplicate header row from DEIS list
DELETE FROM deis_raw WHERE roll_number = 'Roll Number';