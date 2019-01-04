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

// Create district var
gen district = congressionaldistrictname
replace district = subinstr(district, "Congressional District ","",.)
replace district = subinstr(district, "ï»¿", "",.)
replace district = subinstr(district, " ","",.)
replace district = "0"+ district if length(district) == 1
replace district = "AL" if district == "(atLarge)"
drop if state == "District of Columbia"
gen statehold = state
replace state = "CA" if state == "California"
replace state = "NY" if state == "New York"
replace state = "VA" if state == "Virginia"
replace state = "NJ" if state == "New Jersey"
replace state = "MD" if state == "Maryland"
replace state = "MA" if state == "Massachusetts"
replace state = "TX" if state == "Texas"
replace state = "CT" if state == "Connecticut"
replace state = "IL" if state == "Illinois"
replace state = "WA" if state == "Washington"
replace state = "MN" if state == "Minnesota"
replace state = "GA" if state == "Georgia"
replace state = "MO" if state == "Missouri"
replace state = "CO" if state == "Colorado"
replace state = "MI" if state == "Michigan"
replace state = "PA" if state == "Pennsylvania"
replace state = "NC" if state == "North Carolina"
replace state = "KS" if state == "Kansas"
replace state = "AZ" if state == "Arizona"
replace state = "HI" if state == "Hawaii"
replace state = "WI" if state == "Wisconsin"
replace state = "NH" if state == "New Hampshire"
replace state = "FL" if state == "Florida"
replace state = "IN" if state == "Indiana"
replace state = "OR" if state == "Oregon"
replace state = "OH" if state == "Ohio"
replace state = "RI" if state == "Rhode Island"
replace state = "NV" if state == "Nevada"
replace state = "ME" if state == "Maine"
replace state = "NE" if state == "Nebraska"
replace state = "SC" if state == "South Carolina"
replace state = "IA" if state == "Iowa"
replace state = "VT" if state == "Vermont"
replace state = "AL" if state == "Alabama"
replace state = "AK" if state == "Alaska"
replace state = "LA" if state == "Louisiana"
replace state = "UT" if state == "Utah"
replace state = "DE" if state == "Delaware"
replace state = "ND" if state == "North Dakota"
replace state = "WY" if state == "Wyoming"
replace state = "NM" if state == "New Mexico"
replace state = "KY" if state == "Kentucky"
replace state = "SD" if state == "South Dakota"
replace state = "TN" if state == "Tennessee"
replace state = "OK" if state == "Oklahoma"
replace state = "ID" if state == "Idaho"
replace state = "AR" if state == "Arkansas"
replace state = "MT" if state == "Montana"
replace state = "WV" if state == "West Virginia"
replace state = "MS" if state == "Mississippi"

replace district = state + "-" + district
replace state = statehold
drop statehold

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
//
// twoway ///
// (scatter Stores pct_185, ///
// msize(tiny) ///
// ) ///
// (scatter Stores pct_100, ///
// msize(tiny) ///
// graphregion(color(white)) ///
// ylab(,nogrid) ///
// leg(off) ///
// ) 
//
// (lfit Stores pct_100, lcolor(navy)) ///
// (lfit Stores pct_185, lcolor(cranberry))
//
// twoway (scatter Stores sq_km, msize(vtiny)) (fpfit Stores sq_km)
