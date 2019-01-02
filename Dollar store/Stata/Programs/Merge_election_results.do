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
gl Electoral_data "$root\Electoral data"
gl Citylab_data "$root\City lab data"

* import CDI file from city labs
import excel "$Electoral_data\general_results.xlsx", sheet("Results") cellrange(A2:I437) firstrow clear
ren H Obama08
ren Obama Obama12

gen General_2016 = "R" if Trump>Clinton
replace General_2016 = "D" if Trump<Clinton

gen General_2012 = "R" if Romney>Obama12
replace General_2012 = "D" if Romney<Obama12

//Florida 7th went narrowly Romney
replace General_2012 = "R" if CD == "FL-07"
ren CD district

save "$Data/General_data.dta", replace

* Disricts that swung
import delimited "$Electoral_data/flipped_seats.csv", varnames(1) clear
ren flipped district
gen flipped = "Flipped"
save "$Data/Flipped_seats.dta", replace


* create matching number and state variables for the store file
use "$Data/DS_mapped_to_dist.dta", clear
ren NAMELSAD district
replace district = subinstr(district, "Congressional District ", "",.)
drop if district == "Delegate District (at Large)" // DC isnt in the CDI data
replace district = "AL" if district == "(at Large)"
ren district number
replace number = (2-length(number))*"0" +number

* merge in city lab CDI
merge m:1 state number using "$Data/CDI.dta"
// Drop old General election variables from citylab
drop General*
// keep if _m == 3
drop _m

* merge in General results from Daily Kos
merge m:1 district using "$Data/General_data.dta"
// keep if _m == 3
drop _m

* merge in flipped data
merge m:1 district using "$Data/Flipped_seats.dta"
drop _m

* Keep only the data we want
drop fulladdress store_type stype_num store_group stgrp_num y2008 y2009 y2010 ///
y2011 y2012 y2013 y2014 y2015 y2016 y2017 y2018 year_first year_last
drop dup dup st_type loc_id store_name_l store x y CDSESSN
drop clinton16 trump16 obama12 romney12 obama08 mccain08
save "$Data/Dollar_store_master.dta", replace


use "$Data/Dollar_store_master.dta", clear

* Stores per district
gen Number_of_stores = 1
collapse (sum) Number_of_stores, by(district cluster _ID General_* Clinton Trump Obama12 Romney ALAND flipped)

* Clean names for export
label var Number "Number of Dollar Stores in District"
label var General_2016 "Election Result, 2016"
label var General_2012 "Election Result, 2012"
label var Romney "Romney Share of District Votes"
label var Trump "Trump Share of District Votes"
label var Obama "Obama Share of District Votes"
label var Clinton "Clinton Share of District Votes"

*Clasify district swings
gen District_type = "Obama-Trump" if General_2016 == "R" & General_2012 == "D"
replace District_type = "Romney-Trump" if General_2016 == "R" & General_2012 == "R"
replace District_type = "Obama-Clinton" if General_2016 == "D" & General_2012 == "D"
replace District_type = "Romney-Clinton" if General_2016 == "D" & General_2012 == "R"

* Find land area in square kilometers
gen sq_km = ALAND/1000000
label var sq_km "Square Kilometers"

sort Nu	
keep if General_2012 == "D"

* Export data
// export delimited "$Data\District_classification.csv", replace
// collapse (mean) Number_of_stores, by(cluster)
// export delimited "$Data\Mean_store_by_cluster.csv", replace

* Make map
// spmap Number_of_stores using "Districts_coor.dta", id(_ID) fcolor(Reds)

* Make boxplot Obama-Trump
// graph box Number_of_stores ///
// if District_type == "Obama-Trump" | District_type == "Obama-Clinton", ///
// by(District_type, graphregion(fcolor(white))) ///
// ylab(, nogrid)


* Make box plot of urban rural suburban
gen sort2 = 1 if cluster == "Pure urban"
replace sort2 = 2 if cluster == "Urban-suburban mix"
replace sort2 = 3 if cluster == "Dense suburban"
replace sort2 = 4 if cluster == "Sparse suburban"
replace sort2 = 5 if cluster == "Rural-suburban mix"
replace sort2 = 6 if cluster == "Pure rural"

graph box Number, over(cluster, sort(sort2)) ///
ylab(,nogrid)

* Make scatter of land area and stores
twoway scatter Number sq_km ///
msize(vsmall) ///
mcolor(forrest) ///
ylab(,nogrid)




* Make boxplot Romney-Trump
// graph box Number_of_stores ///
// if District_type == "Romney-Trump" | District_type == "Romney-Clinton", ///
// by(District_type, graphregion(fcolor(white))) ///
// ylab(, nogrid)

* Make boxplot Romney-Trump
gen sorter = 2 if District_type == "Obama-Clinton"
replace sorter = 3 if District_type == "Obama-Trump"
replace sorter = 4 if District_type == "Romney-Trump"
replace sorter = 1 if District_type == "Romney-Clinton"
replace sorter = 5 if District_type == ""

// replace District_type = flipped if flipped == "Flipped"

// keep if flipped == "Flipped"

graph box Number_of_stores, ///
over(District_type, sort(sorter)) ///
box(1, col(purple)) ///
box(2, col(medium-blue)) ///
box(3, col(purple)) ///
box(4, col(cranberry)) ///
ylab(,nogrid) 
///
(dot Number, over(District_type))

// , graphregion(fcolor(white))) ///
// ylab(, nogrid)

sort District_type Nu
br
* Scatter
// twoway scatter trump16 Number


preserve
keep if cluster == "Pure rural" |  cluster == "Rural-suburban mix"

twoway ///
(scatter Number sq_km, ///
			by(cluster, ///
			graphregion(fcolor(white))) ///
			ylab(,nogrid) ///
			mcolor(cranberry%30)) ///
(lfit Number sq_km, ///
lcolor(medium-blue)) 


restore


preserve
keep if cluster != "Pure rural" &  cluster != "Rural-suburban mix"
// NV-04 is 10x bigger than any other in its class
drop if district == "NV-04"
twoway ///
(scatter Number sq_km, ///
			by(cluster, ///
			graphregion(fcolor(white))) ///
			ylab(,nogrid) ///
			mcolor(cranberry%30)) ///
(lfit Number sq_km, ///
lcolor(blue)) 

restore


// experimental graph

egen box = cut(Number), at(0(5)200)
gen x = 0
gen y = box

sort District_type box 
egen rank = rank(_n), by(District_type box)
egen box_num = max(rank), by(District_type box)
replace x = (rank-(box_num/2))+30*sorter

twoway ///
(scatter y x if flipped != "Flipped", ///
msize(vsmall) msymbol(o) ylab(,nogrid) leg(off) ///
mcolor(purple%50) ///
xlabel(15(30)130 30 "Romney-Clinton" 60 "Obama-Clinton" 90 "Obama-Trump" 120 "Romney-Trump") ///
) ///
(scatter y x if flipped == "Flipped", ///
msize(small) msymbol(d) mcolor(orange) ylab(,nogrid) leg(off))

replace x = 2
