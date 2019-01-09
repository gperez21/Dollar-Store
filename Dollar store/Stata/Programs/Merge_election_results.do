
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

* merge in life expectancy
preserve 
do import_life_expectancy
restore
merge m:1 district using "$Data\District_LE"
drop _m

*merge in poverty line data
preserve
do Poverty_line
restore
merge m:1 district using "$Data\poverty.dta"
drop _m

*merge HDI and other index data
merge m:1 district using "$Data\district_HDI"
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
pct2016republican unc2016 pct2018rep pct2018dem unc2018 life_expectancy ///
pct_100 pct_185  HDIndex HealthIndex EducationIndex IncomeIndex)

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
replace band = "From 30 to 60" if Nu >= 30 & Nu <= 60
replace band = "Greater than 60" if Nu > 60
gen sorter2 = 1 if band == "Fewer than 30"
replace sorter2 = 2 if band == "From 30 to 60"
replace sorter2 = 3 if band == "Greater than 60"


// bins of 15
gen bin = "0-15" if Nu < 15
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
gen map2016 = 1 if  pct2016dem > pct2016rep // band == "From 30 to 60"
replace map2016 = 2 if pct2016dem < pct2016rep // band == "From 30 to 60"

replace pct2018dem = 0 if pct2018dem ==.
replace pct2018rep = 0 if pct2018rep ==.
gen map2018 = 1 if  pct2018dem > pct2018rep // band == "From 30 to 60"
replace map2018 = 2 if pct2018dem < pct2018rep // band == "From 30 to 60"

gen mapbins = 1 if bin == "30-45"  | bin == "15-30" | bin ==  "60-75"
replace mapbins = 2 if bin == "45-60"

* find quitiles for store numbers
egen store_quintile = xtile(Nu), nq(5)

gen order3 = 1 if cluster == "Pure urban"
replace order3 = 2 if cluster == "Urban-suburban mix"
replace order3 = 3 if cluster == "Dense suburban"
replace order3 = 4 if cluster == "Sparse suburban"
replace order3 = 5 if cluster == "Rural-suburban mix"
replace order3 = 6 if cluster == "Pure rural"

save "$Data\dollar_master_clean", replace 

///////////////////////////////////////////////////////////////////////////////
* Make tables
dotplot IncomeIndex, over(order3) center ///
xlab( 1 "Pure urban" 2  "Urban-suburban mix" 3  "Dense suburban" ///
4 "Sparse suburban" 5 "Rural-suburban mix" 6 "Pure rural") ///
msize(vsmall) ///
msymbol(d)



///////////////////////////////////////////////////////////////////////////////
* Make graphs

dotplot Nu, over(order3) center


twoway scatter life_expectancy Nu, ///
graphregion(color(white)) ///
ylab(,nogrid tlength(0) ) ///
mstyle(o) ///
msize(small) ///
mcolor(teal%60) ///
xlab(,tlength(0))



dotplot life_expectancy, over(cluster) median center

regress diff_2016 life_expectancy pct_185 

* make plots

graph dot Median_swing, ///
over(band) ///
nofill vertical ///
graphregion(color(white))
//
graph dot ig map

dotplot swing_2018 , over(store_quintile) center median msize(small)

graph box Nu , over(Rep_swingxtile) 
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


///////////////////////////////////////////////////////////////////////////////
* experimental graphs

* experimental crhistmas tree graph

egen box = cut(Number), at(0(5)200)
gen x = 0
gen y = box

sort cluster box 
egen rank = rank(_n), by(cluster box)
egen box_num = max(rank), by(cluster box)
replace x = (rank-(box_num/2))+30*order3

twoway ///
(scatter y x if flipped != "Flipped", ///
msize(vsmall) msymbol(o) ylab(,nogrid) leg(off) ///
mcolor(purple%50) ///
) ///
(scatter y x if flipped == "Flipped", ///
msize(small) msymbol(d) mcolor(orange) ylab(,nogrid) leg(off))

replace x = 2



* Swing by Store quintile

egen box = cut(swing_2018), at(-.2(.01).4)
gen x = 0
gen y = box

sort store_quintile box 
egen rank = rank(_n), by(store_quintile box )
egen box_num = max(rank), by(store_quintile box )
replace x = (rank-(box_num/2))+15*store_quintile

twoway ///
(scatter y x if map2016 == 1, ///
msize(small) msymbol(o) ylab(,nogrid) leg(off) ///
mcolor(midblue%50) ///
xlabel(7.5(15)80 15 "1st" 30 "2nd" 45 "3rd" 60 "4th" 75 "5th") ///
graphregion(color(white)) ///
) ///
(scatter y x if map2016 == 2, ///
msize(small) msymbol(o) mcolor(cranberry%50) ylab(,nogrid) leg(off))

* Experimental arrow graph
gen x1 = diff_2016
gen x2 = diff_2018
gen y1 = Number

twoway pcarrow y1 x1 y1 x2 if map2016 == 2, ///
msize(tiny) mcolor(cranberry%50) lcolor(cranberry%50) ///
ylab(,nogrid) graphregion(color(white))


 