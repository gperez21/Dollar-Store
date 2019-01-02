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

  
*Create a Dta from a shape file
shp2dta using "$GIS/Shapefiles/cb_2017_us_county_5m.shp", genid(_ID) data("$Data\County_data.dta") coor("$Data\County_coor.dta") replace

use "$Data/County_data.dta", clear

*Import CSV with xy data
import delimited "$Dollar_data\original_wf_data.csv",clear 
ren (v1 v2 v3 v4)(x y name address)

gen _X = x
gen _Y = y

save "$Data\WF_store_info.dta", replace


* Spatial join using geoinpoly points to polygons
geoinpoly _Y _X using "$Data\County_coor.dta"


* merge the matched polygons with the database and get attributes
merge m:1 _ID using "$Data\County_data.dta", keep(master match) 
// Drop Canadian WF
keep if _m == 3
drop _m

save "$Data\WF_mapped_to_dist.dta", replace


use "$Data\WF_mapped_to_dist.dta", clear
* Find number of counties with a Whole Foods
gen Number_of_Wholefoods = 1 
collapse (sum) count, by(STATEFP COUNTYFP GEOID NAME)
export delimited "$Dollar_data\WholeFoods_by_county.csv"


// Find how many dollar stores there are in each county
*

*Import CSV with xy data
import delimited "$Dollar_data\Dollar stores.csv", stringcols(4 9) clear 
drop ïobjectid
replace zip5 = (5-length(zip5))*"0" +zip5
gen _X = x
gen _Y = y

save "Dollar_store_info.dta", replace


* Spatial join using geoinpoly points to polygons
geoinpoly _Y _X using "$Data\County_coor.dta"


* merge the matched polygons with the database and get attributes
merge m:1 _ID using "$Data\County_data.dta", keep(master match) 
keep if _m == 3
drop _m

* Find number of counties with a Whole Foods
gen Number_of_DS = 1 
collapse (sum) Number_of_DS, by(STATEFP COUNTYFP GEOID NAME)
export delimited "$Dollar_data\Dollar_by_county.csv"
