# Literature Review

## Spatial Access to Education and Deprivation in Ireland: A Review of Relevant Literature

This literature review contextualises the methodology and findings of the DEIS spatial 
analysis within the existing body of research on spatial inequality in Irish education, 
deprivation measurement, and spatial access to services.

---

### 1. The Pobal HP Deprivation Index

The deprivation data used in this analysis is drawn from the Pobal HP Deprivation Index, 
developed by Haase and Pratschke using Confirmatory Factor Analysis applied to Irish 
census data. Haase, Pratschke and Gleeson (2012) describe the methodological foundations 
of this approach, noting that the use of Confirmatory rather than Exploratory Factor 
Analysis allows for comparable deprivation scores across successive census waves — a 
key advantage over indices developed elsewhere in Europe. The index combines three 
underlying dimensions: demographic profile, social class composition, and labour market 
situation, measured across ten indicators at Electoral Division level.

A critical limitation for this analysis follows directly from this methodology. As Haase 
et al. (2012) acknowledge, the index is published at Electoral Division level in its 
publicly available form; small area level data requires a license from the authors. This 
means that deprivation scores used here represent aggregated ED-level values, which 
may dilute pockets of extreme deprivation within larger EDs. Pratschke and Haase (2015) 
further demonstrate, through longitudinal analysis of five census waves from 1991 to 
2011, that the spatial distribution of deprivation in Ireland shifted substantially during 
the economic boom and subsequent downturn — a further reason to treat any single wave 
of ED-level data with caution when making claims about current deprivation patterns.

Mogin et al. (2025), in a European-wide scoping review of multiple deprivation indices, 
identify the Pobal HP index as one of eighteen indices currently applied across Europe, 
noting that it uses confirmatory factor analysis for weighting — an approach shared by 
only a minority of European indices. This contextualises the methodological choice 
embedded in the data used here and highlights that index construction always involves 
value judgements about which dimensions of deprivation to measure and how to weight them.

---

### 2. Spatial Analysis of Schools and Deprivation in Ireland

Doyle, Foley and Houghton (2024) provide the closest methodological parallel to this 
analysis. Using QGIS and 300-metre buffer analysis around all schools in Ireland, they 
examine the density of licensed alcohol premises in the vicinity of DEIS and non-DEIS 
schools, finding that schools in the most disadvantaged areas have significantly higher 
numbers of licensed premises nearby. Critically, they use the same Pobal HP Deprivation 
Index and the same DEIS classification as this analysis, and they note explicitly that 
their GIS analysis establishes Euclidean distances rather than road network distances — 
the same limitation that applies here. This parallel supports the methodological choices 
made in this analysis while also confirming that road network distance remains an 
important extension for future work.

Mancini (2023) examines spatial inequalities in post-primary school provision in Ireland, 
finding that active transport to school follows educational provision rather than 
population density — settlements without post-primary schools have near-zero rates of 
adolescent active travel. This research demonstrates that physical proximity to schools 
has measurable consequences for communities beyond educational outcomes alone, 
reinforcing the policy relevance of the access gap identified in this analysis for Mayo 
and Limerick county.

---

### 3. Deprivation, Poverty and Spatial Inequality in Ireland

Nolan, Whelan and Williams (1998) provide a foundational analysis of the spatial 
distribution of poverty and deprivation in Ireland, establishing that deprivation is not 
randomly distributed but clusters spatially — a finding that underpins the rationale for 
spatially targeted policy interventions such as DEIS. While this work predates the current 
analysis by over two decades, its core finding that spatial targeting of resources requires 
accurate small-area deprivation measurement remains directly relevant to the limitations 
identified here.

---

### 4. Spatial Access to Schools and Deprivation — International Context

Macdonald et al. (2016), in a Scotland-wide GIS analysis of walkability around primary 
schools by deprivation quintile, find that built environment features around schools differ 
significantly by area deprivation — though the pattern is non-linear and varies by 
geographic scale. Their use of school catchment areas rather than simple buffers 
represents a more sophisticated spatial approach than the 5km buffer used in this 
analysis, and their finding that results vary depending on whether national or city-level 
analysis is conducted is directly relevant to the urban-rural pattern identified here. 
They note that rural schools were excluded from their analysis precisely because catchment 
areas in rural settings extend well beyond walkable distances — a structural issue that 
also affects the interpretation of rural coverage findings in this analysis.

---

### 5. Vulnerability Index Construction

McCullagh et al. (2025), developing a Social Vulnerability Index for Cork, Logroño and 
Milan, outline a tiered methodology for combining normalised indicators into a composite 
vulnerability score using z-score standardisation with equal domain weighting. Their 
experience of applying this methodology across different national contexts — encountering 
data availability constraints and having to adapt weighting schemes accordingly — is 
directly relevant to the priority ranking introduced in Analysis 9 of this project. Their 
finding that z-score normalisation is essential before combining variables on different 
scales validates the methodological decision to normalise distance and deprivation inputs 
before combining them, and their recommendation to document weighting decisions 
transparently has been followed in this analysis.

---

### Summary

The literature reviewed here contextualises three key aspects of this analysis:

1. **The deprivation data** — Haase, Pratschke and Gleeson (2012) and Pratschke and 
   Haase (2015) establish the foundations and limitations of the Pobal HP index used 
   here; the ED-level aggregation issue is an inherent feature of the publicly available 
   data, not a methodological error.

2. **The spatial approach** — Doyle et al. (2024) and Macdonald et al. (2016) both use 
   Euclidean buffer analysis in comparable contexts, confirming that straight-line 
   distance is standard in this literature while also confirming that road network 
   distance remains an important extension.

3. **The priority ranking** — McCullagh et al. (2025) provide direct methodological 
   support for the normalised composite scoring approach used in Analysis 9.

A key gap in the literature is the absence of published spatial analysis specifically 
examining DEIS post-primary school coverage at small area level — this analysis 
addresses that gap directly.

---

### References

Doyle, A., Foley, R. and Houghton, F. (2024) 'A spatial examination of alcohol 
availability and the level of disadvantage of schools in Ireland', *BMC Public Health*, 
24(1), p. 795. https://doi.org/10.1186/s12889-024-18280-z

Haase, T., Pratschke, J. and Gleeson, J. (2012) 'All-island deprivation index: towards 
the development of consistent deprivation measures for the island of Ireland', 
*Borderlands: The Journal of Spatial Planning in Ireland*, pp. 21–37.

Macdonald, L., McCrorie, P., Nicholls, N. and Ellaway, A. (2016) 'Walkability around 
primary schools and area deprivation across Scotland', *BMC Public Health*, 16(1), 
p. 328. https://doi.org/10.1186/s12889-016-2964-x

Mancini, J.M. (2023) 'Census and sustainability: school provision, urban teenagers, and 
unequal access to active transport in the Republic of Ireland', *Irish Educational 
Studies*, 42(2), pp. 221–240. https://doi.org/10.1080/03323315.2023.2260379

McCullagh, D., Cámaro-García, W., Dunne, D., Nowbakht, P., Cumiskey, L., Gannon, C. 
and Phillips, C. (2025) 'Development of a social vulnerability index: enhancing 
approaches to support climate justice', *MethodsX*, 14, p. 103290. 
https://doi.org/10.1016/j.mex.2025.103290

Mogin, G., Gorasso, V., Idavain, J., Lepnurm, M., Delaunay-Havard, S., Bølling, A.K., 
Buekers, J., Luyten, A., Devleesschauwer, B. and Baravelli, C.M. (2025) 'A scoping 
review of multiple deprivation indices in Europe', *European Journal of Public Health*, 
35(6), pp. 1122–1128. https://doi.org/10.1093/eurpub/ckaf190

Nolan, B., Whelan, C.T. and Williams, J. (1998) *Where are poor households? The spatial 
distribution of poverty and deprivation in Ireland*. Dublin: Oak Tree Press in 
association with Combat Poverty Agency.

Pratschke, J. and Haase, T. (2015) 'A longitudinal study of area-level deprivation in 
Ireland, 1991–2011', *Environment and Planning B: Planning and Design*, 42(3), 
pp. 442–458. https://doi.org/10.1068/b130043p