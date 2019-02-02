

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

use "$Data/dollar_master_clean_new"
// merge m:1 _ID using "$Data/Events_in_dist"


// gen flag_c = 1 if General_2016 == "D"
// replace flag_c = 0 if General_2016 == "R"

// collapse (mean) flag_c, by(bin)


gen flag_un_28 = 0
replace flag_un_28 = 1 if district == "AL-04"
replace flag_un_28 = 1 if district == "AR-01"
replace flag_un_28 = 1 if district == "AR-03"
replace flag_un_28 = 1 if district == "AR-04"
replace flag_un_28 = 1 if district == "AZ-08"
replace flag_un_28 = 1 if district == "GA-01"
replace flag_un_28 = 1 if district == "GA-09"
replace flag_un_28 = 1 if district == "GA-10"
replace flag_un_28 = 1 if district == "GA-14"
replace flag_un_28 = 1 if district == "IL-15"
replace flag_un_28 = 1 if district == "IL-16"
replace flag_un_28 = 1 if district == "KS-01"
replace flag_un_28 = 1 if district == "KY-02"
replace flag_un_28 = 1 if district == "KY-05"
replace flag_un_28 = 1 if district == "LA-05"
replace flag_un_28 = 1 if district == "NE-03"
replace flag_un_28 = 1 if district == "OK-01"
replace flag_un_28 = 1 if district == "PA-03"
replace flag_un_28 = 1 if district == "PA-18"
replace flag_un_28 = 1 if district == "TX-04"
replace flag_un_28 = 1 if district == "TX-05"
replace flag_un_28 = 1 if district == "TX-08"
replace flag_un_28 = 1 if district == "TX-11"
replace flag_un_28 = 1 if district == "TX-13"
replace flag_un_28 = 1 if district == "TX-19"
replace flag_un_28 = 1 if district == "TX-32"
replace flag_un_28 = 1 if district == "TX-36"


* christmas tree plot of district type and store
// highlighting the uncontested districts

// egen box = cut(Number), at(0(3)170)
// gen x = 0
// gen y = box

// sort District_type box 
// egen rank = rank(_n), by(District_type box )
// egen box_num = max(rank), by(District_type box )
// egen group1 = group(District_type)
// replace x = (rank-(box_num/2))+15*group1

// twoway ///
// (scatter y x if flag_un_28 == 1, ///
// msize(small) msymbol(o) ylab(,nogrid) leg(off) ///
// mcolor(lavender%50) ///
// xlabel(15 "Obama-Clinton" 30 "" 45 "30-45" 60 "45-60", tlength(0)) ///
// xtitle(Number of Stores in District, size(small) margin(small)) ///
// ylabel( -10 "-10" 0 "0" 10 "10" 20 "20" 30 "30") /// 
// ytitle("Swing R to D, 2016-2018 (pts)", size(small) margin(small)) ///
// yline(0, lcolor(gray%30)) /// 
// graphregion(color(white)) ///
// ) ///
// (scatter y x if flag_un_28 == 0, ///
// msize(small) msymbol(o) mcolor(grey%50) ylab(,nogrid) leg(off))



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
(scatter y x if flag_un_28 == 1, ///
msize(med) msymbol(d) ylab(,nogrid) leg(off) ///
mcolor(orange) ///
xlabel( 10 " " 25 "Romney-Clinton" 50 "Obama-Clinton" 75 "Obama-Trump" 100 "Romney-Trump", tlength(0)) ///
ytitle("Stores per District, 2018", size(msmall) margin(small)) ///
graphregion(color(white)) ///
) ///
(scatter y x if flag_un_28 == 0, ///
msize(vsmall) msymbol(o) mcolor(lavender%35) ylab(,nogrid) leg(off))
