clear all
set more off

cd "/Users/zhaozhan/GitHub/CDC_places_county_health_portfolio"

global project "/Users/zhaozhan/GitHub/CDC_places_county_health_portfolio"
global raw "$project/01 Data/raw"
global processed "$project/01 Data/processed"
global output "$project/02 Output"

pwd
display "$raw"
display "$processed"
display "$output"

import delimited "$raw/PLACES__Local_Data_for_Better_Health,_County_Data,_2025_release_20260407.csv", clear

save "$processed/places_2025_county.dta", replace


/* 
Use the variables 'category' and 'measure' to isolate the 4 measured health risk behaviors : 
 a. Binge drinking among adults
 b. Current cigarette somking among adults
 c. No leisure-time physical activity among adults
 d. short sleep duration among adults
*/

keep if category == "Health Risk Behaviors"& ///
	( measure =="Binge drinking among adults" /// 
	| measure =="Current cigarette smoking among adults" ///
	| measure =="No leisure-time physical activity among adults" ///
	| measure =="Short sleep duration among adults" ///
)

/* Label the counties by its name concatenated with its state abbreviation*/


egen counties = concat(locationname stateabbr), punct("-")

save "$processed/places_2025_county01.dta",replace


/*----------------------*/
/* The dataset is now ready for the next step: creating the Excel Portfolio 3. */


preserve
	keep if data_value_type == "Age-adjusted prevalence"

	gsort measureid -data_value 
	by measureid: gen rank = _n
	keep if rank <= 20

	bysort counties: gen repeated_count = _N
	drop if repeated_count == 1

	keep counties 
	duplicate drop counties, force

	tempfile selected_counties
	save `selected_counties', replace
restore

keep if category == "Health Outcomes" & data_value_type == "Age-adjusted prevalence"

merge 

	








egen counties = concat(locationname stateabbr), punct("-")
bysort measureid data_value: gen rank = _n
keep if rank <= 20
bysort counties: gen repeat_count=_N
drop if repeat_count == 1

bysort category measure : keep if category == "Health Outcomes" & data_value_type == "Age-adjusted prevalence"

bysort  measureid -data_value : gen rank_top5 =_n 
keep if rank_top5 <= 5

gsort counties -rank_top5
