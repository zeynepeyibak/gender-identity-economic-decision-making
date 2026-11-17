numlabel, add

* ado location
adopath++ "$path/4_ado"

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


/*
*erase temp files
foreach d in `date'{
	erase "$path/1_data/1_rawdata/swissuni/rho/data_`d'.dta"
	erase "$path/1_data/1_rawdata/swissuni/rho/payment_`d'.dta"
	erase "$path/1_data/1_rawdata/swissuni/rho/survey_`d'.dta"
}
*/

* Prepare the data to compute rho



forvalues i =1/15{
	
	if inlist("`i'", "1") {
		local m=120
		local ps=3
		local po=1
		assert part3`i'playerbudget_s<=`m'
		assert part3`i'playerbudget_o<=`m'
		replace part3`i'playerbudget_o = `po'*(120-3*part3`i'playerbudget_s)/`m'
		replace part3`i'playerbudget_s = (`ps'*part3`i'playerbudget_s)/`m'
	}
	
	if inlist("`i'", "2") { 
		local m=120
		local ps=1
		local po=3
		assert part3`i'playerbudget_s<=`m'
		assert part3`i'playerbudget_o<=`m'		
		replace part3`i'playerbudget_o = `po'*(40-1/3*part3`i'playerbudget_s )/`m'
		replace part3`i'playerbudget_s = (`ps'*part3`i'playerbudget_s)/`m'
		
	}
	
	if inlist("`i'", "3") { 
		local m=120
		local ps=2
		local po=1
		assert part3`i'playerbudget_s<=`m'
		assert part3`i'playerbudget_o<=`m'		
		replace part3`i'playerbudget_o = `po'*(120-2*part3`i'playerbudget_s)/`m'
		replace part3`i'playerbudget_s = (`ps'*part3`i'playerbudget_s)/`m'
	}
	
	if inlist("`i'", "4") { 
		local m=120
		local ps=1
		local po=2
		assert part3`i'playerbudget_s<=`m'
		assert part3`i'playerbudget_o<=`m'		
		replace part3`i'playerbudget_o = `po'*(60-1/2*part3`i'playerbudget_s)/`m'
		replace part3`i'playerbudget_s = (`ps'*part3`i'playerbudget_s)/`m'
	}
	
	if inlist("`i'", "5") { 
		local m=80
		local ps=1
		local po=1
		assert part3`i'playerbudget_s<=`m'
		assert part3`i'playerbudget_o<=`m'		
		replace part3`i'playerbudget_o = `po'*(80-part3`i'playerbudget_s)/`m'
		replace part3`i'playerbudget_s = (`ps'*part3`i'playerbudget_s)/`m'
	}
	
	if inlist("`i'", "6") { 
		local m=160
		local ps=4
		local po=1
		assert part3`i'playerbudget_s<=`m'
		assert part3`i'playerbudget_o<=`m'		
		replace part3`i'playerbudget_o =`po'* (160-4*part3`i'playerbudget_s)/`m'
		replace part3`i'playerbudget_s = (`ps'*part3`i'playerbudget_s)/`m'
	}
	
	if inlist("`i'", "7") { 
		local m=160
		local ps=1
		local po=4
		assert part3`i'playerbudget_s<=`m'
		assert part3`i'playerbudget_o<=`m'		
		replace part3`i'playerbudget_o = `po'*(40-1/4*part3`i'playerbudget_s)/`m'
		replace part3`i'playerbudget_s = (`ps'*part3`i'playerbudget_s)/`m'
	}
	
	if inlist("`i'", "8") { 
		local m=400
		local ps=4
		local po=5
		assert part3`i'playerbudget_s<=`m'
		assert part3`i'playerbudget_o<=`m'		
		replace part3`i'playerbudget_o = `po'*(80-4/5*part3`i'playerbudget_s)/`m'
		replace part3`i'playerbudget_s = (`ps'*part3`i'playerbudget_s)/`m'
	}
	
	if inlist("`i'", "9") { 
		local m=400
		local ps=5
		local po=4
 		assert part3`i'playerbudget_s<=`m'
		assert part3`i'playerbudget_o<=`m'		
		replace part3`i'playerbudget_o = `po'*(100-5/4*part3`i'playerbudget_s)/`m'
		replace part3`i'playerbudget_s = (`ps'*part3`i'playerbudget_s)/`m'
	}
	
	if inlist("`i'", "10") { 
		local m=300
		local ps=2
		local po=5
		assert part3`i'playerbudget_s<=`m'
		assert part3`i'playerbudget_o<=`m'		
		replace part3`i'playerbudget_o = `po'*(60-2/5*part3`i'playerbudget_s)/`m'
		replace part3`i'playerbudget_s = (`ps'*part3`i'playerbudget_s)/`m'
	}
	
	if inlist("`i'", "11") {
		local m=300
		local ps=5
		local po=2
		assert part3`i'playerbudget_s<=`m'
		assert part3`i'playerbudget_o<=`m'		
		replace part3`i'playerbudget_o = `po'*(150-5/2*part3`i'playerbudget_s)/`m'
		replace part3`i'playerbudget_s = (`ps'*part3`i'playerbudget_s)/`m'
	}
	
	if inlist("`i'", "12") { 
		local m=150
		local ps=1
		local po=5
		assert part3`i'playerbudget_s<=`m'
		assert part3`i'playerbudget_o<=`m'		
		replace part3`i'playerbudget_o = `po'*(30-1/5*part3`i'playerbudget_s)/`m'
		replace part3`i'playerbudget_s = (`ps'*part3`i'playerbudget_s)/`m'
	}
	
	if inlist("`i'", "13") {
		local m=150
		local ps=5
		local po=1
		replace part3`i'playerbudget_s=`m' if part3`i'playerbudget_s>`m'
		replace part3`i'playerbudget_o=0 if part3`i'playerbudget_o<0
		assert part3`i'playerbudget_s<=`m'
		assert part3`i'playerbudget_o<=`m'		
		replace part3`i'playerbudget_o = `po'*(150-5*part3`i'playerbudget_s)/`m'
		replace part3`i'playerbudget_s = (`ps'*part3`i'playerbudget_s)/`m'
	}
	
	if inlist("`i'", "14") { 
		local m=300
		local ps=3
		local po=5
		assert part3`i'playerbudget_s<=`m'
		assert part3`i'playerbudget_o<=`m'		
		replace part3`i'playerbudget_o = `po'*(60-3/5*part3`i'playerbudget_s)/`m'
		replace part3`i'playerbudget_s = (`ps'*part3`i'playerbudget_s)/`m'
	}
	
	if inlist("`i'", "15") { 
		local m=300
		local ps=5
		local po=3
		assert part3`i'playerbudget_s<=`m'
		assert part3`i'playerbudget_o<=`m'		
		replace part3`i'playerbudget_o = `po'*(100-5/3*part3`i'playerbudget_s)/`m'
		replace part3`i'playerbudget_s = (`ps'*part3`i'playerbudget_s)/`m'
	}
	
	rename (part3`i'playerbudget_o part3`i'playerbudget_s) (RE_other`i' RE_self`i')
}


* crosswalk id to code
sort code 
gen id =_n

preserve
keep code id
save "$path/1_data/1_rawdata/swissuni/rho/2_code_id_CW.dta", replace
restore

reshape long RE_self  RE_other, i(code) j(PR)

* change to price ratio of p_o/ p_s, see Design and Procedures's section A of Fisman, R., S. Kariv, and D. Markovits, “Individual Preferences for Giving,” American Economic Review
replace PR =1/3 if PR ==1
replace PR =1/2 if PR ==3 
replace PR =3 if PR ==2
replace PR =2 if PR ==4
replace PR =1 if PR ==5
replace PR =1/4 if PR ==6
replace PR =4 if PR ==7
replace PR =5/4 if PR ==8
replace PR =4/5 if PR ==9
replace PR =5/2 if PR ==10
replace PR =2/5 if PR ==11
replace PR =5 if PR ==12
replace PR =1/5 if PR ==13
replace PR =5/3 if PR ==14
replace PR =3/5 if PR ==15

order id RE_self RE_other PR
keep id RE_self RE_other PR

outsheet id - PR using "$path/1_data/1_rawdata/swissuni/rho/3_input_matlab.csv", comma nolabel replace




