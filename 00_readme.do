/*-----------------------------------------------------------------------
Project:     Analytic Bundle
File:        00_readme.do
Author:      Zhan Zhao
Email:       zz1461153@gmail.com
Date:        4.29.2026
Purpose:     Run the full workflow from cleaning to final output.

Instructions:
    1. Change only the cd line below to the project folder path.
    2. Run this file from top to bottom.
    3. The cleaning and analysis do-files will run automatically.
------------------------------------------------------------------------------*/

version 18
clear all
set more off

* Set project directory

cd "/Users/zhaozhan/GitHub/CDC_places_county_health_portfolio/"

* Run project do-files

do "01_clean_places.do"

/*cd "/Users/zhaozhan/Zhan_Zhao_FAB"*/
do "02_create_portfolio.do"
