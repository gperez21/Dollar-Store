
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


use "$Data\dollar_master_clean", clear

////////////////////////////////////////////////////////////////////////////////
* christmas tree plot of tranches and swings
replace swing_2018 = swing_2018*100

egen box = cut(swing_2018), at(-20(1)40)
gen x = 0
gen y = box

sort bin box 
egen rank = rank(_n), by(bin box )
egen box_num = max(rank), by(bin box )
egen group1 = group(bin)
replace x = (rank-(box_num/2))+15*group1

twoway ///
(scatter y x if map2016 == 1, ///
msize(small) msymbol(o) ylab(,nogrid) leg(off) ///
mcolor(midblue%50) ///
xlabel(15 "0-15" 30 "15-30" 45 "30-45" 60 "45-60" 75 "60-75" 90 "75+", tlength(0)) ///
xtitle(Number of Stores in District, size(small) margin(small)) ///
ylabel( -10 "-10" 0 "0" 10 "10" 20 "20" 30 "30") /// 
ytitle("Swing R to D, 2016-2018 (pts)", size(small) margin(small)) ///
yline(0, lcolor(gray%30)) /// 
graphregion(color(white)) ///
) ///
(scatter y x if map2016 == 2, ///
msize(small) msymbol(o) mcolor(cranberry%50) ylab(,nogrid) leg(off))

////////////////////////////////////////////////////////////////////////////////
* christmas tree plot of tranches and swings
use "$Data\dollar_master_clean", clear

replace swing_2018 = swing_2018*100
egen median_2018 = median(swing_2018), by(bin)

graph dot median_2018, ///
over(bin) ///
vertical 

 
twoway ///
(scatter y x if map2016 == 1, ///
msize(small) msymbol(o) ylab(,nogrid) leg(off) ///
mcolor(midblue%50) ///
xlabel(15 "0-15" 30 "15-30" 45 "30-45" 60 "45-60" 75 "60-75" 90 "75+", tlength(0)) ///
xtitle(Number of Stores in District, size(small) margin(small)) ///
ylabel( -10 "-10" 0 "0" 10 "10" 20 "20" 30 "30") /// 
ytitle("Swing R to D, 2016-2018 (pts)", size(small) margin(small)) ///
yline(0, lcolor(gray%30)) /// 
graphregion(color(white)) ///
) ///
(scatter y x if map2016 == 2, ///
msize(small) msymbol(o) mcolor(cranberry%50) ylab(,nogrid) leg(off))



///////////////////////////////////////////////////////////////////////////////
* arrow graph of sparse suburban
use "$Data\dollar_master_clean", clear

keep if cluster == "Rural-suburban mix"
gen x1 = diff_2016
gen x2 = diff_2018
gen y1 = Number

twoway (pcarrow y1 x1 y1 x2 if map2016 == 2, ///
msize(tiny) mcolor(cranberry%50) lcolor(cranberry%50) ///
ylab(,nogrid) ///
graphregion(color(white))) ///
(pcarrow y1 x1 y1 x2 if map2016 == 1, ///
msize(tiny) mcolor(midblue%50) lcolor(midblue%50) ///
)

///////////////////////////////////////////////////////////////////////////////
* map of bins

spmap group1 using "$Data\Districts_coor.dta", id(_ID) fcolor(Reds) ///
clmethod(custom) clbreaks(0 1.1 2.1 3.1 4.1 5.1 6.1) ///
legend(symy(*2) symx(*2) size(*2) position (4)) 

///////////////////////////////////////////////////////////////////////////////
* income index dot plot
use "$Data\dollar_master_clean", clear

// drop if district == "AK-AL" | district == "HI-02"  | district == "HI-01" 

egen box = cut(IncomeIndex), at(0(.25)10)
gen x = 0
gen y = box

sort bin box 
egen rank = rank(_n), by(bin box )
egen box_num = max(rank), by(bin box )
egen group1 = group(bin)
replace x = (rank-(box_num/2))+15*group1

twoway ///
(scatter y x if map2016 == 1, ///
msize(small) msymbol(o) ylab(,nogrid) leg(off) ///
mcolor(midblue%50) ///
xlabel(15 "0-15" 30 "15-30" 45 "30-45" 60 "45-60" 75 "60-75" 90 "75+", tlength(0)) ///
xtitle(Number of Stores in District, size(small) margin(small)) ///
ytitle("SSRC Income Index", size(msmall) margin(small)) ///
graphregion(color(white)) ///
) ///
(scatter y x if map2016 == 2, ///
msize(small) msymbol(o) mcolor(cranberry%50) ylab(,nogrid) leg(off))

///////////////////////////////////////////////////////////////////////////////
* income index dot plot
use "$Data\dollar_master_clean", clear

egen box = cut(EducationIndex), at(0(.25)10)
gen x = 0
gen y = box

sort bin box 
egen rank = rank(_n), by(bin box )
egen box_num = max(rank), by(bin box )
egen group1 = group(bin)
replace x = (rank-(box_num/2))+15*group1

twoway ///
(scatter y x if map2016 == 1, ///
msize(small) msymbol(o) ylab(,nogrid) leg(off) ///
mcolor(midblue%50) ///
xlabel(15 "0-15" 30 "15-30" 45 "30-45" 60 "45-60" 75 "60-75" 90 "75+", tlength(0)) ///
xtitle(Number of Stores in District, size(small) margin(small)) ///
ylabel( 10 "Max" ) /// 
ytitle("SSRC Education Index", size(msmall) margin(small)) ///
graphregion(color(white)) ///
) ///
(scatter y x if map2016 == 2, ///
msize(small) msymbol(o) mcolor(cranberry%50) ylab(,nogrid) leg(off))

///////////////////////////////////////////////////////////////////////////////
* income index dot plot
use "$Data\dollar_master_clean", clear

gen x = 0
gen y = 0

egen box = group(cluster)
egen group1 = group(bin)

twoway scatter box group1 , jitter(10) msize(vsmall)


// set up x
sort bin box 
egen rank = rank(_n), by(bin box)
egen box_num = max(rank), by(bin box)
replace x = (rank-(box_num/2))+15*group1

sort box group1

//set up y
// sort cluster group1 
// egen rank2 = rank(_n), by(cluster group1)
// egen box_num2 = max(rank), by(cluster group1 )
// replace y = (rank2-(box_num2/2))+15*box
replace y = box*15

twoway ///
(scatter y x if map2016 == 1, ///
msize(small) msymbol(o) ylab(,nogrid) leg(off) ///
mcolor(midblue%50) ///
xlabel(15 "0-15" 30 "15-30" 45 "30-45" 60 "45-60" 75 "60-75" 90 "75+", tlength(0)) ///
xtitle(Number of Stores in District, size(small) margin(small)) ///
ylabel( 10 "Max" ) /// 
ytitle("", size(msmall) margin(small)) ///
graphregion(color(white)) ///
) ///
(scatter y x if map2016 == 2, ///
msize(small) msymbol(o) mcolor(cranberry%50) ylab(,nogrid) leg(off))

