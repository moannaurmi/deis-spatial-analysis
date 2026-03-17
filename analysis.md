# DEIS Spatial Analysis
## Spatial inequality in school access: coverage of DEIS schools across deprived small areas in Ireland

### Research Question
What proportion of Ireland's most deprived small areas are within 5km of a DEIS post-primary school, and does the spatial pattern suggest effective policy targeting?

---

## Tools Used
- PostgreSQL 16
- PostGIS 3.6.2
- pgAdmin 4
- VS Code
- Python 3.9.6 (openpyxl for Excel conversion)
- ogr2ogr (via Homebrew PostGIS install)
- QGIS (to come)

---

## Data Sources
- CSO Small Area boundaries 2022 — GeoPackage — data.gov.ie
- CSO Electoral Division boundaries 2022 — GeoPackage — data.gov.ie
- Pobal HP Deprivation Index 2022 — CSV — data.gov.ie (Electoral Division level only — small area level requires a license from authors)
- DEIS post-primary schools list — XLS — Department of Education gov.ie
- Post-primary schools locations 2016 — compiled manually from data.gov.ie (original download link broken)

---

## Data Ingestion
- Small area boundaries loaded using ogr2ogr from GeoPackage into PostgreSQL/PostGIS
- Electoral Division boundaries loaded using ogr2ogr from GeoPackage into PostgreSQL/PostGIS
- Coordinate system set to Irish Transverse Mercator EPSG:2157 for all spatial datasets
- Deprivation CSV imported using PostgreSQL COPY command with LATIN1 encoding to handle Irish fada characters
- Schools data converted from Excel to CSV using Python/openpyxl then imported via COPY
- DEIS schools list had a duplicate header row — removed, leaving 232 DEIS post-primary schools

---

## Data Cleaning
- CSO Small Area GeoPackage contained three copies of each boundary at different generalisation levels — filtered to unique small areas using DISTINCT ON retaining lowest objectid
- GeoPackage also contained non-small-area boundaries — filtered to records where LENGTH(sa_geogid_2022) = 10
- Result: 16,837 unique small areas
- Geometry columns renamed from shape to geom for consistency
- School coordinates converted from WGS84 to ITM EPSG:2157 using ST_Transform
- 227 of 232 DEIS schools matched to location dataset (97.8%)

### Deprivation Join Method
- Deprivation index is at Electoral Division level — codes do not directly match small area codes
- Primary method: spatial containment join — small area centroids spatially joined to ED boundary polygons, then deprivation scores assigned by ED name match
- Some centroids fell on ED boundaries — resolved using DISTINCT ON to retain one match per small area
- Match rate: 19,970 of 20,044 small areas matched (99.6%)
- Validation: name-based join produced virtually identical results (<0.1% difference), confirming robustness of both approaches

---

## Database Tables
| Table | Description | Rows |
|---|---|---|
| sa_boundaries | Raw CSO small area boundaries | 56,757 |
| small_areas_clean | Filtered unique small areas with centroids | 16,837 |
| ed_boundaries | CSO Electoral Division boundaries | 3,420 |
| deprivation_raw | Raw Pobal CSV (all columns as text) | 3,417 |
| deprivation | Cleaned deprivation data | 3,417 |
| small_areas2 | Main working table (spatial join) | 16,837 |
| schools_raw | Raw schools data | 711 |
| schools | Schools with PostGIS geometry and DEIS flag | 711 |
| deis_raw | Raw DEIS schools list | 232 |
| distances2 | Distance to nearest DEIS and non-DEIS school | 16,837 |
| coverage2 | DEIS 5km coverage status per small area | 16,837 |

---

## Analysis 1 — Deprivation Distribution Baseline

| Category | Count | % of Total |
|---|---|---|
| Marginally Above Average | 9,262 | 46.3% |
| Marginally Below Average | 7,796 | 38.9% |
| Affluent | 1,389 | 6.9% |
| Disadvantaged | 1,362 | 6.8% |
| Very Disadvantaged | 154 | 0.8% |
| Extremely Disadvantaged | 7 | 0.0% |

Total focus areas (Very + Extremely Disadvantaged): 161 small areas

---

## Analysis 2 — DEIS Schools Per County

| County | DEIS Schools |
|---|---|
| Dublin | 65 |
| Cork | 21 |
| Donegal | 19 |
| Mayo | 11 |
| Tipperary | 10 |
| Wexford | 10 |
| Galway | 9 |
| Limerick | 8 |
| Kildare | 7 |
| Louth | 7 |
| Wicklow | 6 |
| Waterford | 6 |
| Longford | 6 |
| Kilkenny | 6 |
| Kerry | 5 |
| Offaly | 4 |
| Monaghan | 4 |
| Meath | 4 |
| Clare | 3 |
| Carlow | 3 |
| Sligo | 3 |
| Westmeath | 3 |
| Roscommon | 3 |
| Cavan | 2 |
| Laois | 2 |

Notable: Donegal has 19 DEIS schools despite being a predominantly rural county.

---

## Analysis 3 — Extremely Deprived Areas Per County

Only Limerick City has extremely disadvantaged small areas: 7 total. All extreme deprivation is concentrated in one city — likely an artefact of ED-level aggregation diluting urban deprivation pockets elsewhere.

---

## Analysis 4a — Average Distance to Nearest DEIS School

| Category | Avg DEIS Distance (km) | Avg Any School (km) |
|---|---|---|
| Marginally Below Average | 7.64 | 5.09 |
| Marginally Above Average | 7.23 | 3.82 |
| Disadvantaged | 3.45 | 5.33 |
| Affluent | 3.36 | 1.41 |
| Extremely Disadvantaged | 1.49 | 1.84 |
| Very Disadvantaged | 1.15 | 1.71 |

Key finding: most deprived areas are closest to DEIS schools — suggests policy targeting is working. Note: averages hide rural outliers — see median analysis below.

---

## Analysis 4b — Median and 75th Percentile Distance

| Category | Median (km) | 75th Percentile (km) |
|---|---|---|
| Marginally Below Average | 5.26 | 11.84 |
| Marginally Above Average | 4.97 | 10.30 |
| Affluent | 2.03 | 3.29 |
| Extremely Disadvantaged | 1.55 | 1.71 |
| Disadvantaged | 0.98 | 3.62 |
| Very Disadvantaged | 0.67 | 1.01 |

Key finding: Very Disadvantaged areas have a median of just 0.67km — half are within walking distance of a DEIS school. The high 75th percentile for average areas (11.84km) reflects rural areas creating heavy tails in the average.

---

## Analysis 5 — Coverage by Deprivation Category (5km buffer)

| Category | Total | Covered | Coverage % |
|---|---|---|---|
| Extremely Disadvantaged | 7 | 7 | 100% |
| Very Disadvantaged | 154 | 148 | 96.1% |
| Affluent | 1,167 | 1,042 | 89.3% |
| Disadvantaged | 1,362 | 1,056 | 77.5% |
| Marginally Above Average | 7,031 | 4,033 | 57.4% |
| Marginally Below Average | 7,042 | 3,640 | 51.7% |

Key finding: 100% of extremely disadvantaged and 96.1% of very disadvantaged areas are within 5km of a DEIS school.

---

## Analysis 6 — County Coverage Gap

| County | Deprived Areas | Covered | Coverage % |
|---|---|---|---|
| Limerick (county) | 4 | 0 | 0% |
| Mayo | 2 | 0 | 0% |
| Waterford City | 9 | 9 | 100% |
| Limerick City | 58 | 58 | 100% |
| Dublin City | 30 | 30 | 100% |
| South Dublin | 24 | 24 | 100% |
| Cork City | 34 | 34 | 100% |

Key finding: clear urban-rural divide — all urban deprived areas have 100% coverage, rural deprived areas have zero coverage. Note: Limerick county and Limerick City are separate administrative units.

---

## Analysis 7 — Population Weighted Coverage

**98.5%** of people living in extremely or very disadvantaged areas are within 5km of a DEIS post-primary school.

This is the headline statistic for the project — robust across both join methods.

---

## Analysis 8 — Uncovered Deprived Areas (Policy Gaps)

| Small Area | County | Distance to Nearest DEIS (km) | Population |
|---|---|---|---|
| A157040001 | Mayo | 16.20 | 158 |
| A157114001 | Mayo | 11.47 | 114 |
| A127123005 | Limerick | 10.97 | 1,408 |
| A127123002 | Limerick | 10.67 | 1,408 |
| A127123004 | Limerick | 10.66 | 1,408 |
| A127123003 | Limerick | 10.54 | 1,408 |

Key finding: 6 deprived small areas have no DEIS school within 5km. Mayo areas are most isolated at 16.2km. The 4 Limerick county areas likely represent the same Electoral Division split across multiple small areas — combined approximately 1,680 people without accessible DEIS provision.

---

## Limitations
- Deprivation data is at Electoral Division level not Small Area level — true small area data requires a license from the authors. ED-level aggregation likely dilutes extreme deprivation in urban areas.
- School location data is from 2016 — some schools may have opened, closed, or moved since then.
- 74 small areas (0.4%) have no deprivation score due to centroids falling on ED boundaries.
- 5 DEIS schools from the Department of Education list could not be matched to the schools location dataset.
- 5km buffer threshold is a methodological choice justified by typical rural post-primary travel distance.
- County comparison mixes cities and counties as separate administrative units — interpret carefully.