# DEIS Spatial Analysis

## Spatial inequality in school access: coverage of DEIS post-primary schools across deprived small areas in Ireland

### Research Question
What proportion of Ireland's most deprived small areas are within 5km of a DEIS post-primary school, and does the spatial pattern suggest effective policy targeting?

---

## Key Findings
- **96.1%** of Very Disadvantaged small areas are within 5km of a DEIS school — the headline finding of this analysis
- **100%** of Extremely Disadvantaged small areas are within 5km — treat as illustrative given very small sample size (7 areas) and ED-level aggregation constraints
- Within this dataset, every identified deprived urban area is covered and no identified deprived rural area is covered at the 5km threshold
- **6 deprived small areas** identified with no DEIS school within 5km
- Most isolated: Mayo small area A157040001 at 16.2km — highest priority for intervention based on combined distance and deprivation ranking

---

## Operational Relevance
**Who would use this:** Department of Education DEIS policy team, school transport scheme planners, local authorities in Mayo and Limerick county.

**What decision it informs:** Where to prioritise new DEIS school designations or enhanced transport provision for post-primary students in deprived areas currently outside the 5km coverage threshold.

**What this analysis cannot do:** Road network distance is not included — straight-line distance overstates accessibility in rural areas. School capacity is unknown. Population data is from 2016 at ED level only.

---

## Tools
- PostgreSQL 16 + PostGIS 3.6.2
- pgAdmin 4
- Python 3.9.6 (openpyxl for Excel conversion)
- ogr2ogr (via Homebrew)
- QGIS (maps in progress)
- Git / GitHub

## Data Sources
- CSO Small Area boundaries 2022 — data.gov.ie
- CSO Electoral Division boundaries 2022 — data.gov.ie
- Pobal HP Deprivation Index 2022 — data.gov.ie (ED level only)
- DEIS post-primary schools list — Department of Education
- Post-primary schools locations 2016 — compiled from data.gov.ie

*Note: data files are not included in this repository due to file size. All sources are freely available from the links above.*

---

## Repository Structure
```
├── sql/
│   ├── 01_setup.sql           # Table creation
│   ├── 02_import.sql          # Data import commands
│   ├── 03_cleaning.sql        # Data cleaning and spatial join
│   └── 04_analysis.sql        # All analysis queries including join audit and priority ranking
├── maps/                      # QGIS map exports (in progress)
├── analysis.md                # Full methodology, findings, limitations, future work
├── literature_review.md       # Academic context (in progress)
├── policy_brief.pdf           # One-page policy recommendations (in progress)
├── environment.txt            # Software versions and dependencies
└── README.md
```

---

## Methodology
Full methodology including data cleaning decisions, hybrid join structure, join quality audit, duplicate name analysis and limitations is documented in [analysis.md](analysis.md).

### Join Quality Audit Results
- 16,837 total small areas
- 16,763 matched with deprivation data (99.6%)
- 74 unmatched due to centroid boundary ambiguity
- 193 ED names appear more than once in deprivation table — hybrid join structural limitation documented in analysis.md