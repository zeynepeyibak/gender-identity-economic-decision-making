clear all

global out_path "$path/3_out" 
"$path/1_data/4_temp"				
numlabel, add

use "$path/2_do/2_analysis/11_nonbinary/0_usadults_w2_20_60.dta", replace
append using "$path/2_do/2_analysis/11_nonbinary/0_usadults_w1_30_60", generate(Wave)

* Rename wave 
replace Wave = 2 if Wave == 0 
do "$path/2_do/3_aux/label_subscales"

*-----------------------------------------------------------------------------
* Study Fields
*-----------------------------------------------------------------------------

* Encode study fields
replace study_field = "1" if study_field == "Agriculture, Forestry, Fisheries and Veterinary"
replace study_field = "2" if study_field == "Arts and Humanities"
replace study_field = "3" if study_field == "Biological and Related Science / Environmental Science "
replace study_field = "4" if study_field == "Business, Administration and Law"
replace study_field = "5" if study_field == "Education"
replace study_field = "6" if study_field == "Engineering, Manufacturing and Construction"
replace study_field = "7" if study_field == "Health and Welfare"
replace study_field = "8" if study_field == "Information and Communication Technologies"
replace study_field = "9" if study_field == "Other, please specify:"
replace study_field = "10" if study_field == "Physical Sciences / Mathematics and Statistics"
replace study_field = "11" if study_field == "Social Sciences, Journalism, and Information"

* Other study field
do "$path/2_do/3_aux/other_study_field"

destring study_field, replace

* Dummy for each field
gen agriculture = (study_field==1)
gen arts = (study_field==2)
gen biological = (study_field==3)
gen business = (study_field==4)
gen education = (study_field==5)
gen engineering = (study_field==6)
gen health = (study_field==7)
gen information = (study_field==8)
gen other_field = (study_field==9)
gen physics = (study_field==10)
gen social = (study_field==11)	
gen service = (study_field==12)	

* Merge with female shares in major studied
merge m:1 study_field using "$path/1_data/3_aux/major_female_share.dta", nogen keep(1 3) // 1 unmatched major (12- services) left from using 

*-----------------------------------------------------------------------------
* CGI Variables
*-----------------------------------------------------------------------------
* Gen female dummy
gen female=0
replace female=1 if assigned_sex== "Female"
label define female 0 "men" 1 "women"
label value female female 
label variable female "acc. to . biological_gender"

* cgi_own (Relative to your own biological gender, how do you see yourself?)
generate cgi_own = .
replace cgi_own = cgi_male if assigned_sex == "Male"
replace cgi_own = cgi_female if assigned_sex == "Female"

* cgi_opposite (Relative to the opposite biological gender, how do you see yourself?)
generate cgi_opposite = .
replace cgi_opposite = cgi_female if assigned_sex == "Male"
replace cgi_opposite = cgi_male if assigned_sex == "Female"

** Standardization

* CGI (First order)
su cgi_main
gen std_cgi_main=(cgi_main-r(mean))/r(sd)

* CGI Other (Third order)
su cgi_other
gen std_cgi_other=(cgi_other-r(mean))/r(sd)

* CGI Male
su cgi_male
gen std_cgi_male=(cgi_male-r(mean))/r(sd)

* CGI Female
su cgi_female
gen std_cgi_female=(cgi_female-r(mean))/r(sd)

* CGI Own Gender
su cgi_own
gen std_cgi_own=(cgi_own-r(mean))/r(sd)

* CGI Other Gender
su cgi_opposite
gen std_cgi_opposite=(cgi_opposite-r(mean))/r(sd)


*-----------------------------------------------------------------------------
* Donation
*-----------------------------------------------------------------------------
/* Imagine the following situation: Suppose you unexpectedly received $2400.
 How much of this amount would you donate to a good cause?  
 (Values between 0 and $2400 are allowed)*/
 
su donation
gen std_donation=(donation-r(mean))/r(sd)
label variable std_donation "Std. Donation"
assert donation!=.

*-----------------------------------------------------------------------------
* Redistribution
*-----------------------------------------------------------------------------
/* How much economic redistribution do you want in society? 
"No redistribution" means the state does not influence the income distribution at all, 
and "Full redistribution" means everyone earns the same amount after taxes and subsidies. */

su redistribution
gen std_redistribution=(redistribution-r(mean))/r(sd)
assert redistribution!=.

*-----------------------------------------------------------------------------
* Competitiveness
*-----------------------------------------------------------------------------
/* How competitive do you consider yourself to be? Please indicate your response 
on this scale from 0-"Not at all competitive" to 10-"Very competitive". */

su competitiveness
gen std_competitiveness=(competitiveness-r(mean))/r(sd)
assert competitiveness!=.

*-----------------------------------------------------------------------------
* Hypothetical risk
*-----------------------------------------------------------------------------
/* How willing or unwilling are you to take risks, in general? 
Please indicate your response on this scale from 0-"Completely unwilling to take risks" 
to 10-"Very willing to take risks". */

su hypothetical_risk
gen std_hyp_risk=(hypothetical_risk-r(mean))/r(sd)
assert hypothetical_risk!=.

*-----------------------------------------------------------------------------
* Incentivized risk
*-----------------------------------------------------------------------------
/* For this, we endow you with an additional $1. You choose how much of this amount you wish to invest.
If the virtual coin comes up tails, the investment fails, and you lose the amount invested.
If the virtual coin comes up heads, the investment succeeds, and you receive 2.5 times the amount invested. */

su incentivized_risk
gen std_incentivized_risk=(incentivized_risk-r(mean))/r(sd)

*-----------------------------------------------------------------------------
* Control Variables
*-----------------------------------------------------------------------------
** age squared 
rename age_qualtrics age // as there are less missing obs in qualtrics age, take it as the default one. 
label variable age "age_qualtrics"
label variable age_prolific "age_prolific"

destring age, replace
gen squared_age = age*age

** state (In qualtrics there are 52 different state options but in data we have 51 as there are no obs from Puerto Rico.)
encode(state), gen(state_encoded)
drop state
rename state_encoded state

** relationship status
	* encode Categorical var
	encode(relationship_status), gen(relationship_status_encoded)
	drop relationship_status
	rename relationship_status_encoded relationship_status

	* create dummies
	assert relationship_status!=. //before creating the dummies, make sure that there are no missings.
	gen divorced = (relationship_status==1)
	gen married = (relationship_status==2)
	gen relationship = (relationship_status==3)
	gen single = (relationship_status==4)
	gen separated = (relationship_status==5)
	gen widowed = (relationship_status==6)

** sex orientation
	* encode Categorical var
	encode(sex_orientation), gen(sex_orientation_encoded)
	drop sex_orientation
	rename sex_orientation_encoded sex_orientation

	* create dummies
	assert sex_orientation!=.
	gen bisexual = (sex_orientation==1)
	gen gay = (sex_orientation==2)
	gen hetero = (sex_orientation==3)
	gen other_orientation = (sex_orientation==4)
	gen no_orientation = (sex_orientation==5)

** children
	* encode Categorical var
	encode(children), gen(children_encoded)
	drop children
	replace children_encoded=0 if children_encoded==6 // 6 is is encoded as none
	rename children_encoded children
	
	* Create dummies
	assert children!=.
	gen no_children = (children==0)
	gen one_child = (children==1)
	gen two_children = (children==2)
	gen three_children = (children==3)
	gen four_children = (children==4)
	gen fiveplus_children = (children==5)


** race and ethnicity
	* encode categorical var
	encode(race_ethnicity), gen(race_ethnicity_encoded)
	drop race_ethnicity
	rename race_ethnicity_encoded race_ethnicity
	
	* Create dummies
	assert race_ethnicity!=.
	gen american_indian = (race_ethnicity==1)
	gen asian = (race_ethnicity==2)
	gen black = (race_ethnicity==3)
	gen hispanic = (race_ethnicity==4)
	gen hawaiian = (race_ethnicity==5)
	gen other_race = (race_ethnicity==6)
	gen white = (race_ethnicity==7)

** education
	* encode categorical var
	encode(education_level), gen(educ_encoded)
	drop education_level 
	rename educ_encoded education_level

	* Create dummies
	assert education_level!=.
	gen one_year_college = (education_level==1)
	gen associate = (education_level==2)
	gen bachelor = (education_level==3)
	gen doctorate = (education_level==4)
	gen ged = (education_level==5)
	gen master = (education_level==6)
	gen no_schooling = (education_level==7)
	gen professional = (education_level==8)
	gen high_school = (education_level==9)
	gen some_college = (education_level==10)

** employment status
	* encode categorical var
	encode(employment_status), gen(employment_status_encoded)
	drop employment_status
	rename employment_status_encoded employment_status
	replace employment_status=. if STUDY_ID == "6410819079fb0bd36e5d6bf0" | STUDY_ID == "6410819079fb0bd36e5d6bf1"  // employment status is missing if age 20-29

	* Create Dummies // maybe the missing employment_status could be treated for each category variable too? I think either case is OK
	gen child_leave = (employment_status==1)
	replace child_leave=. if employment_status==. 
	
	gen employed = (employment_status==2)
	replace employed=. if employment_status==.
	
	gen homemaker = (employment_status==3)
	replace homemaker=. if employment_status==.
	
	gen in_education = (employment_status==4)
	replace in_education=. if employment_status==.
	
	gen other_employment = (employment_status==5)
	replace other_employment=. if employment_status==.
	
	gen relative_assisting = (employment_status==6)
	replace relative_assisting=. if employment_status==.
	
	gen retired = (employment_status==7)
	replace retired=. if employment_status==.
	
	gen self_employed = (employment_status==8)
	replace self_employed=. if employment_status==.
	
	gen long_term_illness = (employment_status==9)
	replace long_term_illness=. if employment_status==.
	
	gen unemployed = (employment_status==10)
	replace unemployed=. if employment_status==.

** employment looking
gen employment_looking_1=.
replace employment_looking_1=1 if employment_looking=="Yes"
replace employment_looking_1=0 if employment_looking=="No"
label define employment_looking_1 0 "No" 1 "Yes"
label value employment_looking_1 employment_looking_1
drop employment_looking 
rename employment_looking_1 employment_looking

** weeks worked
	* Encode caregorical var
	encode(weeks_worked), gen(weeks_worked_encoded)
	drop weeks_worked
	rename weeks_worked_encoded weeks_worked

	* create weeks worked approximated variables
	gen weeks_worked_cont = .
	replace weeks_worked_cont = 7 if weeks_worked==1 // (0 weeks + 13 weeks / 2 = 6.5, which means approximately 7 weeks)
	replace weeks_worked_cont = 20 if weeks_worked==2 // (14 weeks + 26 weeks / 2 = 20 weeks)
	replace weeks_worked_cont = 33 if weeks_worked==3 // (27 weeks + 39 weeks / 2 = 33 weeks)
	replace weeks_worked_cont = 46 if weeks_worked==4 // (40 weeks + 52 weeks / 2 = 46 weeks)

** hours worked 
	* Encode caregorical var
	encode(hours_worked), gen(hours_worked_encoded)
	drop hours_worked
	rename hours_worked_encoded hours_worked

	* Create approximated hours worked variables
	gen hours_worked_cont = .
	replace hours_worked_cont = 5 if hours_worked==1 // (0 hours + 10 hours / 2 = 5 hours)
	replace hours_worked_cont = 15 if hours_worked==2 // (11 hours + 20 hours / 2 = 15.5 hours, approximately 15)
	replace hours_worked_cont = 25 if hours_worked==3 // (21 hours + 30 hours / 2 = 25.5 hours, approximately 25)
	replace hours_worked_cont = 35 if hours_worked==4 // (31 hours + 40 hours / 2 = 35.5 hours, approximately 35)
	replace hours_worked_cont = 45 if hours_worked==5 // (41 hours + 50 hours / 2 = 45.5 hours, approximately 45)
	replace hours_worked_cont = 55 if hours_worked==6 // (We use 55 for more than 50 hours)

	gen yearly_work_hours = weeks_worked_cont*hours_worked_cont
	gen yearly_work_hours_weeklyaverage=yearly_work_hours/52
	
** income
* Encode income 
encode income, gen(income_encoded)
drop income
rename income_encoded income

* income dummies
gen income_less_5k = income==1
gen income_10k_25k = income==2
gen income_100k_250k = income==3
gen income_25k_50k = income==4
gen income_5k_10k = income==5
gen income_50k_100k = income==6
gen income_more_250k = income==7

* income approx var
gen income_cont = .
replace income_cont = 2.5 if income==1 // (0k + 5k / 2 = 2.5k)
replace income_cont = 17.5 if income==2 // (10k + 25k /2 = approximately 17.5k)
replace income_cont = 175 if income==3 // (100k + 250k /2 = approximately 175k)
replace income_cont = 37.5 if income==4 // (25k + 50k /2 = approximately 57.5k)
replace income_cont = 7.5 if income==5 // (5k + 10k /2 = approximately 7.5k)
replace income_cont = 75 if income==6 // (50k + 100k /2 = approximately 75k)
replace income_cont = 350 if income==7 // For more than 250k, assume 350000 
replace income_cont = 0 if income==.

** financial market 
	* financial_market dummies 1
	encode financial_market, gen(financial_market_encoded) //1=no, 2=yes
	drop financial_market
	rename financial_market_encoded financial_market

	replace financial_market=0 if financial_market==1 //no
	replace financial_market=1 if financial_market==2 //yes
	
	label define financial_market 0 "No" 1 "Yes"
  	label values financial_market financial_market
	
	* standardize
	su financial_market
	gen std_financial_market =(financial_market-r(mean))/r(sd)

** negotiation
	* categorical var
	encode negotiation, gen(negotiation_encoded) //1=No, 2=Yes, only once, 3=Yes, more than once
	drop negotiation
	rename negotiation_encoded negotiation

	* create a dummy
	gen negot_yes=negotiation==2 | negotiation==3
	replace negot_yes=. if negotiation==.

* manager employed //asked only to people above 30
gen manager=.
replace manager=1 if manager_employed =="Yes"| manager_unemployed == "Yes"
replace manager=0 if manager_employed =="No" | manager_unemployed =="No"
label define manager 0 "No" 1 "Yes"
label value manager manager

** Division (Source: https://www2.census.gov/geo/pdfs/maps-data/maps/reference/us_regdiv.pdf)

gen division = .
replace division=1 if inlist(state,"Maine":state_encoded,"New Hampshire":state_encoded, "Vermont":state_encoded, "Massachusetts":state_encoded, "Rhode Island":state_encoded, "Connecticut":state_encoded)
replace division=2 if inlist(state,"New York":state_encoded,"Pennsylvania":state_encoded, "New Jersey":state_encoded)
replace division=3 if inlist(state,"Wisconsin":state_encoded,"Michigan":state_encoded, "Illinois":state_encoded, "Indiana":state_encoded, "Ohio":state_encoded)
replace division=4 if inlist(state,"North Dakota":state_encoded,"South Dakota":state_encoded, "Nebraska":state_encoded, "Kansas":state_encoded, "Minnesota":state_encoded, "Iowa":state_encoded, "Missouri":state_encoded)
replace division=5 if inlist(state,"Delaware":state_encoded,"Maryland":state_encoded, "District of Columbia":state_encoded, "Virginia":state_encoded, "West Virginia":state_encoded, "North Carolina":state_encoded, "South Carolina":state_encoded, "Georgia":state_encoded, "Florida":state_encoded)
replace division=6 if inlist(state,"Kentucky":state_encoded,"Tennessee":state_encoded, "Mississippi":state_encoded, "Alabama":state_encoded)
replace division=7 if inlist(state,"Oklahoma":state_encoded,"Texas":state_encoded, "Arkansas":state_encoded, "Louisiana":state_encoded)
replace division=8 if inlist(state,"Idaho":state_encoded,"Montana":state_encoded, "Wyoming":state_encoded, "Nevada":state_encoded, "Utah":state_encoded, "Colorado":state_encoded, "Arizona":state_encoded, "New Mexico":state_encoded)
replace division=9 if inlist(state,"Alaska":state_encoded,"Washington":state_encoded, "Oregon":state_encoded, "California":state_encoded, "Hawaii":state_encoded)

label define division 1 "New England" 2 "Middle Atlantic" 3 "East North Central" 4 "West North Central" 5 "South Atlantic" 6 "East South Central" 7 "West South Central" 8 "Mountain" 9 "Pacific"
label value division division


** Race 
*** We try to control for races other than black and white. Therefore, we form the variable other races = american indian + alaskan + asian + hsipanic + hawaiian + other race
*** In the regressions, we will include black and all_other_races and omit white, to avoid multicollenarity
gen all_other_races = max(american_indian, asian, hispanic, hawaiian, other_race)

** Age Groups: 
	* Age group 20-29
	gen twenties = 0
	replace twenties=1 if age >= 20 & age < 30
	* Age group 30-39
	gen thirties = 0
	replace thirties=1 if age >= 30 & age < 40
	* Age group 40-49
	gen fourties = 0
	replace fourties=1 if age >=40 & age < 50
	* Age group 50-60	
	gen fifties = 0
	replace fifties=1 if age >=50 & age <= 60
	
* Gen wave dummy
gen wave1=Wave==1

* Save wave 1 and wave 2
save "$path/2_do/2_analysis/11_nonbinary/1_usadults_w1_w2_20_60.dta", replace

* Save wave 1
preserve
keep if Wave==1 
save "$path/2_do/2_analysis/11_nonbinary/1_usadults_w1_30_60.dta", replace
restore

* Save wave 2 - 20-60
preserve
keep if Wave==2 
save "$path/2_do/2_analysis/11_nonbinary/1_usadults_w2_20_60.dta", replace

drop if STUDY_ID == "6410819079fb0bd36e5d6bf0" | STUDY_ID == "6410819079fb0bd36e5d6bf1" 

* Save wave 2 - 30-60
save "$path/2_do/2_analysis/11_nonbinary/1_usadults_w2_30_60.dta", replace
restore

* Save wave 1 wave 2- 30-60
preserve
drop if STUDY_ID == "6410819079fb0bd36e5d6bf0" | STUDY_ID == "6410819079fb0bd36e5d6bf1" 
save "$path/2_do/2_analysis/11_nonbinary/1_usadults_w1_w2_30_60.dta", replace
restore


* Erase 0_US files
erase "$path/2_do/2_analysis/11_nonbinary/0_usadults_w1_30_60.dta"
erase "$path/2_do/2_analysis/11_nonbinary/0_usadults_w2_20_60.dta"

