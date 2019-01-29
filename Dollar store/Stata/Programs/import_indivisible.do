// This file spatially joins xy data to shapefiles

* set up
clear
set type double
cd "C:\Users\perez_g\Desktop\Data_vis_wa\data_vis_wa\Dollar store\Stata\Programs"

gl root "C:\Users\perez_g\Desktop\Data_vis_wa\data_vis_wa\Dollar store"
gl GIS "$root/GIS"
gl Stata "$root/Stata"
gl Data "$Stata/Data"
gl Dollar_data "$root/Dollar store data"
gl Electoral_data "$root/Electoral data"
gl Citylab_data "$root/City lab data"


import delimited "$Electoral_data\indivisible_events.csv", varnames(1) clear
tostring zipcode, replace
replace zipcode = "0"*(5-length(zipcode))+zipcode if zipcode != "."
br if length(zipcode) != 5

save "$Data\events", replace
drop if length(zipcode) == 5

// Limited to 2500 free requests per day
// only use one of the following commands- comment the other out
// if address is one string (less accurate)
// opencagegeo, key(e4c5a22b9a9540e880b666c332b7351f) fulladdress(location)

gen flag = 1 if g_quality >2
keep if flag == 1
keep *event g_lat g_lon
ren (g_lat g_lon)(x y)
save "$Data/indivisible_geocoded", replace

* import zip xy
import delimited "$GIS\Shapefiles\zipxy.txt", varnames(1) clear
ren ïzip zipcode
tostring zipcode, replace
replace zipcode = "0"*(5-length(zipcode))+zipcode
save "$Data\zipxy", replace

use "$Data\events", clear
drop if length(zipcode) != 5
append using "$Data/indivisible_geocoded"
replace zipcode = strtrim(zipcode)
merge m:1 zipcode using "$Data/zipxy"
drop if _m == 2



use "$Data/dollar_master_clean", clear
