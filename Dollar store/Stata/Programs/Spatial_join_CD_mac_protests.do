

clear
set type double
cd "/Users/lep12/Desktop/Dollar-Store/Dollar store/Stata/Programs"

gl root "/Users/lep12/Desktop/Dollar-Store/Dollar store"
gl GIS "$root/GIS"
gl Stata "$root/Stata"
gl Data "$Stata/Data"
gl Dollar_data "$root/Dollar store data"
gl Citylab_data "$root/City lab data"
gl Electoral_data "$root/Electoral data"

 
*Create a Dta from a shape file
capture shp2dta using "$GIS/Shapefiles/tl_2018_us_cd116.shp", genid(_ID) data("$Data/Districts_data.dta") coor("$Data/Districts_coor.dta") replace



use "$Data/families_belong_tog", clear
destring g_lat g_lon, replace

gen _X = g_lon
gen _Y = g_lat
save "$Data/families_belong_tog", replace

* Spatial join using geoinpoly points to polygons
geoinpoly _Y _X using "$Data/Districts_coor.dta"


* merge the matched polygons with the database and get attributes
merge m:1 _ID using "$Data/Districts_data.dta", keep(master match) 
keep if _m == 3
drop _m

save "$Data/Prostests_mapped_to_dist.dta", replace


use "$Data/Prostests_mapped_to_dist.dta",  clear

* Stores per district
gen counter = 1
collapse (sum) counter, by(_ID STATEFP)
keep if STATEFP == "39"
// keep if STATEFP == "39" | STATEFP == "42"| STATEFP == "54"
* Make PA map
spmap counter using "$Data/Districts_coor.dta" , id(_ID) fcolor(Reds) ///
clmethod(custom) clbreaks(0 25 50 75 100 125) ///
legend(symy(*2) symx(*2) size(*1.25) position (4)) 
