cd "/Users/zhaozhan/GitHub/CDC_places_county_health_portfolio/01 Data"

use "./processed/places_2025_county01.dta",clear
/* The Excel Portfolio: */
snapshot save

centile data_value , centile (80)
*Report centile and confidence interval

g flag =1 if data_value>34.8
replace flag = 0 if flag == .

keep if data_value_type == "Age-adjusted prevalence"


levelsof measureid, local(healthbr)

foreach x in `healthbr' {
	preserve
	putexcel set "../02 Output/FAB_file.xlsx", sheet("Behaviors `x'")modify
	keep if measureid == "`x'"
	
	gsort -data_value
	gen rank = _n
	keep if rank<=20
	
	graph hbar (mean) data_value, ///
	over(counties,sort(data_value) descending label(labsize(vsmall))) ///
	name(bar_`x',replace) ///
	title("`x'") ///
	ytitle("Mean prevalence(%)")
	graph export "../02 Output/bar_`x'.png",replace
	putexcel B3 =image("../02 Output/bar_`x'.png")
	restore
}


/* Health Outcomes */

snapshot restore 1

keep if data_value_type == "Age-adjusted prevalence"

tempfile top20_all
save `top20_all', emptyok replace

levelsof measureid, local(healthot)

foreach y in `healthot' {
	preserve
	
		keep if measureid == "`y'"
		
		gsort -data_value
		gen risk_rank = _n
		keep if risk_rank <=20
		
		append using `top20_all'
		save `top20_all',replace
		
	restore		
}

use `top20_all',clear

*identify counties appearing more than one among top 20 risk behavior lists

bysort counties: gen repeat_count = _N
keep if repeat_count >1

sort counties measureid

order counties locationname stateabbr measureid measure data_value risk_rank repeat_count

save "./processed/repeated_top20_risk_counties.dta", replace

/*---------------------*/
/*the top 5 health outcomes(e.g.,Diabetes, COPD, Obesity, Depression, etc.) of each county */

tab counties, sort
