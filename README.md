# DEIS Spatial Analysis

## Spatial inequality in school access: coverage of DEIS post-primary schools across deprived small areas in Ireland

### Research Question
What proportion of Ireland's most deprived small areas are within 5km of a DEIS post-primary school, and does the spatial pattern suggest effective policy targeting?

---

## Key Findings
- **98.5%** of people in extremely or very disadvantaged areas live within 5km of a DEIS school
- **100%** of extremely disadvantaged small areas are within 5km of a DEIS school
- **96.1%** of very disadvantaged small areas are within 5km of a DEIS school
- Clear urban-rural divide: all urban deprived areas have 100% coverage; rural deprived areas have zero coverage
- 6 deprived small areas have no DEIS school within 5km — the most isolated is 16.2km away in Mayo

---

## Tools
- PostgreSQL 16 + PostGIS 3.6.2
- pgAdmin 4
- Python 3.9.6
- ogr2ogr
- QGIS (maps in progress)

## Data Sources
- CSO Small Area boundaries 2022 — data.gov.ie
- CSO Electoral Division boundaries 2022 — data.gov.ie
- Pobal HP Deprivation Index 2022 — data.gov.ie
- DEIS post-primary schools list — Department of Education
- Post-primary schools locations 2016 — compiled from data.gov.ie

*Note: data files are not included in this repository due to file size. All sources are freely available from the links above.*

---

## Repository Structure
```
├── sql/
│   ├── 01_setup.sql       # Table creation
│   ├── 02_import.sql      # Data import commands
│   ├── 03_cleaning.sql    # Data cleaning and spatial join
│   └── 04_analysis.sql    # All analysis queries
├── maps/                  # QGIS map exports (in progress)
├── analysis.md            # Full methodology and findings
├── environment.txt        # Software versions and dependencies
└── README.md
```

---

## Methodology
Full methodology including data cleaning decisions, join validation and limitations is documented in [analysis.md](analysis.md).