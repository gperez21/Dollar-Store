clear
set type double
cd "/Users/lep12/Desktop/Dollar-Store/Dollar store/Stata/Programs"

gl root "/Users/lep12/Desktop/Dollar-Store/Dollar store"
gl GIS "$root/GIS"
gl Stata "$root/Stata"
gl Data "$Stata/Data"
gl Dollar_data "$root/Dollar store data"
gl Electoral_data "$root/Electoral data"
gl Citylab_data "$root/City lab data"


use "$Data/dollar_master_clean", clear

dotplot EducationIndex, over(cluster sort(order3)) ///
graphregion(color(white)) ///
center ///
msize(vsmall)

twoway (scatter Trump Nu , ///
mcolor(lavender%50) ///
msize(vsmall)) ///
(scatter Romney Nu , ///
mcolor(green%50) ///
msize(vsmall) ///
graphregion(color(white)) ///
ylab(,nogrid)) ///
(lfit Trump Nu , lcolor(lavender)) ///
(lfit Romney Nu , lcolor(green))

gen _12 = 100 - Obama12 - Romney
gen _16 = 100 - Trump - Clinton
sum _12, det
sum _16, det

///////////////////////////////////////////////////////////////////////////////
*Xmas tree by pres swing 2016-2018 
use "$Data/dollar_master_clean_new", clear


drop if district == "AK-AL" | district == "HI-02"  | district == "HI-01" 
drop if strpos(district,"PA")


egen box = cut(Nu), at(0(5)170)
gen x = 0
gen y = box

sort District_type box 
egen rank = rank(_n), by(District_type box )
egen box_num = max(rank), by(District_type  box )
egen group1 = group(sorter)
replace x = (rank*.85-(box_num/2))+25*group1

twoway ///
(scatter y x if map2016 == 1, ///
msize(vsmall) msymbol(o) ylab(,nogrid) leg(off) ///
mcolor(midblue%50) ///
xlabel( 10 " " 25 "Romney-Clinton" 50 "Obama-Clinton" 75 "Obama-Trump" 100 "Romney-Trump", tlength(0)) ///
xtitle(Number of Stores in District, size(small) margin(small)) ///
ytitle("Stores per District, 2018", size(msmall) margin(small)) ///
graphregion(color(white)) ///
) ///
(scatter y x if map2016 == 2, ///
msize(vsmall) msymbol(o) mcolor(cranberry%50) ylab(,nogrid) leg(off))

//////////////////////////
use "$Data/dollar_master_clean_new", clear


gen share_change = Trump - Romney
twoway scatter share_change Nu

dotplot EducationIndex, over(cluster sort(order3)) ///
graphregion(color(white)) ///
center ///
msize(vsmall)

twoway (scatter Trump Nu , ///
mcolor(lavender%50) ///
msize(vsmall)) ///
(scatter Romney Nu , ///
mcolor(green%50) ///
msize(vsmall) ///
graphregion(color(white)) ///
ylab(,nogrid)) ///
(lfit Trump Nu , lcolor(lavender)) ///
(lfit Romney Nu , lcolor(green))

gen _12 = 100 - Obama12 - Romney
gen _16 = 100 - Trump - Clinton
sum _12, det
sum _16, det

// AddGIni

//////////////////////////
use "$Data/dollar_master_clean_new", clear


import delimited "$Citylab_data/lara_city_lab.csv", varnames(1) clear
save "$Data/city_lab_gini", replace

use "$Data/dollar_master_clean", clear
merge 1:1 district using "$Data/city_lab_gini"

drop if district == "AK-AL" | district == "HI-02"  | district == "HI-01" 

egen box = cut(Nu), at(0(3)170)
gen x = 0
gen y = box

sort District_type box 
egen rank = rank(_n), by(District_type box )
egen box_num = max(rank), by(District_type  box )
egen group1 = group(sorter)
replace x = (rank-(box_num/2))+15*group1

twoway ///
(scatter y x if party == "D", ///
msize(vsmall) msymbol(o) ylab(,nogrid) leg(off) ///
mcolor(midblue%50) ///
xlabel(7.5 " " 15 "Romney-Clinton" 30 "Obama-Clinton" 45 "Obama-Trump" 60 "Romney-Trump", tlength(0)) ///
xtitle(Number of Stores in District, size(small) margin(small)) ///
ytitle("Stores per District, 2018", size(msmall) margin(small)) ///
graphregion(color(white)) ///
) ///
(scatter y x if party == "R", ///
msize(vsmall) msymbol(o) mcolor(cranberry%50) ylab(,nogrid) leg(off))


twoway scatter gini Nu, ///
msize(vsmall) ///
mcolor(orange%50) ///
graphregion(color(white)) ///
ylab(,nogrid) ///
ytitle("District Gini Coefficient")

collapse (sd) gini, by(cluster)

//////////////////////////
use "$Data/dollar_master_clean_new", clear


gen share_change = Trump - Romney
twoway scatter share_change Nu if !strpos(district,"PA"), ///
msize(vsmall) ///
mcolor(lavender%50) ///
yline(0) ///
graphregion(color(white)) ///
ylab(,nogrid) ///
ytitle("Change in Vote Share Romney to Trump")


//////////////////////////
use "$Data/dollar_master_clean_new", clear
merge 1:1 district using "$Data/city_lab_gini"
preserve
replace cluster = bin
tempfile data
save `data'
restore
append using `data'
collapse (sd) HDIndex HealthIndex EducationIndex IncomeIndex gini life_ pct_100 pct_185, by(cluster)

///////////////////////////////////////////////////////////////////////////////
*Xmas tree by pres swing 2016-2018 with swings
use "$Data/dollar_master_clean_new", clear


drop if district == "AK-AL" | district == "HI-02"  | district == "HI-01" 
drop if strpos(district,"PA")


egen box = cut(Nu), at(0(5)170)
gen x = 0
gen y = box

sort District_type box 
egen rank = rank(_n), by(District_type box )
egen box_num = max(rank), by(District_type  box )
egen group1 = group(sorter)
replace x = (rank*.85-(box_num/2))+25*group1

twoway ///
(scatter y x if flipped == "", ///
msize(vsmall) msymbol(s) ylab(,nogrid) leg(off) ///
mcolor(orange%50) ///
xlabel( 10 " " 25 "Romney-Clinton" 50 "Obama-Clinton" 75 "Obama-Trump" 100 "Romney-Trump", tlength(0)) ///
xtitle(Number of Stores in District, size(small) margin(small)) ///
ytitle("Stores per District, 2018", size(msmall) margin(small)) ///
graphregion(color(white)) ///
) ///
(scatter y x if flipped == "Flipped-D", ///
msize(vsmall) msymbol(D) mcolor(purple%75) ylab(,nogrid) leg(off)) ///
(scatter y x if flipped == "Flipped-R", ///
msize(vsmall) msymbol(D) mcolor(green%75) ylab(,nogrid) leg(off))

///////////////////////////////////////////////////////////////////////////////
*Xmas tree by pres swing 2016-2018 with swings
use "$Data/dollar_master_clean_new", clear


drop if district == "AK-AL" | district == "HI-02"  | district == "HI-01" 
drop if strpos(district,"PA")


egen box = cut(Nu), at(0(5)170)
gen x = 0
gen y = box

sort District_type box 
egen rank = rank(_n), by(District_type box )
egen box_num = max(rank), by(District_type  box )
egen group1 = group(sorter)
replace x = (rank*.85-(box_num/2))+25*group1

twoway ///
(scatter y x if flipped == "" & map2016 == 1, ///
msize(vsmall) msymbol(s) ylab(,nogrid) leg(off) ///
mcolor(midblue%50) ///
xlabel( 10 " " 25 "Romney-Clinton" 50 "Obama-Clinton" 75 "Obama-Trump" 100 "Romney-Trump", tlength(0)) ///
xtitle(Number of Stores in District, size(small) margin(small)) ///
ytitle("Stores per District, 2018", size(msmall) margin(small)) ///
graphregion(color(white)) ///
) ///
(scatter y x if flipped == "" & map2016 == 2, ///
msize(vsmall) msymbol(s) mcolor(cranberry%50) ylab(,nogrid) leg(off)) ///
(scatter y x if flipped == "Flipped-D", ///
msize(vsmall) msymbol(D) mcolor(purple%75) ylab(,nogrid) leg(off)) ///
(scatter y x if flipped == "Flipped-R", ///
msize(vsmall) msymbol(D) mcolor(orange%75) ylab(,nogrid) leg(off))

///////////////////////////////////////////////////////////////////////////////
*congressional swing
use "$Data/dollar_master_clean_new", clear


drop if district == "AK-AL" | district == "HI-02"  | district == "HI-01" 
drop if strpos(district,"PA")

scatter pct2016repub Nu if unc2016 == "", ///
msize(small) ///
mcolor(orange%50) ///
graphregion(color(white))

scatter pct2018rep Nu if unc2018 == "", ///
msize(small) ///
mcolor(sand%50) ///
graphregion(color(white)) ///
ytitle("Republican Share 2018")

gen share_change = pct2018rep - pct2016repub if unc2016 == "" & unc2018 == ""

scatter share_change Nu if unc2018 == "", ///
msize(small) ///
mstyle(D) ///
mcolor(teal%50) ///
graphregion(color(white)) ///
ytitle("Republican Congressionl Swing 2016 to 2018")

