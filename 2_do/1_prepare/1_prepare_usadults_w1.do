numlabel, add
adopath++ "$path/4_ado"
cd "$path/1_data/4_temp"

*-----------------------------------------------------------------------------
* Import Qualtrics
*-----------------------------------------------------------------------------
import excel using "$path/1_data/1_rawdata/usadults_w1/Qualtrics_Cont_Gender_Rep_Sample_Choice_Text_220324.xlsx", firstrow  clear

* Label/Organize variables
foreach var of varlist * {
	 label variable `var' "`=`var'[1]'"
} 

drop if _n==1 

	foreach var of varlist * {
	destring `var', replace
}

* Drop duplicates
duplicates drop PROLIFIC, force // 14 observations

* Remove testing data: data collection started on 03.22.21
split RecordedDate
gen day=substr(RecordedDate1,3,2)
drop RecordedDate1 RecordedDate2
drop if day=="15" 

* Keep the ones that were finished and consented
keep if Finished=="True" //0 obsv deleted
keep if Consent == "I agree" //1 obsv deleted
drop Finished Consent

duplicates tag prolific_id, gen(dup_id)
assert dup_id==0
drop dup_id

* Rename age
rename age age_qualtrics

tempfile qualtrics
save `qualtrics'
*-----------------------------------------------------------------------------
* Import Prolific "admin data"
*-----------------------------------------------------------------------------
* 30_39
import delimited using "$path/1_data/1_rawdata/usadults_w1/Prolific_Cont_Gender_30_to_39_220324.csv", varn(1) clear
drop reviewed 
	foreach var of varlist * {
	destring `var', replace
}
assert age>=30 & age<=39
tempfile prolific_30_39
save `prolific_30_39', replace

* 40_49
import delimited using "$path/1_data/1_rawdata/usadults_w1/Prolific_Cont_Gender_40_to_49_220324.csv", varn(1) clear
drop reviewed
	foreach var of varlist * {
	destring `var', replace
}
assert age>=40 & age<=49
tempfile prolific_40_49 
save `prolific_40_49', replace

* 50_59
import delimited using "$path/1_data/1_rawdata/usadults_w1/Prolific_Cont_Gender_50_to_59_220324.csv", varn(1) clear
drop reviewed
	foreach var of varlist * {
	destring `var', replace
}
assert age>=50 & age<=59
tempfile prolific_50_59
save `prolific_50_59', replace

* append
clear all
local age 30_39 40_49 50_59
foreach age in `age' {
append using `prolific_`age''
}

* rename age
rename age age_prolific

* rename 
rename participant_id prolific_id
*-----------------------------------------------------------------------------
* Merge prolific with qualtrics data
*-----------------------------------------------------------------------------
merge 1:1 prolific_id using `qualtrics' // 40 unmatched from master, 1 unmatched from using, 2002 merged.
* Gen age brackets by age_prolific
gen age_bracket=""
replace  age_bracket="30-39" if age_prolific<=39
replace  age_bracket="40-49" if age_prolific<=49 & age_prolific>39
replace  age_bracket="50-59" if age_prolific>49
tab age_bracket

* Drop if sex consent is not given
drop if sex=="CONSENT REVOKED" // 31 obs deleted
drop if biological_gender=="" // 9 obs deleted
drop if sex=="" // 1 obs deleted
count // 2,002
tab age_bracket

* Drop if prolific "sex" != biological_gender
drop if biological_gender!=sex  // 8 observations
count // 1,994

assert _merge==3 // all non-merged gave inconsistent answers.
drop _merge

* Drop obs who failed the attention check 
drop if attention_1!=17 | attention_2!=14 // 0 dropped. There is one person that fails but was already dropped as he/she didnt give consent 
drop attention_1 attention_2

count
tempfile usadults_w1
save `usadults_w1', replace


*-----------------------------------------------------------------------------
* US Adults Sample Wave 1
*-----------------------------------------------------------------------------
use `usadults_w1', replace

* Rename the cont_gender_1 with cgi_main // In general, how do you see yourself? 
rename cont_gender_1 cgi_main

* Rename the cont_gender_other with cgi_other // In general, how do most people see you? 
rename cont_gender_other_1 cgi_other

* Rename the cont_gender_male_1 with cgi_male // Relative to men in general, how do you see yourself?  
rename cont_gender_male_1 cgi_male

* Rename the cont_gender_female_1 with cgi_female // Relative to women in general, how do you see yourself? 
rename cont_gender_female_1 cgi_female

* Rename the economic preference variables consistent with how they are collected in US wave 2
rename incentivized_risk_1 incentivized_risk
rename hypothetical_risk_1 hypothetical_risk
rename competitiveness_1 competitiveness
rename redistribution_1 redistribution

*-----------------------------------------------------------------------------
* Sector
*-----------------------------------------------------------------------------
* encode sector
encode sector, gen (sector_encoded)
drop sector
rename sector_encoded sector

* gen gov_sector and private_sector variables
gen gov_sector = sector==1 
replace gov_sector=. if sector==.

gen private_sector = sector==2
replace private_sector=. if sector==.

*-----------------------------------------------------------------------------
* Performace Pay
*-----------------------------------------------------------------------------

/* 
This variable is asked conditioned, both to employed participants for their current employment and unemployed participants for their most recent employment. 
* 1- No
* 2- Yes, less than 1/3 of my total income
* 3- Yes, more than 1/3 but less than 2/3 of
* 4- Yes, more than 2/3 of my total income 
*/

* Process the performace pay variable for the people employed
encode(performance_pay_empl), gen(pay_empl_encoded)
drop performance_pay_empl
rename pay_empl_encoded performance_pay_empl

* Process the performace pay variable for the people unemployed
encode(performance_pay_unem), gen(pay_unem_encoded)
drop performance_pay_unem
rename pay_unem_encoded performance_pay_unem	

*assert to make sure that empl and unempl variables are mutually excl
assert missing(performance_pay_unem)==!missing(performance_pay_empl)

* Merge both in only one variable as they are mutually exclusive
clonevar performance_pay=performance_pay_empl
replace performance_pay = performance_pay_unem if performance_pay ==.

* Gen no_perf_pay and perf_pay_yes variables
gen no_perf_pay = (performance_pay==1) // as we see "1 = No" in the encoding
gen perf_pay_yes = (no_perf_pay==0)

*-----------------------------------------------------------------------------

* flexibility of working hours
*-----------------------------------------------------------------------------

/* 
this variable is asked conditioned, both to employed participants for their current employment and unemployed participants for their most recent employment. 

The encoding for the answers is for both variables the following:
* 1- I can adapt my working hours within certain limits (e.g., flextime)  
* 2- I can choose between several fixed working schedules determined by the company/organization
* 3- My working hours are entirely or almost entirely determined by myself  
* 4- They are set by the company/organization with no possibility for changes  
*/

* Process the work arrangements variable for the people employed
encode(arrangements_empl), gen(arrangements_empl_encoded)
drop arrangements_empl
rename arrangements_empl_encoded arrangements_empl

* Process the work arrangements variable for the people unemployed
encode(arrangements_unempl), gen(arrangements_unempl_encoded)
drop arrangements_unempl
rename arrangements_unempl_encoded arrangements_unempl	

*assert to make sure that empl and unempl variables are mutually excl
assert missing(arrangements_unempl)==!missing(arrangements_empl)

* Merge both in only one variable as they are mutually exclusive. 
clonevar flexibility_arrangement= arrangements_empl
replace flexibility_arrangement = arrangements_unempl if flexibility_arrangement ==.

* working hours 
gen work_hours = .
replace work_hours = 0 if flexibility_arrangement==4  
replace work_hours = 0.5 if flexibility_arrangement==2
replace work_hours = 0.5 if flexibility_arrangement==1
replace work_hours = 1 if flexibility_arrangement==3

la var work_hours "Flexibility of Working Hours (0 No flexibility, 1 Full flexibility)"

* Standardize Work Hours: 
su work_hours
gen std_work_hours=(work_hours-r(mean))/r(sd)

label var std_work_hours "Std. Flexibility of Working Hours (0 No flexibility, 1 Full flexibility)"		

*-----------------------------------------------------------------------------
* changes to working arrangement
*-----------------------------------------------------------------------------

/* 
this variable is asked conditioned, both to employed participants for their current employment and unemployed participants for their most recent employment. 

The encoding for the answers is for both variables the following:
* 1- No  
* 2- Yes, several weeks in advance 
* 3- Yes, the day before 
* 4- Yes, the same day
*/

* Process the work arrangements variable for the people employed
encode(work_changes_empl), gen(work_changes_empl_encoded)
drop work_changes_empl
rename work_changes_empl_encoded work_changes_empl

* Process the work arrangements variable for the people unemployed
encode(work_changes_unempl), gen(work_changes_unempl_encoded)
drop(work_changes_unempl)
rename work_changes_unempl_encoded work_changes_unempl	

* assert to make sure that empl and unempl variables are mutually excl
assert missing(work_changes_unempl)==!missing(work_changes_empl)

* Merge both in only one variable as they are mutually exclusive
clonevar work_changes = work_changes_empl
replace work_changes = work_changes_unempl if work_changes ==.

* Gen no_work_changes and yes_work_changes
gen no_work_changes = (work_changes==1)
gen yes_work_changes = (no_work_changes==0)

*-----------------------------------------------------------------------------
* Ability to take off an hour for personal matters 
*-----------------------------------------------------------------------------

/* this variable is asked conditioned, both to employed participants for their current employment and unemployed participants for their most recent employment. 

The encoding for the answers is for both variables the following:
* 1- Fairly difficult   
* 2- Fairly easy  
* 3- Very difficult 
* 4- Very easy 
*/

* Process the work arrangements variable for the people employed
encode(personal_leave_empl), gen(personal_leave_empl_encoded)
drop(personal_leave_empl)
rename personal_leave_empl_encoded personal_leave_empl 

* Process the work arrangements variable for the people unemployed
encode(personal_leave_unemp), gen(personal_leave_unemp_encoded)
drop(personal_leave_unemp)
rename personal_leave_unemp_encoded personal_leave_unemp

* assert to make sure that empl and unempl variables are mutually excl
assert missing(personal_leave_empl)==!missing(personal_leave_unemp)

* Merge both in only one variable
clonevar personal_leave = personal_leave_empl
replace personal_leave = personal_leave_unemp if personal_leave ==.

* Order the categories from difficult to easy
gen pers_leave = .
replace pers_leave = 1 if personal_leave==3
replace pers_leave = 2 if personal_leave==1
replace pers_leave = 3 if personal_leave==2
replace pers_leave = 4 if personal_leave==4

label define pers_leave 1 "Very difficult" 2 "Fairly difficult" 3 "Fairly easy" 4 "Very easy"
label value pers_leave pers_leave
drop personal_leave // drop the unordered variable.

* std pers_leave
su pers_leave
gen std_pers_leave=(pers_leave-r(mean))/r(sd)
label variable std_pers_leave "Take off an Hour for Personal Matters (std.)"	 

*-----------------------------------------------------------------------------
*industry share 
*-----------------------------------------------------------------------------

/*
In the old version, first the industry_employed and industry_unemployed variables 
were encoded then they were merged into one variable. However, there is one 
industry that exists only in employed (Mining). This made all the industry codes 
after mining to shift. 

1. Agriculture, Forestry and Fishing 
2. Construction 
3. Education and Health Services 
4. Financial Activities 
5. Information       
6. Leisure and Hospitality       
7. Manufacturing 
8. Mining and Quarrying, and Oil and Ga      
9. Other Services    
10. Professional and Business Services      
11. Public Administration        
12. Transportation and Utilities       
13. Wholesale and Retail Trade 
*/	


* Merge both industry_employed and industry_unemployed in only one variable.
clonevar industry = industry_employed
replace industry = industry_unemployed if industry ==""
encode(industry), gen(industry_encoded)
drop industry 
rename industry_encoded industry

* Create new industry_unemployed and industry_employed variables
clonevar industry_employed2=industry if industry_employed!=""
clonevar industry_unemployed2=industry if industry_unemployed!=""

drop industry_employed industry_unemployed
rename industry_employed2 industry_employed
rename industry_unemployed2 industry_unemployed

* merge with female share in industry 
merge m:1 industry using "$path/1_data/3_aux/industry_female_share.dta", nogen assert(3)

*-----------------------------------------------------------------------------
* Division of housework
*-----------------------------------------------------------------------------

*laundry
encode(housework_laundry), gen(housework_laundry_encoded)
drop(housework_laundry)
rename housework_laundry_encoded housework_laundry

*repairs
encode(housework_repairs), gen(housework_repairs_encoded)
drop(housework_repairs)
rename housework_repairs_encoded housework_repairs

*groceries
encode(housework_groceries), gen(housework_groceries_encoded)
drop(housework_groceries)
rename housework_groceries_encoded housework_groceries

*cleaning
encode(housework_cleaning), gen(housework_cleaning_encoded)
drop(housework_cleaning)
rename housework_cleaning_encoded housework_cleaning

*meals
encode(housework_meals), gen(housework_meals_encoded)
drop(housework_meals)
rename housework_meals_encoded housework_meals

// The encoding for laundry, repairs, groceries, cleaning, meals
// 1- About equal or both together 
// 2- Always me 
// 3- Always the other person(s) 
// 4- Usually done by an outsider or not done 
// 5- Usually me 
// 6- Usually the other person(s)

// laundry
gen hh_laundry = .
replace hh_laundry = 1 if housework_laundry==3 // Always the other person(s)
replace hh_laundry = 2 if housework_laundry==6 // Usually the other person(s)
replace hh_laundry = 3 if housework_laundry==1 // About equal or both together
replace hh_laundry = 3 if housework_laundry==4 // Usually done by an outsider or not done 
replace hh_laundry = 4 if housework_laundry==5 // Usually me
replace hh_laundry = 5 if housework_laundry==2 // Always me

//repairs
gen hh_repairs = .
replace hh_repairs = 1 if housework_repairs==3
replace hh_repairs = 2 if housework_repairs==6
replace hh_repairs = 3 if housework_repairs==1
replace hh_repairs = 3 if housework_repairs==4
replace hh_repairs = 4 if housework_repairs==5
replace hh_repairs = 5 if housework_repairs==2

//groceries
gen hh_groceries = .
replace hh_groceries = 1 if housework_groceries==3
replace hh_groceries = 2 if housework_groceries==6
replace hh_groceries = 3 if housework_groceries==1
replace hh_groceries = 3 if housework_groceries==4
replace hh_groceries = 4 if housework_groceries==5
replace hh_groceries = 5 if housework_groceries==2

//cleaning
gen hh_cleaning = .
replace hh_cleaning = 1 if housework_cleaning==3
replace hh_cleaning = 2 if housework_cleaning==6
replace hh_cleaning = 3 if housework_cleaning==1
replace hh_cleaning = 3 if housework_cleaning==4
replace hh_cleaning = 4 if housework_cleaning==5
replace hh_cleaning = 5 if housework_cleaning==2

//meals
gen hh_meals = .
replace hh_meals = 1 if housework_meals==3
replace hh_meals = 2 if housework_meals==6
replace hh_meals = 3 if housework_meals==1
replace hh_meals = 3 if housework_meals==4
replace hh_meals = 4 if housework_meals==5
replace hh_meals = 5 if housework_meals==2

* Create the index of division of housework 
egen division_housework = weightave(hh_laundry hh_repairs hh_groceries hh_cleaning hh_meals) 

* Age sanity checks
gen age_diff=age_qualtrics-age_prolific
tab age_diff
drop age_diff

* Final Sanity checks and organization to make sure that Wave1 variables match Wave2
assert Progress==100
drop Progress RecipientLastName RecipientFirstName RecipientEmail ExternalReference 
destring zip_code, replace

* Rename variables s.t. they are consistent with wave2
drop num_rejections
rename currentcountryofresidence Countryofresidence
rename employmentstatus Employmentstatus
rename nationality Nationality
drop day
rename completed_date_time completed_datetime
assert session_id==SESSION_ID
drop SESSION_ID
drop prolific_score entered_code comments firstlanguage prolific_score

* Save
save "$path/1_data/2_prepared/0_usadults_w1_30_60.dta", replace
