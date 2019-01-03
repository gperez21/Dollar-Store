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
gl Citylab_data "$root\City lab data"


* import harvard congressional election data set
import excel "$Electoral_data\2018-house.xlsx", firstrow clear
// clean name of district to match
tostring district, replace
replace district = "0"+district if length(district) == 1
replace district = "AL" if district == "0."
replace district = state + "-" + district
drop if missing(state)
sort district
// tag uncontested
gen unc2018 = "democrat" if democrat == "*"
replace unc2018 = "republican" if republican == "*"
replace dem = "1" if rep == "*"
replace rep = "1" if dem == "*"
destring (rep dem), replace force
ren (rep dem) (pct2018rep pct2018dem)
drop state

save "$Data\2018_results", replace 

