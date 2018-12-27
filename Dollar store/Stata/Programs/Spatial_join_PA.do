// This file spatially joins xy data to shapefiles

* set up
clear
set type double
cd "C:\Users\perez_g\Desktop\Data_vis_wa\Dollar store\Stata"

gl root "C:\Users\perez_g\Desktop\Data_vis_wa\Dollar store"
gl GIS "$root\GIS"
gl Stata "$root\Stata"
gl Dollar_data "$root\Dollar store data"

 
*Create a Dta from a shape file
capture shp2dta using "$GIS/tl_2016_39_sldl.shp", genid(_ID) data("OH_data.dta") coor("OH_coor.dta") replace

// use "OH_coor.dta", clear
// replace _Y = _Y/(3600*6)
// replace _X = (_X*-1)/(3600*6)
// save "OH_coor.dta", replace

*Import CSV with xy data
import delimited "$Dollar_data\Dollar stores.csv", stringcols(4 9) clear 
keep if state == "OH"
drop ïobjectid
replace zip5 = (5-length(zip5))*"0" +zip5
gen _X = x
gen _Y = y

save "OH_info.dta", replace


* Spatial join using geoinpoly points to polygons
geoinpoly _Y _X using "OH_coor.dta"


* merge the matched polygons with the database and get attributes
merge m:1 _ID using "OH_data.dta", keep(master match) 
keep if _m == 3
drop _m

save "OH_joined.dta", replace

use "OH_joined.dta", clear

* Stores per district
gen counter = 1
collapse (sum) counter, by(NAMELSAD _ID)


spmap counter using "OH_coor.dta", id(_ID) fcolor(Reds)
