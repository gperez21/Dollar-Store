// This file spatially joins xy data to shapefiles

* set up
clear
set type double
cd "C:\Users\perez_g\Desktop\Data_vis_wa\data_vis_wa\Dollar store\Stata\Programs"

gl root "C:\Users\perez_g\Desktop\Data_vis_wa\data_vis_wa\Dollar store"
gl GIS "$root\GIS"
gl Stata "$root\Stata"
gl Dollar_data "$root\Dollar store data"
gl Data "$Stata\Data"
gl Dollar_data "$root\Dollar store data"
gl Electoral_data "$root\Electoral data"
gl Citylab_data "$root\City lab data"
 
*Create a Dta from a shape file
capture shp2dta using "$GIS/Shapefiles/tl_2018_us_cd116.shp", genid(_ID) data("$Data\Districts_data.dta") coor("$Data\Districts_coor.dta") replace

use "$Data\Districts_coor.dta", clear

*Import CSV with xy data
import delimited "$Dollar_data\Dollar stores.csv", stringcols(4 9) clear 
drop ïobjectid
replace zip5 = (5-length(zip5))*"0" +zip5
gen _X = x
gen _Y = y

save "$Data\Dollar_store_info.dta", replace


* Spatial join using geoinpoly points to polygons
geoinpoly _Y _X using "$Data\Districts_coor.dta"


* merge the matched polygons with the database and get attributes
merge m:1 _ID using "$Data\Districts_data.dta", keep(master match) 
keep if _m == 3
drop _m

save "$Data\DS_mapped_to_dist.dta", replace


use "$Data\DS_mapped_to_dist.dta",  clear

* Stores per district
gen counter = 1
collapse (sum) counter, by(_ID)

gen band = 1 if counter < 61 & counter >29
replace band = 0 if band ==.
* Make PA map
spmap band using "$Data\Districts_coor.dta", id(_ID) fcolor(Reds) ///
legend(symy(*2) symx(*2) size(*2) position (4)) 

clmethod(custom) clbreaks(1 3 5 7 9 12) ///
