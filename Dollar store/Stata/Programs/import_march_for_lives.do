
fire break
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

*import march for our lives
import delimited "$Electoral_data/march_for_our_lives", varnames(1) 
drop if _n >822
drop if missing(country)
ren city city
ren state state
ren country country
gen full_address = city + ", " + state+ ", " +country

// opencagegeo, key(e4c5a22b9a9540e880b666c332b7351f) fulladdress(full_address)

gen protest = "MFoL"

save "$Data/march_for_our_lives", replace

* import families belong
import delimited "$Electoral_data/families_belong_tog", varnames(1) clear
drop if _n >739
drop if missing(country)
ren city city
ren state state
ren country country
compress
gen full_address = city + ", " + state+ ", " +country
gen protest = "FBT"

// opencagegeo, key(e4c5a22b9a9540e880b666c332b7351f) fulladdress(full_address)

save "$Data/families_belong_tog", replace

use "$Data/families_belong_tog", clear




*import march for our lives 2
import delimited "$Electoral_data/student_walk_out", varnames(1) clear
drop if _n == 1
drop if _n >1177
drop if missing(country)
ren city city
ren state state
ren country country
gen full_address = city + ", " + state+ ", " +country
compress

// opencagegeo, key(e4c5a22b9a9540e880b666c332b7351f) fulladdress(full_address)

gen protest = "student_walk_out"

save "$Data/student_walk_out", replace


