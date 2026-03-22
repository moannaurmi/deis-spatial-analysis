# DEIS Spatial Analysis
## Spatial inequality in school access: coverage of DEIS post-primary schools across deprived small areas in Ireland

### Research Question
What proportion of Ireland's most deprived small areas are within 5km of a DEIS post-primary school, and does the spatial pattern suggest effective policy targeting?

---

## Operational Relevance

**Who would use this analysis:**
Department of Education DEIS policy team, school transport scheme planners, local authorities in Mayo and Limerick county.

**What decision it informs:**
Where to prioritise new DEIS school designations or enhanced transport provision for post-primary students in deprived areas currently outside the 5km coverage threshold.

**What changes with this analysis vs without:**
Resource allocation moves from county-level approximation to community-level identification — the six specific small areas with highest combined deprivation and distance are named and ranked by priority score.

**What this analysis cannot do:**
Road network distance is not included — straight-line distance overstates accessibility in rural areas. School capacity is not known — a school within 5km may be oversubscribed. Population data is from 2016 and at ED level only.

---

## Tools Used
- PostgreSQL 16
- PostGIS 3.6.2
- pgAdmin 4
- VS Code
- Python 3.9.6 (openpyxl for Excel conversion)
- ogr2ogr (via Homebrew PostGIS install)
- QGIS (maps in progress)

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

## Data Cleaning and Row Count Tracking

All analyses use **small_areas2 as the canonical base table (16,837 rows)**. The following table tracks every reduction step explicitly:

| Stage | Table | Rows | Notes |
|---|---|---|---|
| Raw GeoPackage load | sa_boundaries | 56,757 | Three generalisation levels + other boundary types mixed together |
| Filter to SA codes only | — | 50,511 | WHERE LENGTH(sa_geogid_2022) = 10 |
| Remove duplicate generalisation levels | small_areas_clean | 16,837 | DISTINCT ON retaining lowest objectid |
| Add centroid column | small_areas_clean | 16,837 | ST_Centroid(geom) |
| Spatial containment join (final) | small_areas2 | 16,837 | One row per small area, DISTINCT ON |
| Unmatched after spatial join | — | 74 | Centroids on ED boundaries — geometric ambiguity |
| Final matched rows with deprivation | — | 16,763 | small_areas2 minus 74 unmatched — used for all deprivation analyses |

### Deprivation Join Method
- Deprivation index is at Electoral Division level — codes do not directly match small area codes
- The join pipeline is hybrid in two stages:
  - **Stage 1 — Spatial:** small area centroids are spatially joined to ED boundary polygons. Once a small area centroid is confirmed to fall within an ED polygon, the ED is identified spatially.
  - **Stage 2 — Name-based:** ED boundaries are then joined to the deprivation table via ed_english name matching. No guaranteed unique key exists between these two datasets — the name match bridges the gap.
- This hybrid structure means that for ED names appearing in multiple counties — which is common in Ireland — the join cannot guarantee the correct county's deprivation score was assigned. A duplicate name audit found 193 ED names appearing more than once in the deprivation table, with NEWTOWN appearing 8 times and CASTLETOWN 8 times. DISTINCT ON resolved duplicate matches by retaining one result per small area, but county assignment for common placenames cannot be guaranteed.
- A small number of small area centroids fell on or very near ED boundaries, creating geometric ambiguity. The correct alternative — polygon-to-polygon intersection — introduces its own problem: small areas that physically span multiple EDs would receive ambiguous or averaged deprivation scores, as there is no principled way to assign a single ED's attributes to a small area that overlaps several. The centroid approach avoids this by assigning each small area to exactly one ED based on where its centre falls. Boundary cases are handled pragmatically using DISTINCT ON, retaining the match with a non-null deprivation score where multiple candidates exist. This is acknowledged as a limitation rather than a clean solution — 74 small areas (0.4%) remain unmatched.
- Validation: a name-based join was run in parallel and produced virtually identical deprivation category distributions (<0.1% difference), confirming the spatial approach is robust overall despite the hybrid structure.

---

## Database Tables

| Table | Description | Rows |
|---|---|---|
| sa_boundaries | Raw CSO small area boundaries | 56,757 |
| small_areas_clean | Filtered unique small areas with centroids | 16,837 |
| ed_boundaries | CSO Electoral Division boundaries | 3,420 |
| deprivation_raw | Raw Pobal CSV (all columns as text) | 3,417 |
| deprivation | Cleaned deprivation data | 3,417 |
| small_areas2 | Canonical working table (spatial join) | 16,837 |
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

Notable: Donegal has 19 DEIS schools despite being a predominantly rural county — the third highest count nationally after Dublin and Cork. The reason for this is not established by this analysis. Two hypotheses present themselves: Donegal consistently ranks among Ireland's most deprived counties on multiple socioeconomic indicators, which could reflect genuine need; alternatively, the county's dispersed settlement pattern may have led to more individual school designations rather than concentrated urban clusters. These are hypotheses only — testing them would require historical DEIS designation data and school-level socioeconomic indicators. What can be said is that if Donegal's deprivation is real but geographically dispersed, it would be precisely the kind of county most exposed to the rural accessibility gap identified in Analyses 6 and 8 — deprived, rural, and reliant on a school network spread across a large geographic area. This connects Donegal directly to the central finding of this analysis rather than treating it as an anomaly.

---

## Analysis 3 — Extremely Deprived Areas Per County

Only Limerick City has extremely disadvantaged small areas: 7 total.

**Important caveat:** This figure should be treated with significant caution. The Pobal deprivation index is available at Electoral Division level only — true small area level data requires a license from the authors. When deprivation scores are averaged up to ED level, pockets of extreme deprivation within larger EDs are diluted and may not cross the threshold into the "Extremely Disadvantaged" category. The true number of extremely disadvantaged small areas in Ireland is almost certainly higher than 7. This is the most significant data limitation in this analysis and affects the interpretation of all findings related to the most deprived areas. All conclusions about "Extremely Disadvantaged" areas should be read with this constraint in mind.

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

Key finding: the most deprived areas are geographically closest to DEIS schools, while average and affluent areas are furthest away. This pattern is consistent with effective spatial targeting of DEIS provision. Note: averages mask significant rural variation — see median analysis below for a more robust picture.

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

Key finding: the median distance for Very Disadvantaged areas is just 0.67km — half of all very disadvantaged small areas are within walking distance of a DEIS school. The tight interquartile range (0.67km median, 1.01km at 75th percentile) indicates this is a consistent pattern rather than an average driven by a few urban clusters. By contrast, the wide spread for average areas (5.26km median, 11.84km at 75th percentile) reveals the rural accessibility problem — a quarter of average small areas are more than 12km from any DEIS school.

---

## Analysis 5 — Coverage by Deprivation Category (5km buffer)

**Note on totals:** Area counts here differ slightly from Analysis 1 because coverage2 excludes the 74 small areas with no deprivation match. All analyses from Analysis 4 onwards use small_areas2 as the canonical base.

| Category | Total | Covered | Coverage % |
|---|---|---|---|
| Extremely Disadvantaged | 7 | 7 | 100% |
| Very Disadvantaged | 154 | 148 | 96.1% |
| Affluent | 1,167 | 1,042 | 89.3% |
| Disadvantaged | 1,362 | 1,056 | 77.5% |
| Marginally Above Average | 7,031 | 4,033 | 57.4% |
| Marginally Below Average | 7,042 | 3,640 | 51.7% |

Key finding: coverage decreases as deprivation decreases — the most deprived areas are best served by DEIS schools at the 5km threshold. The 100% figure for extremely disadvantaged areas should be treated as illustrative given the very small sample size (7 areas) and the ED aggregation issue described in Analysis 3. The 96.1% figure for Very Disadvantaged is the headline finding of this analysis. The gap between deprived areas (96.1%) and average areas (roughly 50%) is the clearest evidence of effective spatial targeting in this dataset.

---

## Analysis 6 — County Coverage Gap

Note: Ireland's administrative geography separates some cities from their surrounding counties as distinct units. The table below reflects this — city and county figures are not directly comparable and should not be aggregated without care.

| Administrative Unit | Type | Deprived Areas | Covered | Coverage % |
|---|---|---|---|---|
| Limerick (county) | County | 4 | 0 | 0% |
| Mayo | County | 2 | 0 | 0% |
| Waterford City | City | 9 | 9 | 100% |
| Limerick City | City | 58 | 58 | 100% |
| Dublin City | City | 30 | 30 | 100% |
| South Dublin | County | 24 | 24 | 100% |
| Cork City | City | 34 | 34 | 100% |

Key finding: within this dataset, every identified deprived urban area is covered and no identified deprived rural area is covered at the 5km threshold. The sample of uncovered areas is small (6 small areas across 2 counties) so this should be treated as a directional finding rather than a definitive pattern — but it is consistent with the distance data in Analysis 4 and 5 and points to a meaningful urban-rural dimension in DEIS accessibility.

---

## Analysis 7 — Population Weighted Coverage

A population-weighted calculation was attempted but is not reported as a headline finding. The population data used is from 2016 at Electoral Division level — not matched at small area level — making any precise population-weighted figure unreliable.

The more defensible headline finding is the 96.1% area-based coverage for Very Disadvantaged small areas reported in Analysis 5. This figure is based on area counts not population estimates and is not subject to the same data quality constraints.

The population-weighted calculation is included in 04_analysis.sql for completeness only.

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

Key finding: six deprived small areas identified in this dataset have no DEIS school within 5km. The two Mayo areas are the most isolated at 16.2km and 11.5km respectively. The four Limerick county areas share an identical population figure of 1,408 — this is not coincidental. In the CSO small area system, a single Electoral Division is subdivided into multiple small areas, all of which inherit the same ED-level population figure. These four small areas are therefore confirmed to be subdivisions of a single ED, representing one community of approximately 1,408 people. Combined with the two Mayo areas, this analysis identifies approximately one community in Limerick county and two smaller rural areas in Mayo with no DEIS post-primary school within straight-line 5km.

---

## Analysis 9 — Priority Ranking for Policy Action

To move from descriptive finding to decision support, uncovered deprived small areas were ranked by a normalised priority score combining distance and deprivation. All inputs were normalised to a 0-1 scale using min-max scaling before combination to ensure comparability. Population was excluded given data quality constraints identified in Analysis 7.

**Weights applied:** distance 0.6, deprivation 0.4 — illustrative only. Policymakers could adjust these weights based on intervention priorities — a transport-focused response might weight distance more heavily, a deprivation-focused response might invert the balance.

| Small Area | County | Deprivation Score | Distance (km) | Priority Score |
|---|---|---|---|---|
| A157040001 | Mayo | -23.06 | 16.20 | 0.649 |
| A157114001 | Mayo | -24.97 | 11.47 | 0.504 |
| A127123005 | Limerick | -23.01 | 10.97 | 0.454 |
| A127123002 | Limerick | -23.01 | 10.67 | 0.443 |
| A127123004 | Limerick | -23.01 | 10.66 | 0.442 |
| A127123003 | Limerick | -23.01 | 10.54 | 0.438 |

Key finding: Mayo small area A157040001 scores highest on both distance and deprivation combined — it is the priority case for intervention. The four Limerick county areas cluster closely together, reflecting their shared ED origin. Priority scores are relative rankings not absolute measures of need.

---

## Limitations

### Data Limitations
- Deprivation data is at Electoral Division level not Small Area level — true small area data requires a license from the authors. ED-level aggregation likely dilutes extreme deprivation in urban and rural areas alike.
- DEIS school designation uses different methodology to the Pobal deprivation index — they measure different things and don't perfectly align. Some counties with DEIS schools (e.g. Leitrim) do not appear in the deprived small areas analysis, suggesting ED-level data may undercount rural disadvantage.
- School location data is from 2016 — some schools may have opened, closed, or moved since then.
- Population figures are from 2016 and may not reflect current demographics — some areas will have grown or shrunk significantly.
- School capacity is not accounted for — a DEIS school within 5km may be oversubscribed.
- 74 small areas (0.4%) have no deprivation score due to centroids falling on ED boundaries.
- 5 DEIS schools from the Department of Education list could not be matched to the schools location dataset.

### Methodological Limitations
- The deprivation join pipeline is hybrid: Stage 1 uses spatial containment to identify the ED, Stage 2 uses ED name matching to assign deprivation scores. No guaranteed unique key exists between the ED boundary dataset and the deprivation table. A duplicate name audit found 193 ED names appearing more than once in the deprivation table — NEWTOWN appears 8 times, CASTLETOWN 8 times, KILBRIDE 7 times. For small areas whose centroids fell in EDs with common placenames, the correct county's deprivation score cannot be guaranteed. DISTINCT ON resolved duplicate matches pragmatically but county assignment for common names remains a structural uncertainty.
- Distance is measured as straight-line (Euclidean) not road distance — this is the most significant limitation affecting the findings. Straight-line distance likely overstates accessibility in rural areas with limited road networks, meaning coverage figures for Mayo and Limerick county may be overstated. Road network distance using pgRouting is identified as the priority extension for future work.
- Centroid-based distance assumes everyone in a small area lives at its centre — in large rural small areas this could introduce significant error.
- The 5km buffer threshold is a methodological choice not empirically derived. It assumes access to transport — in areas without a car, even 3km could be a meaningful barrier.
- County comparison mixes cities and counties as separate administrative units (e.g. Limerick City vs Limerick county) — interpret carefully.

### Coverage Limitations
- Only post-primary DEIS schools are analysed — primary DEIS schools are excluded.
- School transport schemes are not accounted for — these extend the effective reach of schools significantly in rural areas and could change coverage figures substantially.
- Northern Ireland is excluded entirely — cross-border patterns are not captured.
- Analysis covers the Republic of Ireland only using 2022 small area boundaries.

---

## Future Work

### Priority Extension
- **Road distance analysis** — replacing straight-line distances with road network distances using OSM data and pgRouting is the single extension that would most materially change the findings of this analysis. Given the rural accessibility gap identified in Mayo and Limerick county, road network distances are likely to substantially reduce coverage figures for these areas. This is the priority next step for anyone building on this work.

### Immediate Extensions
- **Age-weighted coverage** — incorporate CSO 2022 small area age breakdown to weight coverage by the proportion of 12-18 year olds in each area.
- **3km and 10km sensitivity analysis** — rerun all coverage analyses at alternative buffer thresholds to test robustness of findings.
- **CSO urban-rural classification** — adding the CSO settlement layer would convert the urban-rural inference into an evidenced finding.

### Deeper Investigation
- **The Limerick concentration** — all 7 extremely disadvantaged small areas are in Limerick City. This warrants deeper investigation — is it a data artefact of ED-level aggregation or a genuine concentration of extreme deprivation?
- **Donegal anomaly** — Donegal has 19 DEIS schools despite being predominantly rural. Investigating whether this reflects genuine deprivation patterns or historical policy decisions would require historical DEIS designation data.
- **DEIS vs non-DEIS comparison** — a more detailed analysis of whether deprived areas are proportionally better served by DEIS schools relative to affluent areas, controlling for overall school density.

### Broader Research Questions
- **Temporal analysis** — how has DEIS school placement changed over time?
- **Transport integration** — incorporating Bus Éireann and school transport scheme routes to model effective rather than geometric accessibility.
- **Primary school analysis** — extending the analysis to DEIS primary schools.
- **Cross-border analysis** — extending the study to include Northern Ireland.
- **Small area deprivation data** — repeating the analysis with true small area level deprivation data to validate findings.