cd "/Users/zhaozhan/GitHub/CDC_places_county_health_portfolio/01 Data"

import delimited "./raw/PLACES__Local_Data_for_Better_Health,_County_Data,_2025_release_20260407.csv",clear

use "./processed/places_2025_county.dta", clear

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

save "./processed/places_2025_county01.dta",replace
