
clear
set type double
cd "C:\Users\perez_g\Desktop\Data_vis_wa\data_vis_wa\Dollar store\Stata\Programs"

gl root "C:\Users\perez_g\Desktop\Data_vis_wa\data_vis_wa\Dollar store"
gl Dollar_data "$root\Dollar store data"
gl GIS "$root/GIS"
gl Stata "$root/Stata"
gl Data "$Stata/Data"
gl Dollar_data "$root/Dollar store data"
gl Electoral_data "$root/Electoral data"
gl Citylab_data "$root/City lab data"
gl Rural "$Electoral_data/pct_rural"
//////////////////////////
* import rural pct
save "$Data/pct_rural_cd", emptyok replace
gl states "NY" "OH" "MO" "TX" "PA" "NC"
foreach x in "$states"{
di "`x'"
import delimited "$Rural/ur_cd_delim_`x'", varnames(1) clear
append using "$Data/pct_rural_cd"
save "$Data/pct_rural_cd", replace
}
// make fip string to match
tostring (ïstate congressionaldistrict), replace
replace congre = "0"+congre if length(congre) == 1
gen congressionaldistrictid = ïstate + congressionaldistrict
	tempfile rural
	save `rural'
use "$Data/dollar_master_clean_new", clear
merge 1:1 congressionaldistrictid using `rural'
keep if _m == 3
sort district
gen state = substr(district,1,2)
gen Trump_margin = Trump - Clinton 
replace Trump_margin = -2 if congressionaldistrictid == "4201"
replace Trump_margin = -48 if congressionaldistrictid == "4202"
replace Trump_margin = -84 if congressionaldistrictid == "4203"
replace Trump_margin = -19 if congressionaldistrictid == "4204"
replace Trump_margin = -28 if congressionaldistrictid == "4205"
replace Trump_margin = -9 if congressionaldistrictid == "4206"
replace Trump_margin = -1 if congressionaldistrictid == "4207"
replace Trump_margin = 10 if congressionaldistrictid == "4208"
replace Trump_margin = 34 if congressionaldistrictid == "4209"
replace Trump_margin = 9 if congressionaldistrictid == "4210" 
replace Trump_margin = 26 if congressionaldistrictid == "4211"
replace Trump_margin = 36 if congressionaldistrictid == "4212"
replace Trump_margin = 46  if congressionaldistrictid == "4213"
replace Trump_margin = 29 if congressionaldistrictid == "4214"
replace Trump_margin = 43 if congressionaldistrictid == "4215"
replace Trump_margin = 20 if congressionaldistrictid == "4216"
replace Trump_margin = 3 if congressionaldistrictid == "4217" 
replace Trump_margin = -27 if congressionaldistrictid == "4218" 

gen pct_rural = 100*ruralpop/totalpop
label var pct_rural "Pct of Population Rural"
label var Trump_margin "Trump Margin of Victory"
twoway (scatter pct_rural Trump_margin, by(state)) 

twoway scatter Trump_margin pct_rural , ///
graphregion(color(white)) ///
ylab(,nogrid) ///
msymbol(o) ///
msize(msmall) ///
mcolor(lavender%80)

twoway scatter Trump_margin Nu, ///
graphregion(color(white)) ///
ylab(,nogrid) ///
msymbol(o) ///
msize(msmall) ///
mcolor(orange%80)

twoway scatter Trump_margin pct_rural , by(state) ///
graphregion(color(white)) ///
ylab(,nogrid) ///
msymbol(o) ///
msize(msmall) ///
mcolor(lavender%80)

twoway scatter Trump_margin Nu, by(state) ///
graphregion(color(white)) ///
ylab(,nogrid) ///
msymbol(o) ///
msize(msmall) ///
mcolor(orange%80)



(scatter Nu Trump, by(state))
// drop if state == "PA"













regress Nu swing_2018 if state == "OH"
regress Nu swing_2018 if state == "NY"
regress Nu swing_2018 if state == "TX"
regress Nu swing_2018 if state == "NC"
regress Nu swing_2018 if state == "MO"
regress pct_rural swing_2018 if state == "OH"
regress pct_rural swing_2018 if state == "NY"
regress pct_rural swing_2018 if state == "TX"
regress pct_rural swing_2018 if state == "MO"
regress pct_rural swing_2018 if state == "NC"

twoway scatter swing_2018 Nu if state != "NY"

regress life pct_rural
regress life Nu

regress HDI pct_rural
regress HDI Nu
twoway (scatter life_expect pct_rural) ///
(scatter life_expect Nu) 
