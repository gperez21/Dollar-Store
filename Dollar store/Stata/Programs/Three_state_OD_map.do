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
gl Overdose "$root\Overdose data"
  
*Create a Dta from a shape file
capture shp2dta using "$GIS/Shapefiles/cb_2017_us_county_5m.shp", genid(_ID) data("$Data\County_data.dta") coor("$Data\County_coor.dta") replace

use "$Data/County_data.dta", clear

*Import CSV with xy data
import delimited "$Overdose\Overdoses_OH_PA_WV.csv",clear 
ren (ïnotes countycode) (state GEOID)
drop if _n >210
destring deaths, replace force
tostring GEOID, replace
gen OD_rate = deaths*100000/population

* merge the matched polygons with the database and get attributes
merge m:1 GEOID using "$Data\County_data.dta" 
// Drop Canadian WF
keep if _m == 3
drop _m

save "$Data\Tristate_OD.dta", replace

*Import CSV with xy data
import delimited "$Dollar_data\Dollar stores.csv", stringcols(4 9) clear 
keep if state == "WV" | state == "PA" | state == "OH"
drop ïobjectid
replace zip5 = (5-length(zip5))*"0" +zip5
gen _X = x
gen _Y = y


* Spatial join using geoinpoly points to polygons
geoinpoly _Y _X using "$Data\County_coor.dta"
gen count = 1
collapse (sum) total_stores = count, by(_ID)
tempfile dstore
save `dstore'

use "$Data\Tristate_OD.dta", clear
merge 1:1 _ID using `dstore'
keep if _m == 3
drop _m
gen store_rate = total_stores*100000/population

// spmap store_rate using "$Data\County_coor.dta" , id(_ID) fcolor(Reds)

// twoway (scatter OD store_rate) (lfit store_rate OD_rate)
keep if total_stores > 2
keep if cruderate != "Unreliable"  & cruderate != "Suppressed"  
egen store_x = xtile(store_rate), nq(6)
sort store_rate
graph box OD, over(store_x) vertical
// regress store_rate OD_rate 

