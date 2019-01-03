// This file spatially joins xy data to shapefiles

* set up
clear
set type double
cd "C:\Users\perez_g\Desktop\Data_vis_wa\data_vis_wa\Dollar store\Stata\Programs"

gl root "C:\Users\perez_g\Desktop\Data_vis_wa\data_vis_wa\Dollar store"
gl GIS "$root\GIS"
gl Stata "$root\Stata"
gl Data "$Stata\Data"
gl Dollar_data "$root\Dollar store data"
gl Electoral_data "$root\Electoral data"

// Import poverty data
import delimited "$Electoral_data\poverty_line.csv", varnames(1)

// standardize congressional districtID
tostring congressionaldistrictid, replace
replace congressionaldistrictid = "0"*(4-length(congressionaldistrictid))+congressionaldistrictid
gen GEOID = congressionaldistrictid
ren number  num_100
ren percent  pct_100
ren v6  num_185
ren v7  pct_185
label var pct_185 "Percent of District Living Below 185% of Poverty Line"
label var pct_100 "Percent of District Living Below Poverty Line"
save "$Data\poverty.dta", replace

// Merge in data to dollar stores
use "$Data/DS_mapped_to_dist.dta", clear
merge m:1 GEOID using "$Data\poverty.dta"

// Collapse onto district
gen Stores = 1
collapse (sum) Stores, by(GEOID congressionaldistrictid congressionaldistrictname num_100 pct_100 num_185 pct_185 ALAND)
replace pct_185 = pct_185*100
replace pct_100 = pct_100*100
gen sq_km = ALAND/1000000
gen sq_km_sq = sq_km^2

// gen band_30_60 = 1 if Stores >= 30 & Stores <= 60
// gen sixty = 1 if Stores > 60
// gen thirty = 1 if Stores < 30
// keep if thirty == 1
// collapse (mean) pct*, by(thi) 

twoway ///
(scatter Stores pct_185, ///
msize(tiny) ///
) ///
(scatter Stores pct_100, ///
msize(tiny) ///
graphregion(color(white)) ///
ylab(,nogrid) ///
leg(off) ///
) 

(lfit Stores pct_100, lcolor(navy)) ///
(lfit Stores pct_185, lcolor(cranberry))

twoway (scatter Stores sq_km, msize(vtiny)) (fpfit Stores sq_km)
