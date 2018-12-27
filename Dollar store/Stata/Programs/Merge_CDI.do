// This file spatially joins xy data to shapefiles

* set up
clear
set type double
cd "C:\Users\perez_g\Desktop\Data_vis_wa\Dollar store\Stata"

gl root "C:\Users\perez_g\Desktop\Data_vis_wa\Dollar store"
gl GIS "$root\GIS"
gl Stata "$root\Stata"
gl Dollar_data "$root\Dollar store data"
gl Citylab_data "$root\City lab data"


* import CDI file from city labs
import delimited "$Citylab_data\CDI.csv", clear
ren cd district
split district, p("-")
ren district1 state
ren district2 number
save "CDI.dta", replace

* create matching number and state variables for the store file
use "DS_mapped_to_dist.dta", clear
ren NAMELSAD district
replace district = subinstr(district, "Congressional District ", "",.)
drop if district == "Delegate District (at Large)" // DC isnt in the CDI data
replace district = "AL" if district == "(at Large)"
ren district number
replace number = (2-length(number))*"0" +number

* merge in CDI
merge m:1 state number using "CDI.dta"
keep if _m == 3
drop _m

save "Dollar_CDI.dta", replace


use "Dollar_CDI.dta", clear
keep if state == "PA"
* Stores per district
gen counter = 1
collapse (sum) counter, by(district cluster _ID)
collapse (mean) counter, by(cluster)


spmap counter using "Districts_coor.dta", id(_ID) fcolor(Reds)
