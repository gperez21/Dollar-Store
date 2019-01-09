
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

// Use master data set
use "$Data\dollar_master_clean", clear

// create numerical vars for categorical ones
replace swing_2018 = swing_2018*100
egen group1 = group(bin)

// keep relevant
keep swing_2018 cluster bin Nu life_expectancy pct_100 pct_185 HDIndex HealthIndex EducationIndex IncomeIndex Number_of_stores district

// Drop 3 non lower 48
keep if district != "AK-AL" & district != "HI-01" & district != "HI-02"

// find standard deviation chopping up by different division
preserve
collapse (sd) life_expectancy pct_100 pct_185 HDIndex HealthIndex EducationIndex IncomeIndex (count) Nu, by(cluster)
ren cluster division
tempfile cluster_
save `cluster_'
restore

collapse (sd) life_expectancy pct_100 pct_185 HDIndex HealthIndex EducationIndex IncomeIndex (count) Nu, by(bin)
ren bin division
append using `cluster_'

drop Nu

levelsof division, local(divisions)
di `divisions'

// transpose
xpose , clear varname 
drop if _varname == "division"

ren (v1 v2 v3 v4 v5 v6 v7 v8 v9 v10 v11 v12) (_15 _30 _45 _60 _75 _plus ///
Dense_suburban Pure_rural Pure_urban Rural_suburban_mix Sparse_suburban ///
Urban_suburban_mix)

gl bins _15 _30 _45 _60 _75 _plus 
gl cluster Dense_suburban Pure_rural Pure_urban ///
Rural_suburban_mix Sparse_suburban Urban_suburban_mix

gen num = _n

twoway (scatter $bins num ,  mcolor(purple))

 ///
(scatter $cluster num,  mcolor(orange))

