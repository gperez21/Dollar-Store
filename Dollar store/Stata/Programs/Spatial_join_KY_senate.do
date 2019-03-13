// This file spatially joins xy data to shapefiles

* set up
clear
set type double
cd "C:\Users\perez_g\Desktop\Data_vis_wa\data_vis_wa\Dollar store\Stata\Programs"

gl root "C:\Users\perez_g\Desktop\Data_vis_wa\data_vis_wa\Dollar store"
gl GIS "$root\GIS\Shapefiles"
gl Stata "$root\Stata"
gl Data "$Stata\Data"
gl Dollar_data "$root\Dollar store data"
gl Electoral_data "$root\Electoral data"
gl Citylab_data "$root\City lab data"

 
*Create a Dta from a shape file
capture shp2dta using "$GIS/cb_2017_21_sldu_500k.shp", genid(_ID) data("$Data\KY_L_data.dta") coor("$Data\KY_L_coor.dta") replace

*Import CSV with xy data
import delimited "$Dollar_data\Dollar stores.csv", stringcols(4 9) clear 
keep if state == "KY"
drop ïobjectid
replace zip5 = (5-length(zip5))*"0" +zip5
gen _X = x
gen _Y = y

save "$Data\KY_info.dta", replace


* Spatial join using geoinpoly points to polygons
geoinpoly _Y _X using "$Data\KY_L_coor.dta"


* merge the matched polygons with the database and get attributes
merge m:1 _ID using "$Data\KY_L_data.dta", keep(master match) 
keep if _m == 3
drop _m

save "$Data\KY_joined.dta", replace

use "$Data\KY_joined.dta", clear

* Stores per district
gen counter = 1
collapse (sum) counter, by(_ID NAME)

* Make PA map
spmap counter using "$Data\KY_L_coor.dta", id(_ID) fcolor(Reds) ///
clmethod(custom) clbreaks(0 5 10 15 20 25 35) ///
legend(symy(*2) symx(*2) size(*2) position (4)) 

