capture restore
capture erase "$output/FAB_file.xlsx"

cd "/Users/zhaozhan/GitHub/CDC_places_county_health_portfolio/01 Data"

global project "/Users/zhaozhan/GitHub/CDC_places_county_health_portfolio"
global raw "$project/01 Data/raw"
global processed "$project/01 Data/processed"
global output "$project/02 Output"

use "$processed/places_2025_county01.dta",clear
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
	graph export "$output/bar_`x'.png",replace
	putexcel B3 =image("$output/bar_`x'.png")
	restore
}


/* Health Outcomes */
/*----------------------*/
/* The dataset is now ready for the next step: creating the Excel Portfolio 3. */

use "$processed/places_2025_county01.dta",clear
preserve
	keep if data_value_type == "Age-adjusted prevalence"

	gsort measureid -data_value 
	by measureid: gen rank = _n
	keep if rank <= 20


	bysort counties: gen repeated_count = _N
	drop if repeated_count == 1
	
	duplicates drop counties, force

	tempfile selected_counties
	save `selected_counties', replace
restore

use "$processed/places_2025_county.dta",clear
egen counties = concat(locationname stateabbr), punct("-")

sort counties measureid data_value
merge m:1 counties using `selected_counties'
keep if _merge == 3	

keep if category == "Health Outcomes" & data_value_type == "Age-adjusted prevalence"

gsort counties -data_value 
by counties: gen rank_top5 = _n
keep if rank_top5 <= 5

/*---------------------*/

bysort measure: gen outcome_frequency = _N

gen prevalence_percent= data_value
format prevalence_percent %9.1f

sort counties rank_top5

keep counties rank_top5 measure measureid prevalence_percent outcome_frequency
order counties rank_top5 measure measureid prevalence_percent outcome_frequency

export excel using "$output/FAB_file.xlsx", ///
sheet("Top  5 Outcomes") ///
firstrow(variables) sheetreplace