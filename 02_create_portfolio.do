version 18
capture log close _all
capture restore
clear all
set more off

cd "$project"
log using "$output/createlog.log", text replace name(createlog)

display "============================================================"
display "PH 272 FAB - Excel Portfolio Creation"
display "Do-file: 02_create_portfolio.do"
display "Student: Zhan Zhao"
display "Purpose: Create formatted Excel portfolio with plots and tables."
display "============================================================"

capture restore
capture erase "$output/FAB_file.xlsx"

use "$processed/places_2025_county01.dta",clear
/* The Excel Portfolio: */
snapshot save



display "============================================================"
display "Step 1. Keep age-adjusted prevalence records"
display "============================================================"
/*
centile data_value , centile (80)
*Report centile and confidence interval

g flag =1 if data_value>34.8
replace flag = 0 if flag == .
*/

keep if data_value_type == "Age-adjusted prevalence"

count
display "Age-adjusted prevalence observations retained: " r(N)

display "Risk behavior measures available:"
tab measureid

display "============================================================"
display "Step 2. Create one bar chart sheet for each health behavior"
display "============================================================"

levelsof measureid, local(healthbr)

foreach x in `healthbr' {
	preserve
	putexcel set "$output/FAB_file.xlsx", sheet("Behaviors `x'")modify
	keep if measureid == "`x'"
	
	gsort -data_value
	gen rank = _n
	keep if rank<=20
	
	graph hbar (mean) data_value, ///
	over(counties,sort(data_value) descending label(labsize(vsmall))) ///
	name(bar_`x',replace) ///
	title("Top 20 counties: `x'") ///
	ytitle("Age-adjusted prevalence(%)") ///
	graphregion(margin(small)) ///
	plotregion(margin(small))
	
	graph export "$output/bar_`x'.png",replace
	
	putexcel A1 = "Top 20 Counties for `x'"
	putexcel A1, bold
	putexcel A2 = "Statistics: Age-adjusted prevalence,reproted as percentage"
	putexcel A3 =image("$output/bar_`x'.png")
	restore
}


/* Health Outcomes */
/*--------------------------------------------------------------------------*/
* The dataset is now ready for the next step: creating the Excel Portfolio 3.

display "============================================================"
display "Step 3. Identify counties appearing more than once in top 20"
display "============================================================"

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


display "============================================================"
display "Step 4. Determine top 5 Health Outcomes for selected counties"
display "============================================================"

use "$processed/places_2025_county.dta",clear

egen counties = concat(locationname stateabbr), punct("-")

sort counties measureid data_value
merge m:1 counties using `selected_counties'

display "Merge result:"
tab _merge

keep if _merge == 3	
drop _merge

keep if category == "Health Outcomes" & ///
		data_value_type == "Age-adjusted prevalence"

count
display "Health outcome records for selected counties: " r(N)

gsort counties -data_value 
by counties: gen rank_top5 = _n
keep if rank_top5 <= 5

bysort measure: gen outcome_frequency = _N

gen prevalence_percent= data_value
format prevalence_percent %9.1f

label variable outcome_frequency "Frequency of outcome in top 5 list"

sort counties rank_top5

keep counties rank_top5 measure measureid prevalence_percent outcome_frequency
order counties rank_top5 measure measureid prevalence_percent outcome_frequency

display "Final Health Outcomes table:"
list counties rank_top5 measure prevalence_percent outcome_frequency, ///
    sepby(counties) noobs

	
display "============================================================"
display "Step 5. Export Health Outcomes table to Excel portfolio"
display "============================================================"

export excel using "$output/FAB_file.xlsx", ///
sheet("Health Outcomes") firstrow(variables) sheetreplace cell(A4)


putexcel set "$output/FAB_file.xlsx", sheet("Health Outcomes") modify
putexcel A4:F4, bold border(bottom) hcenter
putexcel A4 = "County" ///
		 B4 = "Rank" ///
		 C4 = "Health Outcome" ///
		 D4 = "Measure ID" ///
		 E4 = "Age-adjusted Prevalence (%)" ///
		 F4 = "Outcome Frequency"

putexcel A1 = "statistics note:"
putexcel B1 = "Prevalence is age-adjusted and reported as a percentage"


log close createlog
