clear all

global out_path "$path/3_out" 
cd "$path/1_data/4_temp"

numlabel, add
* short code to save reg coeffs
do "$path/2_do/2_analysis/0_reg_fnc/0_regressions.do" // 2 tailed 
do "$path/2_do/2_analysis/0_reg_fnc/0_regressions_1t_+.do" // 1 tailed if sign_female>0
do "$path/2_do/2_analysis/0_reg_fnc/0_regressions_1t_-.do" // 1 tailed if sign_female<0

local gender_measures std_tmf_score std_magliozzi_fem std_magliozzi_mas std_wangnerud_fem std_wangnerud_mas std_osri_fem std_osri_mas std_cfni_score std_cmni_score std_bsri_fem std_bsri_masc
local variables redistribution competitiveness hypothetical_risk incentivized_risk donation major_share homemaker income_cont yearly_work_hours negot_yes manager financial_market
local variables redistribution competitiveness hypothetical_risk incentivized_risk major_share homemaker income_cont yearly_work_hours_weeklyaverage negot_yes manager financial_market // no donation 


***************** std_cgi_main vs std_tmf_score *****************
***************** std_cgi_main vs std_cfni_score *****************
local measure tmf cfni
foreach m of local measure{
local i=1
foreach v of local variables {
preserve
use "$path/1_data/2_prepared/1_usadults_w2_20_60.dta", replace	
drop if `v'==.
drop if std_`m'_score==.

* Restandardize cgi as it was standardized for wave1 and wave2 together.	
	drop std_cgi_main 
	
	qui su cgi_main
	qui gen std_cgi_main=(cgi_main-r(mean))/r(sd)
	
	drop std_`m'_score
	qui su `m'_score
	gen  std_`m'_score=(`m'_score-r(mean))/r(sd)
	
	if inlist("`v'", "redistribution", "hypothetical_risk", "incentivized_risk", "competitiveness") {
		qui su `v' if std_`m'_score!=.
		replace `v'=(`v'-r(mean))/r(sd) // restandardization of these variables
	}
	
*-----------------------------------------------------------------------------
* Panel A : Binary Sex
*-----------------------------------------------------------------------------
	 reg `v' female, vce(hc3)
	
		**** save coeff and se to be used for p value meta analysis ***
		gen beta_a = _b[female]
		gen se_a = _se[female]
		local sign_female = sign(_b[female])
		
		**** save R2 to be used for R2 meta analysis ***
		gen rsqua = e(r2)
		gen adjrsqua = e(r2_a)

*-----------------------------------------------------------------------------
* Panel C : Binary Sex and Continuous Gender - CGI 
*-----------------------------------------------------------------------------
	qui reg `v' female std_cgi_main, vce(hc3)
	
		**** save coeff and se to be used for p value meta analysis ***
		gen beta_c_CGI = _b[std_cgi_main]
		gen se_c_CGI = _se[std_cgi_main]
		
		test _b[std_cgi_main]=0 
		local sign_cgi = sign(_b[std_cgi_main])

		if `sign_female'>=0 {
		gen p_c_CGI = ttail(r(df_r),`sign_cgi'*sqrt(r(F))) // Ho: coef <= 0
		}
		if `sign_female'<=0 {
		gen p_c_CGI = 1-ttail(r(df_r),`sign_cgi'*sqrt(r(F))) // Ho: coef >= 0
		}

		**** save R2 to be used for R2 meta analysis ***
		gen rsquc_CGI = e(r2)
		gen adjrsquc_CGI = e(r2_a)

*-----------------------------------------------------------------------------
* Panel C : Binary Sex and Continuous Gender - `m'
*-----------------------------------------------------------------------------
	    qui reg `v' female std_`m'_score, vce(hc3)

		**** save coeff and se to be used for p value meta analysis ***
		gen beta_c_`m' = _b[std_`m'_score]
		gen se_c_`m' = _se[std_`m'_score]
			
		test _b[std_`m'_score]=0 
		local sign_`m' = sign(_b[std_`m'_score])
		
		if `sign_female'>0 {
		gen p_c_`m' = ttail(r(df_r),`sign_`m''*sqrt(r(F))) // Ho: coef <= 0
		}
		if `sign_female'<0 {
		gen p_c_`m' = 1-ttail(r(df_r),`sign_`m''*sqrt(r(F))) // Ho: coef >= 0
		}
		
		**** save R2 to be used for R2 meta analysis ***
		gen rsquc_`m' = e(r2)
		gen adjrsquc_`m' = e(r2_a)
		
		**** Save N ****
        local N_`m': di %11.0gc e(N)

*-----------------------------------------------------------------------------
* Store the pvals
*-----------------------------------------------------------------------------
keep if _n==1
keep beta_* se_* p_* rsqu* adjrsqu* 
xpose, clear varname
rename _varname parameter
rename v1 value
gen variable="`v'"
gen variable_order=`i'
tempfile `v'
qui save `v', replace
local i=`i'+1
restore
}

clear
foreach v of local variables {
append using `v'
}
tempfile `m'
save `m', replace

preserve
keep if parameter=="p_c_CGI" | parameter=="p_c_`m'"
rename value p_val
gen measure=""
replace measure="CGI" if parameter=="p_c_CGI"
replace measure="`m'" if parameter=="p_c_`m'"

save "$path/1_data/5_meta/4_pval_other/`m'.dta", replace 
restore 

*-----------------------------------------------------------------------------
* Store R2
*-----------------------------------------------------------------------------
preserve
keep if parameter=="rsqua" 
drop parameter
rename value rsqua
tempfile rsqua
save `rsqua'
restore

preserve
keep if parameter=="rsquc_CGI" | parameter=="rsquc_`m'"
rename value rsquc
merge m:1 variable using `rsqua', assert(3) nogen
gen measure=""
replace measure="CGI" if parameter=="rsquc_CGI"
replace measure="`m'" if parameter=="rsquc_`m'"
gen increase_R2=rsquc-rsqua
assert increase_R2>0
restore 

save "$path/1_data/5_meta/5_R2_other/`m'.dta", replace 

}

***************** std_cgi_main vs std_cmni_score *****************
local measure  cmni 
clear
foreach m of local measure{
local i=1
foreach v of local variables {
preserve
use "$path/1_data/2_prepared/1_usadults_w2_20_60.dta", replace	
drop if `v'==.
drop if std_`m'_score==.

* Restandardize cgi as it was standardized for wave1 and wave2 together.
	drop std_cgi_main 
	
	qui su cgi_main
	qui gen std_cgi_main=(cgi_main-r(mean))/r(sd)
	
	drop std_`m'_score
	qui su `m'_score
	gen  std_`m'_score=(`m'_score-r(mean))/r(sd)
	
	
	if inlist("`v'", "redistribution", "hypothetical_risk", "incentivized_risk") {
		qui su `v'
		replace `v'=(`v'-r(mean))/r(sd) // standardization of these variables
	}
	
	drop if std_`m'_score==.
	
*-----------------------------------------------------------------------------
* Panel A : Binary Sex
*-----------------------------------------------------------------------------
	 qui  reg `v' female, vce(hc3)
	
		**** save coeff and se to be used for p value meta analysis ***
		gen beta_a = _b[female]
		gen se_a = _se[female]
		gen p_a=2*ttail(e(df_r),abs(_b[female]/_se[female]))
		local sign_female = sign(_b[female])
		
		**** save R2 to be used for R2 meta analysis ***
		gen rsqua = e(r2)
		gen adjrsqua = e(r2_a)

*-----------------------------------------------------------------------------
* Panel C : Binary Sex and Continuous Gender - CGI 
*-----------------------------------------------------------------------------
	qui reg `v' female std_cgi_main, vce(hc3)
	
		**** save coeff and se to be used for p value meta analysis ***
		gen beta_c_CGI = _b[std_cgi_main]
		gen se_c_CGI = _se[std_cgi_main]
		//gen p_c_CGI=2*ttail(e(df_r),abs(_b[std_cgi_main]/_se[std_cgi_main]))
		
		test _b[std_cgi_main]=0 
		local sign_cgi = sign(_b[std_cgi_main])

		if `sign_female'>0 {
		gen p_c_CGI = ttail(r(df_r),`sign_cgi'*sqrt(r(F))) // Ho: coef <= 0
		}
		if `sign_female'<0 {
		gen p_c_CGI = 1-ttail(r(df_r),`sign_cgi'*sqrt(r(F))) // Ho: coef >= 0
		}

		**** save R2 to be used for R2 meta analysis ***
		gen rsquc_CGI = e(r2)
		gen adjrsquc_CGI = e(r2_a)

*-----------------------------------------------------------------------------
* Panel C : Binary Sex and Continuous Gender - `m'
*-----------------------------------------------------------------------------
	 qui reg `v' female std_`m'_score, vce(hc3)
	
		**** save coeff and se to be used for p value meta analysis ***
		gen beta_c_`m' = _b[std_`m'_score]
		gen se_c_`m' = _se[std_`m'_score]
		//gen p_c_cfni=2*ttail(e(df_r),abs(_b[std_cfni_score]/_se[std_cfni_score]))
		
		**** save R2 to be used for R2 meta analysis ***
		gen rsquc_`m' = e(r2)
		gen adjrsquc_`m' = e(r2_a)
		
		test _b[std_`m'_score]=0 
		local sign_`m' = sign(_b[std_`m'_score])
		
		if `sign_female'<0 {
		gen p_c_`m'= ttail(r(df_r),`sign_`m''*sqrt(r(F))) // Ho: coef <= 0
		}
		if `sign_female'>0 {
		gen p_c_`m' = 1-ttail(r(df_r),`sign_`m''*sqrt(r(F))) // Ho: coef >= 0
		}
		di `sign_female'
		
		**** Save N ****
        local N_cfni: di %11.0gc e(N)
*-----------------------------------------------------------------------------
* Store the pvals
*-----------------------------------------------------------------------------
keep if _n==1
keep beta_* se_* p_* rsqu* adjrsqu* 

xpose, clear varname
rename _varname parameter
rename v1 value
gen variable="`v'"
gen variable_order=`i'
tempfile `v'
qui save `v', replace
local i=`i'+1
restore
}

clear
foreach v of local variables {
append using `v'
}
tempfile `m'
save `m', replace

preserve
keep if parameter=="p_c_CGI" | parameter=="p_c_`m'"
rename value p_val
gen measure=""
replace measure="CGI" if parameter=="p_c_CGI"
replace measure="`m'" if parameter=="p_c_`m'"

save "$path/1_data/5_meta/4_pval_other/`m'.dta", replace 
restore 


*-----------------------------------------------------------------------------
* Store R2
*-----------------------------------------------------------------------------
preserve
keep if parameter=="rsqua" 
drop parameter
rename value rsqua
tempfile rsqua
save `rsqua'
restore


keep if parameter=="rsquc_CGI" | parameter=="rsquc_`m'"
rename value rsquc
merge m:1 variable using `rsqua', assert(3) nogen
gen measure=""
replace measure="CGI" if parameter=="rsquc_CGI"
replace measure="`m'" if parameter=="rsquc_`m'"
gen increase_R2=rsquc-rsqua
assert increase_R2>0

save "$path/1_data/5_meta/5_R2_other/`m'.dta", replace 

}


***************** std_cgi_main vs std_magliozzi_fem, std_magliozzi_masc *****************
***************** std_cgi_main vs std_wangnerud_fem std_wangnerud_masc *****************
***************** std_cgi_main vs std_osri_fem std_osri_masc *****************
***************** std_cgi_main vs std_bsri_fem std_bsri_masc *****************
local measure magliozzi wangnerud osri bsri
foreach m of local measure {

clear
local i=1
foreach v of local variables {
preserve
use "$path/1_data/2_prepared/1_usadults_w2_20_60.dta", replace	
drop *_1 *_2 *_3 *_NPS_GROUP
drop if `v'==.
drop if std_`m'_fem==.
drop if std_`m'_mas==.

* Restandardize cgi as it was standardized for wave1 and wave2 together.
	drop std_cgi_main 
	
	qui su cgi_main
	qui gen std_cgi_main=(cgi_main-r(mean))/r(sd)
	
	drop std_`m'_fem
	qui su `m'_fem
	gen  std_`m'_fem=(`m'_fem-r(mean))/r(sd)
	
	drop std_`m'_masc
	qui su `m'_masc
	gen  std_`m'_masc=(`m'_masc-r(mean))/r(sd)
	
	
	if inlist("`v'", "redistribution", "hypothetical_risk", "incentivized_risk") {
		qui su `v'
		replace `v'=(`v'-r(mean))/r(sd) // standardization of these variables
	}
	
	drop if std_`m'_fem==. | std_`m'_masc==.
	
*-----------------------------------------------------------------------------
* Panel A : Binary Sex
*-----------------------------------------------------------------------------
	qui reg `v' female, vce(hc3)
	
		**** save coeff and se to be used for p value meta analysis ***
		gen beta_a = _b[female]
		gen se_a = _se[female]
		//gen p_a=2*ttail(e(df_r),abs(_b[female]/_se[female]))
		local sign_female = sign(_b[female])
		
		**** save R2 to be used for R2 meta analysis ***
		gen rsqua = e(r2)
		gen adjrsqua = e(r2_a)

*-----------------------------------------------------------------------------
* Panel C : Binary Sex and Continuous Gender - CGI 
*-----------------------------------------------------------------------------
	qui reg `v' female std_cgi_main, vce(hc3)
	
		**** save coeff and se to be used for p value meta analysis ***
		gen beta_c_CGI = _b[std_cgi_main]
		gen se_c_CGI = _se[std_cgi_main]
		//gen p_c_CGI=2*ttail(e(df_r),abs(_b[std_cgi_main]/_se[std_cgi_main]))
		
		test _b[std_cgi_main]=0 
		local sign_cgi = sign(_b[std_cgi_main])

		if `sign_female'>0 {
		gen p_c_CGI = ttail(r(df_r),`sign_cgi'*sqrt(r(F))) // Ho: coef <= 0
		}
		if `sign_female'<0 {
		gen p_c_CGI = 1-ttail(r(df_r),`sign_cgi'*sqrt(r(F))) // Ho: coef >= 0
		}
		
		**** save R2 to be used for R2 meta analysis ***
		gen rsquc_CGI = e(r2)
		gen adjrsquc_CGI = e(r2_a)

*-----------------------------------------------------------------------------
* Panel C : Binary Sex and Continuous Gender - std_`m'_fem
*-----------------------------------------------------------------------------
	qui reg `v' female std_`m'_fem, vce(hc3)
	
		**** save coeff and se to be used for p value meta analysis ***
		gen beta_c_`m'_fem = _b[std_`m'_fem]
		gen se_c_`m'_fem = _se[std_`m'_fem]
		//gen p_c_`m'_fem=2*ttail(e(df_r),abs(_b[std_`m'_fem]/_se[std_`m'_fem]))
		test _b[std_`m'_fem]=0 
		local sign_`m'_fem = sign(_b[std_`m'_fem])

		if `sign_female'>0 {
		gen p_c_`m'_fem= ttail(r(df_r),`sign_`m'_fem'*sqrt(r(F))) // Ho: coef <= 0
		}
		if `sign_female'<0 {
		gen p_c_`m'_fem = 1-ttail(r(df_r),`sign_`m'_fem'*sqrt(r(F))) // Ho: coef >= 0
		}
		
		**** save R2 to be used for R2 meta analysis ***
		gen rsquc_`m'_fem = e(r2)
		gen adjrsquc_`m'_fem = e(r2_a)
		
		**** Save N ****
        local N_`m'_fem: di %11.0gc e(N)

*-----------------------------------------------------------------------------
* Panel C : Binary Sex and Continuous Gender - std_`m'_masc
*-----------------------------------------------------------------------------
	qui reg `v' female std_`m'_masc, vce(hc3)
	
		**** save coeff and se to be used for p value meta analysis ***
		gen beta_c_`m'_masc = _b[std_`m'_masc]
		gen se_c_`m'_masc = _se[std_`m'_masc]
		//gen p_c_`m'_masc=2*ttail(e(df_r),abs(_b[std_`m'_masc]/_se[std_`m'_masc]))
		test _b[std_`m'_masc]=0 
		local sign_`m'_masc = sign(_b[std_`m'_masc])
		
		if `sign_female'<0 {
		gen p_c_`m'_masc= ttail(r(df_r),`sign_`m'_masc'*sqrt(r(F))) // Ho: coef <= 0
		}
		if `sign_female'>0 {
		gen p_c_`m'_masc = 1-ttail(r(df_r),`sign_`m'_masc'*sqrt(r(F))) // Ho: coef >= 0
		}		
		**** save R2 to be used for R2 meta analysis ***
		gen rsquc_`m'_masc = e(r2)
		gen adjrsquc_`m'_masc = e(r2_a)
		
		**** Save N ****
        local N_`m'_masc: di %11.0gc e(N)


*-----------------------------------------------------------------------------
* Store the pvals
*-----------------------------------------------------------------------------
keep if _n==1
keep beta_* se_* p_* rsqu* adjrsqu* 
xpose, clear varname
rename _varname parameter
rename v1 value
gen variable="`v'"
gen variable_order=`i'
tempfile `v'
qui save `v', replace
local i=`i'+1
restore
}

clear
foreach v of local variables {
append using `v'
}
tempfile `m'
save `m', replace

preserve
keep if parameter=="p_c_CGI" | parameter=="p_c_`m'_masc" | parameter=="p_c_`m'_fem"
rename value p_val
gen measure=""
replace measure="CGI" if parameter=="p_c_CGI"
replace measure="`m' masc" if parameter=="p_c_`m'_masc"
replace measure="`m' fem" if parameter=="p_c_`m'_fem"

save "$path/1_data/5_meta/4_pval_other/`m'.dta", replace 
restore 


*-----------------------------------------------------------------------------
* Store R2
*-----------------------------------------------------------------------------
preserve
keep if parameter=="rsqua" 
drop parameter
rename value rsqua
tempfile rsqua
save `rsqua'
restore

preserve
keep if parameter=="rsquc_CGI" | parameter=="rsquc_`m'_masc" | parameter=="rsquc_`m'_fem"
rename value rsquc
merge m:1 variable using `rsqua', assert(3) nogen
gen measure=""
replace measure="CGI" if parameter=="rsquc_CGI"
replace measure="`m' masc" if parameter=="rsquc_`m'_masc"
replace measure="`m' fem" if parameter=="rsquc_`m'_fem"

gen increase_R2=rsquc-rsqua
assert increase_R2>0

save "$path/1_data/5_meta/5_R2_other/`m'.dta", replace 

restore
}


***************** std_cgi_main vs std_cgi_other vs std_cgi_own vs std_cgi_opposite *****************
clear
local i=1
foreach v of local variables {
	preserve
use "$path/1_data/2_prepared/1_usadults_w2_20_60.dta", replace	

drop if `v'==.
* Restandardize cgi as it was standardized for wave1 and wave2 together.
drop if std_cgi_main==. | std_cgi_other==. | std_cgi_own==. | std_cgi_opposite==. //0 obs deleted

	drop std_cgi_main std_cgi_other std_cgi_own
	
	qui su cgi_main
	qui gen std_cgi_main=(cgi_main-r(mean))/r(sd)
	
	qui su cgi_other
	qui gen std_cgi_other=(cgi_other-r(mean))/r(sd)
	
	qui su cgi_own
	qui gen std_cgi_own=(cgi_own-r(mean))/r(sd)
	

	if inlist("`v'", "redistribution", "hypothetical_risk", "incentivized_risk") {
		qui su `v'
		replace `v'=(`v'-r(mean))/r(sd) // standardization of these variables
	}
*-----------------------------------------------------------------------------
* Panel A : Binary Sex
*-----------------------------------------------------------------------------
	qui reg `v' female, vce(hc3)
	
		**** save coeff and se to be used for p value meta analysis ***
		gen beta_a = _b[female]
		gen se_a = _se[female]
		//gen p_a=2*ttail(e(df_r),abs(_b[female]/_se[female]))
		local sign_female = sign(_b[female])
		
		**** save R2 to be used for R2 meta analysis ***
		gen rsqua = e(r2)
		gen adjrsqua = e(r2_a)

local measure main other own //opposite
foreach m of local measure{
*-----------------------------------------------------------------------------
* Panel C : Binary Sex and Continuous Gender - CGI 
*-----------------------------------------------------------------------------
	qui reg `v' female std_cgi_`m', vce(hc3)
	
		**** save coeff and se to be used for p value meta analysis ***
		gen beta_c_cgi_`m' = _b[std_cgi_`m']
		gen se_c_cgi_`m' = _se[std_cgi_`m']
		//gen p_c_CGI=2*ttail(e(df_r),abs(_b[std_cgi_main]/_se[std_cgi_main]))
		
		test _b[std_cgi_`m']=0 
		local sign_cgi_`m' = sign(_b[std_cgi_`m'])

		if `sign_female'>0 {
		gen p_c_cgi_`m' = ttail(r(df_r),`sign_cgi_`m''*sqrt(r(F))) // Ho: coef <= 0
		}
		if `sign_female'<0 {
		gen p_c_cgi_`m' = 1-ttail(r(df_r),`sign_cgi_`m''*sqrt(r(F))) // Ho: coef >= 0
		}
		
		**** save R2 to be used for R2 meta analysis ***
		gen rsquc_cgi_`m' = e(r2)
		gen adjrsquc_cgi_`m' = e(r2_a)
}

*-----------------------------------------------------------------------------
* Store the pvals
*-----------------------------------------------------------------------------
keep if _n==1
keep beta_* se_* p_* rsqu* adjrsqu* 
xpose, clear varname
rename _varname parameter
rename v1 value
gen variable="`v'"
gen variable_order=`i'
tempfile `v'
qui save `v', replace
local i=`i'+1
restore
}

clear
foreach v of local variables {
append using `v'
}
tempfile CGI
save `CGI', replace

preserve
keep if parameter=="p_c_cgi_main" | parameter=="p_c_cgi_other" | parameter=="p_c_cgi_own" | parameter=="p_c_cgi_opposite"
rename value p_val
gen measure=""
replace measure="CGI" if parameter=="p_c_cgi_main"
replace measure="CGI (other)" if parameter=="p_c_cgi_other"
replace measure="CGI (own)" if parameter=="p_c_cgi_own"
replace measure="CGI (opp)" if parameter=="p_c_cgi_opposite"

save "$path/1_data/5_meta/4_pval_other/cgi.dta", replace 
restore 

*-----------------------------------------------------------------------------
* Store R2
*-----------------------------------------------------------------------------
preserve
keep if parameter=="rsqua" 
drop parameter
rename value rsqua
tempfile rsqua
save `rsqua'
restore

preserve
keep if parameter=="rsquc_cgi_main" | parameter=="rsquc_cgi_other" | parameter=="rsquc_cgi_own" | parameter=="rsquc_cgi_opposite"
rename value rsquc
merge m:1 variable using `rsqua', assert(3) nogen
gen measure=""
replace measure="CGI" if parameter=="rsquc_cgi"
replace measure="CGI (other)" if parameter=="rsquc_cgi_other"
replace measure="CGI (own)" if parameter=="rsquc_cgi_own"

gen increase_R2=rsquc-rsqua
assert increase_R2>0
save "$path/1_data/5_meta/5_R2_other/`m'.dta", replace 

restore

* Delete temp files 
clear 

foreach v of local variables {
erase "`v'.dta"
}

local GI tmf magliozzi wangnerud osri cfni cmni bsri 
foreach g of local GI {
erase  "`g'.dta"
}

clear 
local GI tmf magliozzi wangnerud osri cfni cmni bsri cgi
foreach g of local GI {
append using "$path/1_data/5_meta/4_pval_other/`g'.dta" //this is to be used as a sanity check for the results that we obtain from 7_other_GI
}

save "$path/1_data/5_meta/4_pval_other/sanitycheck_4pval.dta", replace


