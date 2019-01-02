// This file spatially joins xy data to shapefiles

* set up
clear
set type double
cd "C:\Users\perez_g\Desktop\Data_vis_wa\data_vis_wa\Dollar store\Stata\Programs"

gl root "C:\Users\perez_g\Desktop\Data_vis_wa\data_vis_wa\Dollar store"
gl GIS "$root\GIS"
gl Stata "$root\Stata"
gl Dollar_data "$root\Dollar store data"

  
*Create a Dta from a shape file
capture shp2dta using "$GIS/Shapefiles/cb_2017_us_county_5m.shp", genid(_ID) data("County_data.dta") coor("County_coor.dta") replace

use "Districts_coor.dta", clear

*Import CSV with xy data
import delimited "$Dollar_data\Dollar stores.csv", stringcols(4 9) clear 
drop ïobjectid
replace zip5 = (5-length(zip5))*"0" +zip5
gen _X = x
gen _Y = y

save "Dollar_store_info.dta", replace


* Spatial join using geoinpoly points to polygons
geoinpoly _Y _X using "Districts_coor.dta"


* merge the matched polygons with the database and get attributes
merge m:1 _ID using "Districts_data.dta", keep(master match) 
keep if _m == 3
drop _m

save "DS_mapped_to_dist.dta", replace

