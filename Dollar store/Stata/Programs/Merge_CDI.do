// This file spatially joins xy data to shapefiles

* set up
clear
set type double
cd "C:\Users\perez_g\Desktop\Data_vis_wa\data_vis_wa\Dollar store\Stata"

gl root "C:\Users\perez_g\Desktop\Data_vis_wa\data_vis_wa\Dollar store"
gl GIS "$root\GIS"
gl Stata "$root\Stata"
gl Data "$Stata\Data"
gl Dollar_data "$root\Dollar store data"
gl Citylab_data "$root\City lab data"


* import CDI file from city labs
import delimited "$Citylab_data\CDI.csv", clear
ren cd district
split district, p("-")
ren district1 state
ren district2 number
save "$Data\CDI.dta", replace

* create matching number and state variables for the store file
use "$Data\DS_mapped_to_dist.dta", clear
ren NAMELSAD district
replace district = subinstr(district, "Congressional District ", "",.)
drop if district == "Delegate District (at Large)" // DC isnt in the CDI data
replace district = "AL" if district == "(at Large)"
ren district number
replace number = (2-length(number))*"0" +number

* merge in CDI
merge m:1 state number using "$Data\CDI.dta"
keep if _m == 3
drop _m

save "$Data\Dollar_CDI.dta", replace


use "$Data\Dollar_CDI.dta", clear

* Stores per district
gen Number_of_stores = 1
collapse (sum) Number_of_stores, by(district cluster _ID)
export delimited "$Data\District_classification.csv", replace
collapse (mean) Number_of_stores, by(cluster)
export delimited "$Data\Mean_store_by_cluster.csv", replace

spmap Number_of_stores using "Districts_coor.dta", id(_ID) fcolor(Reds)
