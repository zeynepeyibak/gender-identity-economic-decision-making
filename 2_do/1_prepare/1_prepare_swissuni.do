* ado location
numlabel, add
adopath++ "$path/4_ado"
cd "$path/1_data/4_temp"

local date 211011 211012 211014

* Loop through all dates
 foreach d in `date'{
*-----------------------------------------------------------------------------
* Import the survey data
*-----------------------------------------------------------------------------
insheet using "$path/1_data/1_rawdata/swissuni/ContinuousGender_MainStudy_`d'.csv", names clear

* Label variables
foreach var of varlist * {
  label variable `var' "`=`var'[1]'"
}

* Drop responses in progress, i.e. non-complete answers 
drop if finished!="1" // 7 obsv deleted

* Rename recipientid
rename recipientid code

* Sanity checks
drop if code=="" // one entry in 211014 has no recipientid. 
duplicates list code

* Drop duplicates
duplicates drop code, force // 6 people completed the survey twice.

* Label gender 
destring biological_gender, replace
su cont_gender_2_other_1 if biological_gender==1 // mean=2.15 (0=very masculine). 
label define biological_gender 1 "male"  2 "female", replace // acc. to /Continuous Gender/10_Online_Experiment/qualtrics_survey_part_main_experiment.pdf
label values biological_gender biological_gender

* drop click variables
drop *_firstclick *_lastclick *_pagesubmit *_clickcount recipientemail externalreference recipientfirstname recipientlastname

* Temp save
tempfile survey_`d'
save "survey_`d'", replace

*-----------------------------------------------------------------------------
* Import the payment data
*-----------------------------------------------------------------------------
insheet using "$path/1_data/1_rawdata/swissuni/session`d'_payment.csv", names clear

*keep relevant variables
keep code rank1 rank2 rank20  task1_payoff task2_payoff task3_payoff selected_task rank_puzzle correct_puzzles

* Temp save
tempfile payment_`d'
save "payment_`d'", replace 

*-----------------------------------------------------------------------------
* Import oTree data 
*-----------------------------------------------------------------------------
insheet using "$path/1_data/1_rawdata/swissuni/all_apps_wide-`d'.csv", clear

* Rename
rename participant* *
rename _* *

* Drop those that didn't finish
drop if current_page_name!="Ending" //95 obsv deleted

* Merge
merge 1:1 code using "survey_`d'", nogen assert(2 3) keep(3) // assert(2 3) bc survey data includes obsvs for the date(s) before itself
merge 1:1 code using  "payment_`d'", nogen assert(3)

display "obsv count in date `d'"
count

tempfile data_`d'
save "data_`d'", replace
}

*-----------------------------------------------------------------------------
* Append all "data`_d'"
*-----------------------------------------------------------------------------
clear all
foreach d in `date' {
append using "data_`d'"
}

* Save the appended file
tempfile data
save "data", replace

*-----------------------------------------------------------------------------
* Add Fisman et al. rho estimates
*-----------------------------------------------------------------------------

import delimited using "$path/1_data/1_rawdata/swissuni/rho/5_Results.csv", varnames(1) clear
merge 1:1 id using "$path/1_data/1_rawdata/swissuni/rho/2_code_id_CW.dta", assert (3) nogen
merge 1:1 code using "data", assert (3) nogen

tempfile data
save "data", replace

*-----------------------------------------------------------------------------
* Code to follow up token crosswalk
*-----------------------------------------------------------------------------
import excel "$path/1_data/1_rawdata/swissuni/ContinuousGender_Keys_otree_follow-up_survey.xlsx", sheet("Sheet1") firstrow clear
rename tokenKey code
rename participantToken token
tempfile cw_code_token
save `cw_code_token', replace

*-----------------------------------------------------------------------------
* Follow-up survey
*-----------------------------------------------------------------------------
insheet using  "$path/1_data/1_rawdata/swissuni/ContinuousGender_FollowUpStudy_November+1,+2021_14.50.csv", names clear

* Label 
foreach var of varlist * {
  label variable `var' "`=`var'[1]'"
  destring `var', replace
}

* Organize data
rename * *_fo
drop if finished!="1"
drop if distributionchannel!="gl" //eliminate fake obs 
rename externalreference token 
count //621 obsv

*merge
merge 1:1 token using `cw_code_token', keepusing(code) keep(3) nogen
tempfile followup
save `followup', replace

*-----------------------------------------------------------------------------
* Merge  `followup' with `data'
*-----------------------------------------------------------------------------
use "data", clear
merge 1:1 code using `followup', keep(3) //5 unmatched from master

* destring
foreach var of varlist * {
  qui destring `var', replace
}

* cleaning 
rename instructions1playerconsent consent
drop instructions* 
drop v30-v58 

** Drop participants who don't identify as woman or man (binary)

	* label assigned_sex_fo //gender assigned at birth
	destring assigned_sex_fo, replace
	tab assigned_sex_fo biological_gender
	label define assigned_sex_fo 1 "male" 2 "female", replace
	label values assigned_sex_fo assigned_sex_fo

	* label gender2_fo //current gender
	destring gender2_fo, replace
	tab gender2_fo biological_gender
	label define gender2_fo 1 "female" 2 "male", replace
	label values gender2_fo gender2_fo
	
	count // 597
	
	* drop non-binary
	drop if gender2_fo==3 | gender2_fo==4 | gender2_fo==6 // 8 obs deleted
	
	* drop inconsistent sex 
	keep if (biological_gender==2 & gender2_fo==1 & assigned_sex_fo==2) | (biological_gender==1 & gender2_fo==2 & assigned_sex_fo==1) // 5 obs dropped
	drop if gender2_fo==5 // 0 obs deleted
	drop if assigned_sex_fo==3 // 0 obs deleted 
	count // 584

save "$path/1_data/2_prepared/1_SwissUni.dta", replace
*-----------------------------------------------------------------------------
* Variable Creation
*-----------------------------------------------------------------------------
use "$path/1_data/2_prepared/1_SwissUni.dta", clear

* female
gen female=0
replace female=1 if biological_gender==2
label define female 0 "men" 1 "women"
label value female female 
tab biological_gender female

* Prepare first order and third order CGI: destring, rename consistently and standardize
	destring cont_gender_1 cont_gender_other_13, replace 
	rename cont_gender_1 cgi_main, replace
	rename cont_gender_other_13 cgi_other, replace

	* First order CGI
	su cgi_main //0-10
	gen std_cgi_main=(cgi_main-r(mean))/r(sd)
	la var cgi_main "CGI (self, 0 Masculine, 10 Feminine)" 
	la var std_cgi_main "Std. CGI (self)" 
	
	* Follow up First Order CGI
	destring q43_1, replace 
	rename q43_1 cgi_main_fo
	su cgi_main_fo  //0-11
	gen std_cgi_main_fo=-(cgi_main_fo-r(mean))/r(sd)

	*Third order CGI
	su cgi_other
	gen std_cgi_other=(cgi_other-r(mean))/r(sd)
	la var cgi_other "CGI Third-Order (how others see you, 0 Masculine, 10 Feminine)" 
	la var std_cgi_other "Std. CGI Third-Order (how others see you)" 
	

* Magliozzi measures
rename cont_gender_2_other_1 magliozzi_fem
rename cont_gender_2_other_2 magliozzi_masc

su magliozzi_fem
gen std_magliozzi_fem=(magliozzi_fem-r(mean))/r(sd)

su magliozzi_masc
gen std_magliozzi_masc=(magliozzi_masc-r(mean))/r(sd)

*-----------------------------------------------------------------------------
** Incentivized Measures
*-----------------------------------------------------------------------------

	* Incentivized Risk
	/* Participants allocate between 0 and 100 ECU to a risky investment. 
	The investment has a 50% probability of success, in which case it 
	returns 2.5 times the invested amount. */
	assert part11playerinvestment!=.
	gen incentivized_risk = part11playerinvestment
	su incentivized_risk
	gen std_incentivized_risk =(incentivized_risk- r(mean))/ r(sd)

	label variable incentivized_risk "Incentivized Risk"
	label var std_incentivized_risk "Std. Incentivized Risk" 

	* Incentivized Competitiveness
	/* Competitiveness was elicited following a design similar to 
	Niederle and Vesterlund (2007)... Outcome variable for competitiveness 
	is the binary choice in Round 3, as choosing the tournament indicates 
	greater preference for competition. */
	assert part2_task31playerchoice!=.
	gen incentivized_competitiveness = part2_task31playerchoice==2

	label define incentivized_competitiveness 1 "piece-rate" 2 "tournament"
	label var incentivized_competitiveness "Incentivized Competitiveness (Binary)" 


	* Incentivized measure of Efficiency over Equality 
	/* Equality versus efficiency is measured by implementing 15 graphical 
	budget sets, similarly to Fisman et al. (2007). 0<ρ≤1 = weighted towards 
	efficiency, ρ<0 = weighting toward equality. */
	xtile dec_rho_wo = rho, nq(10)
	label variable dec_rho_wo "Equality/Efficiency (decile)"

	rename rho rho_raw
	rename dec_rho_wo rho
	replace rho = rho/10 
	label var rho "Incentivized Equality/Efficiency"

	* Overconfidence
	assert part48playerrank_guess!=.
	assert rank_puzzle!=.
	assert survey1playerrank4!=.
	assert rank1!=.
	assert survey1playerrank20!=.
	assert rank20!=.
	
	gen overpl_puzzle=part48playerrank_guess-rank_puzzle
	gen overpl_competrank4=survey1playerrank4-rank1
	gen overpl_competrank20=survey1playerrank20-rank20

	foreach var of varlist overpl_puzzle overpl_competrank4 overpl_competrank20{
		su `var'
		gen st_`var'=(`var'-r(mean))/r(sd)   
	} 

	* install the program "weightave": https://github.com/PrincetonBPL/ado-gallery 
	egen incentivized_overconfidence = weightave(st_overpl_puzzle st_overpl_competrank4 st_overpl_competrank20)

	su incentivized_overconfidence
	gen std_incentivized_overconfidence =(incentivized_overconfidence- r(mean))/ r(sd)

	la var incentivized_overconfidence "Incentivized Overconfidence" 
	la var std_incentivized_overconfidence "Std. Incentivized Overconfidence" 

*-----------------------------------------------------------------------------
** Non-incentivized Measures (self-reported) measures

* Hypothetical risk
// Label: Please state, in general, how willing or unwilling you are to take risks, using...
assert q64_1_fo!=.
gen hypothetical_risk = q64_1_fo 
su hypothetical_risk
gen std_hyp_risk = (hypothetical_risk-r(mean))/r(sd)

label variable hypothetical_risk "Hypothetical Risk"
label variable std_hyp_risk "Std. Hypothetical Risk"

* Competitiveness (non-incentivized)
// It has no label, so I do not know the question
assert q53_1_fo!=.
gen competitiveness = q53_1_fo  
su competitiveness
gen std_competitiveness =(competitiveness- r(mean))/ r(sd)

la var competitiveness "Competitiveness" 
la var std_competitiveness "Std. Competitiveness" 

* Redistribution  
// Label: How much economic redistribution do you want in society? 
assert redistribution_1_fo!=.
gen redistribution = redistribution_1_fo
su redistribution
gen std_redistribution =(redistribution- r(mean))/ r(sd)

la var redistribution "Redistribution" 
la var std_redistribution "Std. Redistribution" 

* Altruism, which to be consistent with the rest, we call it donation  
//gen donation =q66_5_fo 
//Label: q66_5_fo = How willing are you to give to good causes without expecting anything in return?
//Label: donation_fo = Imagine the following situation: Suppose you unexpectedly received 2400 CHF. How...
assert donation_fo!=.
gen donation = donation_fo
su donation
gen std_donation =(donation- r(mean))/ r(sd)

la var donation "Donation" 
la var std_donation "Std. Donation" 

* Overprecision
// q56_fo  : Please enter the number of jellybeans you think are in this jar (between 1 and 1
// q57_fo  : How confident are you of your answer to this question?
assert q57_fo!=.
gen overconfidence =q57_fo
gen std_overconfidence =(overconfidence- r(mean))/ r(sd)

la var overconfidence "Overconfidence" 
la var std_overconfidence "Std. Overconfidence" 

* Staircase risk

gen risk_willingness = 1 if q626_fo ==2
replace risk_willingness =2 if q626_fo ==1
replace risk_willingness =3 if q624_fo ==2
replace risk_willingness =4 if q624_fo ==1
replace risk_willingness =5 if q620_fo ==2
replace risk_willingness =6 if q620_fo ==1
replace risk_willingness =7 if q618_fo ==2
replace risk_willingness =8 if q618_fo ==1
replace risk_willingness =9 if q632_fo ==2
replace risk_willingness =10 if q632_fo ==1
replace risk_willingness =11 if q634_fo ==2
replace risk_willingness =12 if q634_fo ==1
replace risk_willingness =13 if q640_fo ==2
replace risk_willingness =14 if q640_fo ==1
replace risk_willingness =15 if q638_fo ==2
replace risk_willingness =16 if q638_fo ==1
replace risk_willingness =17 if q650_fo ==2
replace risk_willingness =18 if q650_fo ==1
replace risk_willingness =19 if q648_fo ==2
replace risk_willingness =20 if q648_fo ==1
replace risk_willingness =21 if q656_fo ==2
replace risk_willingness =22 if q656_fo ==1
replace risk_willingness =23 if q654_fo ==2
replace risk_willingness =24 if q654_fo ==1
replace risk_willingness =25 if q664_fo ==2
replace risk_willingness =26 if q664_fo ==1
replace risk_willingness =27 if q662_fo ==2
replace risk_willingness =28 if q662_fo ==1
replace risk_willingness =29 if q668_fo ==2
replace risk_willingness =30 if q668_fo ==1
replace risk_willingness =31 if q670_fo ==2
replace risk_willingness =32 if q670_fo ==1

* Create the variable of Staircase risk 
rename risk_willingness staircase_risk
su staircase_risk
gen std_staircase_risk = (staircase_risk-r(mean))/r(sd)

gen educ_control=0 
replace educ_control=1 if education==14 | education==15 
label var educ_control "Binary variable: 1 people with master/phd, 0 else"

* destring age
destring age, replace


* save
save "$path/1_data/2_prepared/1_SwissUni.dta", replace



