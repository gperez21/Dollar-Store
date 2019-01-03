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
import delimited "$Electoral_data\1976-2016-house.csv", varnames(1) clear
// wyoming candidates not categorized by party
replace part = "republican" if candidate == "Liz Cheney"
replace part = "democrat" if candidate == "Ryan Greene"
replace part = "democrat" if candidate == "Ro Khanna"
replace part = "republican" if candidate == "Clint Didier"
// just 2016 election
keep if year == 2016
// drop over votes, blanks and write in for no party
drop if strpos(lower(candidate),"over vote")
drop if strpos(lower(candidate),"blank vote")
replace party = subinstr(party, " ", "",.)
replace party = "democrat" if strpos(party,"democrat")
// replace party = "republican" if strpos(party,"conservative")
// drop if writein == "TRUE" & party == ""
// clean name of district to match
tostring district, replace
replace district = "0"+district if length(district) == 1
replace district = "AL" if district == "00"
replace district = state_po + "-" + district
// classify rep/dem/other
replace party = "other" if party != "democrat" & party != "republican"
collapse (sum) candidatevotes, by(year state state_po state_fips state_cen state_ic office district stage special party totalvotes)
// find percent of vote by party
egen total2016 = sum(candidate), by(district)
gen pct2016 = candidate/total2016
keep district total2016 pct2016 party
//FL 24 was uncontested
replace pct2016 = 1 if district == "FL-24"
compress

sort district

// reshape wide
reshape wide pct2016, i(district total) j(party) string
gen unc2016 = "democrat" if missing(pct2016dem) | pct2016dem < .025 
replace unc2016 = "republican" if missing(pct2016rep) | pct2016rep < .025 

save "$Data\2016_results", replace 

