
version 18
capture log close _all
capture restore
clear all
set more off





cd "$project"

log using "$output/cleanlog.log", text replace name(cleanlog)


display "============================================================"
display "Step 1. Import raw CDC PLACES county dataset"
display "============================================================"


import delimited "$raw/PLACES__Local_Data_for_Better_Health,_County_Data,_2025_release_20260407.csv", clear


count

display "Number of observations in raw dataset: " r(N)

display "Checking required variables:"

foreach x of varlist category measure data_value_type ///
	data_value locationname stateabbr measureid {
	
	display "required `x' variable is present."
	
}
display "All required variables are present."

display "Distribution of category:"
tab category

display "Distribution of data_value_type:"
tab data_value_type

save "$processed/places_2025_county.dta", replace



display "============================================================"
display "Step 2. Retain four required health risk behavior measures"
display "============================================================"
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

count
display "Observations after filtering four risk behavior measures: " r(N)



display "Selected health risk behavior measures:"
tab measure

display "Selected measure IDs:"
tab measureid

/* Label the counties by its name concatenated with its state abbreviation*/
display "============================================================"
display "Step 3. Create county-state label"
display "============================================================"

egen counties = concat(locationname stateabbr), punct("-")
label variable counties "County name concatenated with state abbreviation"

display "Examples of county-state labels:"
list locationname stateabbr counties in 1/10, noobs
codebook counties



display "============================================================"
display "Step 4. Save cleaned intermediate dataset"
display "============================================================"

describe
count
display "Final number of observations in cleaned dataset: " r(N)

save "$processed/places_2025_county01.dta", replace
display "Cleaned dataset saved successfully:"
display "$processed/places_2025_county01.dta"

display "============================================================"
display "Cleaning workflow completed successfully."
display "Next step: Run 02_create_portfolio.do."
display "============================================================"
log close cleanlog
