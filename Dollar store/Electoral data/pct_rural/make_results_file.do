* gen Fake data for BT24 auction

clear
set type double


capture mkdir "C:\Users\perez_g\Desktop\US24\Stata"

cd "C:\Users\perez_g\Desktop\US24\Stata"

capture mkdir "$root\do"
capture mkdir "$root\data"
capture mkdir "$root\raw"
capture mkdir "$root\output"

global root "C:\Users\perez_g\Desktop\US24\Stata"
gl do "$root\do"
gl data "$root\data"
gl raw "$root\raw"
gl output "$root\output"

//////////
* Make the products

* import names
import delimited "$raw\detail.csv", delimiter(comma) varnames(1) rowrange(8) clear
compress
ren (v2 pea) (geo market)
ren v9 bidding_units
ren v8 population

replace market = "PEA"+(3-length(market))*"0"+ market
	// supply
	preserve
	keep market geo v6
	gen supply = 1
	ren v6 category
	collapse (sum) supply, by( market geo category)
		tempfile supply_num
		save `supply_num'
	restore
keep  market geo bidding_units pop
duplicates drop
	
	tempfile geo
	save `geo'

* import mock
import delimited "$raw\ATT_results_round_1.csv", varnames(1) clear
tostring market, replace
replace market = "PEA"+(3-length(market))*"0"+ market
	tempfile round1
	save `round1'
drop demand
merge m:1 market using `geo'
drop _m

merge 1:1 market geo category using `supply_num'
drop _m

gen auction_id = 102
ren (market geo) (market_number market_name) 
ren ag_dem aggregate_demand
ren clock_price next_round_clock_price
gen round_opening_price = posted_price
gen round_clock_price = posted_price

// organize
order auction_id round market_nu market_na category ///
round_opening round_clock aggregate  posted_price ///
next_round_clock_price bidding_units supply pop
// export
export delimited "$output\my_product_status_round_001_gpp", replace

//////////
* Make the results
gen bidder = "Bluth Telecoms"
gen frn = 5256000000
// merge in demand
gen market = market_number
merge 1:1 market category using `round1', keepus(demand)
drop market	_m
// keep blocks that were bid
keep if demand > 0
ren demand processed_demand
gen processed_demand_flag = "Y"
gen processed_demand_detail = ""
// organize
keep auction_id round market_number market_name category ///
bidder frn processed* supply aggregate posted_price
order auction_id round market_number market_name category ///
bidder frn processed* supply aggregate posted_price
// export
export delimited "$output\my_results_round_001_gpp", replace
