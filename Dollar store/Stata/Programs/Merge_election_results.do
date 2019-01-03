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

//Florida 7th went narrowly Obama
replace General_2012 = "D" if CD == "FL-07"
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

* merge in 2016 congressional results
preserve
do import_2016_congressional
restore
merge m:1 district using "$Data\2016_results" 
drop _m

* merge in 2018 congressional results
preserve
do import_2018_congressional
restore
merge m:1 district using "$Data\2018_results" 
drop _m


* Keep only the data we want
drop fulladdress store_type stype_num store_group stgrp_num y2008 y2009 y2010 ///
y2011 y2012 y2013 y2014 y2015 y2016 y2017 y2018 year_first year_last
drop dup dup st_type loc_id store_name_l store x y CDSESSN
drop clinton16 trump16 obama12 romney12 obama08 mccain08
save "$Data/Dollar_store_master.dta", replace
compress



use "$Data/Dollar_store_master.dta", clear

* Stores per district
gen Number_of_stores = 1
collapse (sum) Number_of_stores, by(district cluster _ID General_* Clinton ///
Trump Obama12 Romney ALAND flipped cong* pct2016democrat pct2016other ///
pct2016republican unc2016 pct2018rep pct2018dem unc2018)

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

* Make boxplot by flip clasification
gen sorter = 2 if District_type == "Obama-Clinton"
replace sorter = 3 if District_type == "Obama-Trump"
replace sorter = 4 if District_type == "Romney-Trump"
replace sorter = 1 if District_type == "Romney-Clinton"

* Find difference between rep and dem pct in 2016 & 2018
gen diff_2016 = pct2016dem - pct2016rep
gen diff_2018 = pct2018dem - pct2018rep
gen swing_2018 = diff_2018 - diff_2016
//dont include PA districts or those uncontested in either election
replace swing_2018 =. if unc2016 != "" | unc2016 != ""
replace swing_2018 =. if strpos(district, "PA")


// bands around 30-69
gen band = "Fewer than 30" if Nu < 30 
replace band = "From 30 to 60" if Nu >= 30 & Nu < 60
replace band = "Greater than 60" if Nu > 60
gen sorter2 = 1 if band == "Fewer than 30"
replace sorter2 = 2 if band == "From 30 to 60"
replace sorter2 = 3 if band == "Greater than 60"


// bins of 15
gen bin = "0-15" if Nu < 16
replace bin = "15-30" if Nu >= 15 & Nu < 30
replace bin = "30-45" if Nu >= 30 & Nu < 45
replace bin = "45-60" if Nu >= 45 & Nu < 60
replace bin = "60-75" if Nu >= 60 & Nu < 75
replace bin = "75+" if Nu >= 75

//find quitiles for store numbers
egen swingxtile = xtile(swing_2018), nq(5)
egen Median_swing = median(swing_2018 ), by(band)
replace Median_swing = Median_swing*100
label var Median_swing "Median Swing 2016-2018"


* find seats held after each midterm
order pct2016democrat pct2016other pct2016republican unc2016 pct2018dem pct2018rep unc2018, last
replace pct2016dem = 0 if pct2016dem ==.
replace pct2016rep = 0 if pct2016rep ==.
gen map2016 = 1 if  pct2016dem > pct2016rep //& band == "From 30 to 60"
replace map2016 = 2 if pct2016dem < pct2016rep //& band == "From 30 to 60"

replace pct2018dem = 0 if pct2018dem ==.
replace pct2018rep = 0 if pct2018rep ==.
gen map2018 = 1 if  pct2018dem > pct2018rep //& band == "From 30 to 60"
replace map2018 = 2 if pct2018dem < pct2018rep //& band == "From 30 to 60"

gen mapbins = 1 if bin == "30-45"  | bin == "15-30" | bin ==  "60-75"
replace mapbins = 2 if bin == "45-60"


* make plots

graph dot Median_swing, ///
over(band) ///
nofill vertical ///
graphregion(color(white))
//
graph dot ig map

dotplot Nu if map2016 == 2, over(swingxtile) center median msize(small)

//
// ///
// over(band, sort(sorter2)) ///
// nofill vertical ///
// graphregion(color(white))

dotplot swing, over(bin) ///
center ///
msize(small) ///
graphregion(color(white))


* Make PA map
spmap mapbins using "$Data\Districts_coor.dta", id(_ID) fcolor(Blues) 

///
clmethod(custom) clbreaks(1 3 5 7 9 12) ///
legend(symy(*2) symx(*2) size(*2) position (4)) 


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
