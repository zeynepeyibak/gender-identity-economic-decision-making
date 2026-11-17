clear all

global out_path "$path/3_out" 
		
local tableid "table_4"
local colno "10" 

* short code to save reg coeffs
do "$path/2_do/2_analysis/0_reg_fnc/0_regressions.do" // 2 tailed 
do "$path/2_do/2_analysis/0_reg_fnc/0_regressions_1t_+.do" // 1 tailed if sign_female>0
do "$path/2_do/2_analysis/0_reg_fnc/0_regressions_1t_-.do" // 1 tailed if sign_female<0




/*
Column 1: Staircase Risk - Swiss Uni
Column 2: Hypothetical Risk - Swiss Uni
Column 3: Hypothetical Risk - US adults
Column 4: Hypothetical Risk - Swiss Teens
Column 5: Hypothetical Risk - Swedish Youth
Column 6: Financial Risk - US Adults
Column 7: Competitiveness - Swiss Uni
Column 8: Competitiveness - US Adults
Column 9: Competitiveness - Swiss Teens
Column 10: Competitiveness - Swedish Youth
*/


*-----------------------------------------------------------------------------
* Import the data
*-----------------------------------------------------------------------------
forvalues z =1/2{ 

forvalues i=1/10{ 
	if `i'==1| `i'==2 | `i'==7{
		use "$path/1_data/2_prepared/1_SwissUni.dta", clear
		local controls "c.age##c.age educ_control"
	}	
	if `i'==3 | `i'==6 | `i'==8{
		use "$path/1_data/2_prepared/1_usadults_w1_w2_30_60.dta", clear
		local controls "c.age##c.age black all_other_races i.division wave1"
		
		* Restandardize std_cgi_main as it was standardized for age 20-60.
		drop std_cgi_main
		qui su cgi_main
		qui gen std_cgi_main=(cgi_main-r(mean))/r(sd)
		
		drop std_hyp_risk
		qui su hypothetical_risk
		qui gen std_hyp_risk=(hypothetical_risk-r(mean))/r(sd)
		
		drop std_competitiveness
		qui su competitiveness
		qui gen std_competitiveness=(competitiveness-r(mean))/r(sd)
	}
	if `i'==4 | `i'==9{
		use "$path/1_data/2_prepared/1_swissteens.dta", clear
		local controls "grade_8 grade_9 march_survey"
	}
	if `i'==5 | `i'==10{
		use "$path/1_data/2_prepared/1_Swedishyouth.dta", clear
		local controls "i.school_new"
	}
	
*-----------------------------------------------------------------------------
* Sanity checks with standardizations before we start the regression analysis
*-----------------------------------------------------------------------------
		if `i'==1{
		qui su std_staircase_risk 
		assert round(r(mean),0.0001)==0
		}	
		if `i'==2 |`i'==3 |`i'==4 |`i'==5 {
		qui su std_hyp_risk 
		assert round(r(mean),0.0001)==0
		}			
		if `i'==7 | `i'==8 |`i'==9 |`i'==10{
		qui su std_competitiveness 
		assert round(r(mean),0.0001)==0 
		}
		
		
		if `i'==1{
		qui su std_cgi_main if std_staircase_risk!=.
		assert round(r(mean),0.0001)==0
		}	
		if `i'==2 {
		qui su std_cgi_main if  std_hyp_risk!=.
		assert round(r(mean),0.0001)==0
		}	
		if `i'==3  {
		qui su std_cgi_main if std_hyp_risk!=.
		assert round(r(mean),0.0001)==0
		}	
		if `i'==4  {
		qui su std_cgi_main if std_hyp_risk!=.
		//assert round(r(mean),0.0001)==0
		
		drop std_cgi_main
		qui su cgi_main if std_hyp_risk!=.
		gen std_cgi_main=(cgi_main-r(mean))/r(sd)
		
		qui su std_cgi_main if std_hyp_risk!=.
		assert round(r(mean),0.0001)==0
		}
		if `i'==5 {
		qui su std_cgi_main if std_hyp_risk!=.
		assert round(r(mean),0.0001)==0		
		}	
		if `i'==6 {
		qui su std_cgi_main if financial_market!=.
		assert round(r(mean),0.0001)==0
		}	
		if `i'==7 {
		qui su std_cgi_main if std_competitiveness!=.
		assert round(r(mean),0.0001)==0		
		}
		if  `i'==8 {
		qui su std_cgi_main if std_competitiveness!=.
		assert round(r(mean),0.0001)==0		
		}
		if `i'==9{
		qui su std_cgi_main if std_competitiveness!=.
		//assert round(r(mean),0.0001)==0		
		
		drop std_cgi_main
		qui su cgi_main if std_competitiveness!=.
		gen std_cgi_main=(cgi_main-r(mean))/r(sd)
		
		qui su std_cgi_main if std_competitiveness!=.
		assert round(r(mean),0.0001)==0
		}		
		if `i'==10{
		qui su std_cgi_main if std_competitiveness!=.
		assert round(r(mean),0.0001)==0
		}


*-----------------------------------------------------------------------------
* Panel A: biological gender	 
*-----------------------------------------------------------------------------
	if `z'== 1 { //no controls
		if `i'==1{
		qui reg std_staircase_risk female, vce(hc3) 
		}	
		if `i'==2 |`i'==3 |`i'==4 |`i'==5 {
		qui reg std_hyp_risk female, vce(hc3) 
		}		
		if `i'==6 {
		qui reg financial_market female, vce(hc3)
		}		
		if `i'==7 | `i'==8 |`i'==9 |`i'==10{
		qui reg std_competitiveness female, vce(hc3) 
		}
	}	
	if `z' ==2 {// with controls      
		if `i'==1{
		qui reg std_staircase_risk female `controls', vce(hc3) 
		}	
		if `i'==2 |`i'==3 |`i'==4 |`i'==5 {
		qui reg std_hyp_risk female `controls', vce(hc3) 
		}		
		if `i'==6 {
		qui reg financial_market female `controls', vce(hc3)
		}		
		if `i'==7 | `i'==8 |`i'==9 |`i'==10{
		qui reg std_competitiveness female `controls', vce(hc3) 
		}
	}		
	
		* Store the results	
		beta_coeff2 female 
		local beta_a_sex_`i' `r(beta)'
		local se_a_sex_`i' `r(se)'
		local rsqua_`i': di %6.3f `e(r2)'
		local rsqua_`i' = trim("$`rsqua_`i''$")
		
		**** save R2 to be used for R2 meta analysis ***
		local rsqua_`i'_meta = e(r2)
		local adjrsqua_`i'_meta = e(r2_a)
		
		local sign_female = sign(_b[female])

*-----------------------------------------------------------------------------				
* Panel B: cgi	 
*-----------------------------------------------------------------------------
	if `z'== 1 { //no controls
		if `i'==1{
		qui reg std_staircase_risk std_cgi_main, vce(hc3) 
		}	
		if `i'==2 |`i'==3 |`i'==4 |`i'==5 {
		qui reg std_hyp_risk std_cgi_main, vce(hc3) 
		}		
		if `i'==6 {
		qui reg financial_market std_cgi_main, vce(hc3)
		}		
		if `i'==7 | `i'==8 |`i'==9 |`i'==10{
		qui reg std_competitiveness std_cgi_main, vce(hc3) 
		}
	}		
	if `z' ==2{ // with controls
		if `i'==1{
		qui reg std_staircase_risk std_cgi_main `controls', vce(hc3) 
		}	
		if `i'==2 |`i'==3 |`i'==4 |`i'==5 {
		qui reg std_hyp_risk std_cgi_main `controls', vce(hc3) 
		}		
		if `i'==6 {
		qui reg financial_market std_cgi_main `controls', vce(hc3)
		}		
		if `i'==7 | `i'==8 |`i'==9 |`i'==10{
		qui reg std_competitiveness std_cgi_main `controls', vce(hc3) 
		}
	}			
	    * Save estimates
        local rsqub_`i': di %6.3f e(r2)
		local rsqub_`i' = trim("$`rsqub_`i''$")
		
		if `sign_female'>0 {
			beta_coeff1_pos std_cgi_main 
			local beta_b_cgi_`i' `r(beta)'
			local se_b_cgi_`i' `r(se)'
		}
		
		if `sign_female'<0 {
			beta_coeff1_neg std_cgi_main 
			local beta_b_cgi_`i' `r(beta)'
			local se_b_cgi_`i' `r(se)'
		}

*-----------------------------------------------------------------------------				
* Panel C: biological gender and cgi 
*-----------------------------------------------------------------------------				
	if `z'== 1 { //no controls
		if `i'==1{
		qui reg std_staircase_risk female std_cgi_main, vce(hc3) 
		}	
		if `i'==2 |`i'==3 |`i'==4 |`i'==5 {
		qui reg std_hyp_risk female std_cgi_main, vce(hc3) 
		}		
		if `i'==6 {
		qui reg financial_market female std_cgi_main, vce(hc3)
		}		
		if `i'==7 | `i'==8 |`i'==9 |`i'==10{
		qui reg std_competitiveness female std_cgi_main, vce(hc3) 
		}
	}	

if `z' ==2{
		if `i'==1{
		qui reg std_staircase_risk female std_cgi_main `controls', vce(hc3) 
		}	
		if `i'==2 |`i'==3 |`i'==4 |`i'==5 {
		qui reg std_hyp_risk female std_cgi_main `controls', vce(hc3) 
		}		
		if `i'==6 {
		qui reg financial_market female std_cgi_main `controls', vce(hc3)
		}		
		if `i'==7 | `i'==8 |`i'==9 |`i'==10{
		qui reg std_competitiveness female std_cgi_main `controls', vce(hc3) 
		}
}	

	    ** Save estimates to be used in reg table
        local N_`i': di %11.0gc e(N)
        local rsquc_`i': di %6.3f e(r2)
		local rsquc_`i' = trim("$`rsquc_`i''$")
		

		if `sign_female'>0 {
			beta_coeff1_pos female		
			local beta_c_sex_`i' `r(beta)'
			local se_c_sex_`i' `r(se)'		
			
			beta_coeff1_pos std_cgi_main 
			local beta_c_cgi_`i' `r(beta)'
			local se_c_cgi_`i' `r(se)'
		}
		
		if `sign_female'<0 {
			beta_coeff1_neg female
			local beta_c_sex_`i' `r(beta)'
			local se_c_sex_`i' `r(se)'		
			
			beta_coeff1_neg std_cgi_main 
			local beta_c_cgi_`i' `r(beta)'
			local se_c_cgi_`i' `r(se)'
		}
		
		** save estimates to be used in meta analysis
		local beta_c_cgi_`i'_meta = _b[std_cgi_main]
		local se_c_cgi_`i'_meta = _se[std_cgi_main]
		local p_c_cgi_`i'_meta=2*ttail(e(df_r),abs(_b[std_cgi_main]/_se[std_cgi_main]))
		
			* save 1 tailed version
			qui test _b[std_cgi_main]=0 
			local sign_cgi = sign(_b[std_cgi_main])
			
			if `sign_female'>0 {
			local p_c_cgi_`i'_meta_1t = ttail(r(df_r),`sign_cgi'*sqrt(r(F))) // Ho: coef <= 0
			}
			if `sign_female'<0 {
			local p_c_cgi_`i'_meta_1t = 1-ttail(r(df_r),`sign_cgi'*sqrt(r(F))) // Ho: coef >= 0
			}
		
			* save R2 to be used for R2 meta analysis ***
			local rsquc_`i'_meta = e(r2)
			local adjrsquc_`i'_meta = e(r2_a)
		
*-----------------------------------------------------------------------------				
* Panel D: cgi for males and cgi for females
*-----------------------------------------------------------------------------				
* Panel D for females: 
preserve
keep if female==1

		if `i'==1{
		drop std_staircase_risk 
		qui su staircase_risk 
		qui gen std_staircase_risk =(staircase_risk-r(mean))/r(sd)		
		
		qui su std_staircase_risk
		assert round(r(mean),0.0001)==0

		}	
		if `i'==2 |`i'==3 |`i'==4 |`i'==5 {
		drop std_hyp_risk 
		qui su hypothetical_risk 
		qui gen std_hyp_risk  =(hypothetical_risk -r(mean))/r(sd)	
		
		qui su std_hyp_risk 
		assert round(r(mean),0.0001)==0
		}			
		
		if `i'==7 | `i'==8 |`i'==9 |`i'==10{
		drop std_competitiveness 
		qui su competitiveness
		qui gen std_competitiveness =(competitiveness -r(mean))/r(sd)	
		
		qui su std_competitiveness 
		assert round(r(mean),0.0001)==0 
		}
		
		
		if `i'==1{
		drop std_cgi_main
		qui su cgi_main if std_staircase_risk!=.
		gen std_cgi_main=(cgi_main-r(mean))/r(sd)
		
		qui su std_cgi_main if std_staircase_risk!=.
		assert round(r(mean),0.0001)==0
		}	
		if `i'==2 {	
		drop std_cgi_main
		qui su cgi_main if std_hyp_risk!=.
		gen std_cgi_main=(cgi_main-r(mean))/r(sd)
		
		qui su std_cgi_main if  std_hyp_risk!=.
		assert round(r(mean),0.0001)==0
		}	
		if `i'==3  {
		drop std_cgi_main
		qui su cgi_main if std_hyp_risk!=.
		gen std_cgi_main=(cgi_main-r(mean))/r(sd)
		
		qui su std_cgi_main if std_hyp_risk!=.
		assert round(r(mean),0.0001)==0
		}	
		
		if `i'==4  {
		drop std_cgi_main
		qui su cgi_main if std_hyp_risk!=.
		gen std_cgi_main=(cgi_main-r(mean))/r(sd)
		
		qui su std_cgi_main if std_hyp_risk!=.
		assert round(r(mean),0.0001)==0
		}
		if `i'==5 {
		drop std_cgi_main
		qui su cgi_main if std_hyp_risk!=.
		gen std_cgi_main=(cgi_main-r(mean))/r(sd)
		
		qui su std_cgi_main if std_hyp_risk!=.
		assert round(r(mean),0.0001)==0		
		}	
		if `i'==6 {
		drop std_cgi_main
		qui su cgi_main if financial_market!=.
		gen std_cgi_main=(cgi_main-r(mean))/r(sd)
		
		qui su std_cgi_main if financial_market!=.
		assert round(r(mean),0.0001)==0
		}	
		
		if `i'==7 {
		drop std_cgi_main
		qui su cgi_main if std_competitiveness!=.
		gen std_cgi_main=(cgi_main-r(mean))/r(sd)
		
		qui su std_cgi_main if std_competitiveness!=.
		assert round(r(mean),0.0001)==0		
		}
		
		if  `i'==8 {
		drop std_cgi_main
		qui su cgi_main if std_competitiveness!=.
		gen std_cgi_main=(cgi_main-r(mean))/r(sd)
		
		qui su std_cgi_main if std_competitiveness!=.
		assert round(r(mean),0.0001)==0		
		}
		if `i'==9{
		drop std_cgi_main
		qui su cgi_main if std_competitiveness!=.
		gen std_cgi_main=(cgi_main-r(mean))/r(sd)
		
		qui su std_cgi_main if std_competitiveness!=.
		assert round(r(mean),0.0001)==0
		}		
		if `i'==10{
		drop std_cgi_main
		qui su cgi_main if std_competitiveness!=.
		gen std_cgi_main=(cgi_main-r(mean))/r(sd)
		
		qui su std_cgi_main if std_competitiveness!=.
		assert round(r(mean),0.0001)==0
		}

	* Drop schools with only one student in this subsample: leverage = 1 breaks HC3.
	* The CGI coefficient is unchanged (the school dummy fits that student perfectly).
	if `z'==2 & "`controls'"=="i.school_new" {
		bysort school_new: drop if _N==1
	}
	
	if `z'== 1 { //no controls
		if `i'==1{
		qui reg std_staircase_risk std_cgi_main if female ==1, vce(hc3) 
		}	
		if `i'==2 |`i'==3 |`i'==4 |`i'==5 {
		qui reg std_hyp_risk std_cgi_main if female ==1, vce(hc3) 
		}		
		if `i'==6 {
		qui reg financial_market std_cgi_main if female ==1, vce(hc3)
		}		
		if `i'==7 | `i'==8 |`i'==9 |`i'==10{
		qui reg std_competitiveness std_cgi_main if female ==1, vce(hc3) 
		}
	}	

if `z' ==2{
		if `i'==1{
		qui reg std_staircase_risk std_cgi_main `controls' if female ==1, vce(hc3) 
		}	
		if `i'==2 |`i'==3 |`i'==4 |`i'==5 {
		qui reg std_hyp_risk std_cgi_main `controls' if female ==1, vce(hc3) 
		}		
		if `i'==6 {
		qui reg financial_market std_cgi_main `controls' if female ==1, vce(hc3)
		}		
		if `i'==7 | `i'==8 |`i'==9 |`i'==10{
		qui reg std_competitiveness std_cgi_main `controls' if female ==1, vce(hc3) 
		}
}	

		 ** Save estimates to be used in reg table
		local rsquf_`i': di %6.3f `e(r2)'
		local rsquf_`i' = trim("$`rsquf_`i''$")

		if `sign_female'>0 {
			beta_coeff1_pos std_cgi_main 
			local beta_f_cgi_`i' `r(beta)'
			local se_f_cgi_`i' `r(se)'
			
		}
		
		if `sign_female'<0 {
			beta_coeff1_neg std_cgi_main 
			local beta_f_cgi_`i' `r(beta)'
			local se_f_cgi_`i' `r(se)'
		}
		
		** save estimates to be used in meta analysis
		local beta_f_cgi_`i'_meta = _b[std_cgi_main]
		local se_f_cgi_`i'_meta = _se[std_cgi_main]
		local p_f_cgi_`i'_meta=2*ttail(e(df_r),abs(_b[std_cgi_main]/_se[std_cgi_main]))
		
			* save 1 tailed version
			qui test _b[std_cgi_main]=0 
			local sign_cgi = sign(_b[std_cgi_main])
			
			if `sign_female'>0 {
			local p_f_cgi_`i'_meta_1t = ttail(r(df_r),`sign_cgi'*sqrt(r(F))) // Ho: coef <= 0
			}
			if `sign_female'<0 {
			local p_f_cgi_`i'_meta_1t = 1-ttail(r(df_r),`sign_cgi'*sqrt(r(F))) // Ho: coef >= 0
			}
			
			* save R2 to be used for R2 meta analysis ***
			local rsquf_`i'_meta = e(r2)
			local adjrsquf_`i'_meta = e(r2_a)

restore

* Panel D for males: 
preserve
keep if female==0
		if `i'==1{
		drop std_staircase_risk 
		qui su staircase_risk 
		qui gen std_staircase_risk =(staircase_risk-r(mean))/r(sd)		
		
		qui su std_staircase_risk
		assert round(r(mean),0.0001)==0

		}	
		if `i'==2 |`i'==3 |`i'==4 |`i'==5 {
		drop std_hyp_risk 
		qui su hypothetical_risk 
		qui gen std_hyp_risk  =(hypothetical_risk -r(mean))/r(sd)	
		
		qui su std_hyp_risk 
		assert round(r(mean),0.0001)==0
		}			
		
		if `i'==7 | `i'==8 |`i'==9 |`i'==10{
		drop std_competitiveness 
		qui su competitiveness
		qui gen std_competitiveness =(competitiveness -r(mean))/r(sd)	
		
		qui su std_competitiveness 
		assert round(r(mean),0.0001)==0 
		}
		
		
		if `i'==1{
		drop std_cgi_main
		qui su cgi_main if std_staircase_risk!=.
		gen std_cgi_main=(cgi_main-r(mean))/r(sd)
		
		qui su std_cgi_main if std_staircase_risk!=.
		assert round(r(mean),0.0001)==0
		}	
		if `i'==2 {	
		drop std_cgi_main
		qui su cgi_main if std_hyp_risk!=.
		gen std_cgi_main=(cgi_main-r(mean))/r(sd)
		
		qui su std_cgi_main if  std_hyp_risk!=.
		assert round(r(mean),0.0001)==0
		}	
		if `i'==3  {
		drop std_cgi_main
		qui su cgi_main if std_hyp_risk!=.
		gen std_cgi_main=(cgi_main-r(mean))/r(sd)
		
		qui su std_cgi_main if std_hyp_risk!=.
		assert round(r(mean),0.0001)==0
		}	
		
		if `i'==4  {
		drop std_cgi_main
		qui su cgi_main if std_hyp_risk!=.
		gen std_cgi_main=(cgi_main-r(mean))/r(sd)
		
		qui su std_cgi_main if std_hyp_risk!=.
		assert round(r(mean),0.0001)==0
		}
		if `i'==5 {
		drop std_cgi_main
		qui su cgi_main if std_hyp_risk!=.
		gen std_cgi_main=(cgi_main-r(mean))/r(sd)
		
		qui su std_cgi_main if std_hyp_risk!=.
		assert round(r(mean),0.0001)==0		
		}	
		if `i'==6 {
		drop std_cgi_main
		qui su cgi_main if financial_market!=.
		gen std_cgi_main=(cgi_main-r(mean))/r(sd)
		
		qui su std_cgi_main if financial_market!=.
		assert round(r(mean),0.0001)==0
		}	
		
		if `i'==7 {
		drop std_cgi_main
		qui su cgi_main if std_competitiveness!=.
		gen std_cgi_main=(cgi_main-r(mean))/r(sd)
		
		qui su std_cgi_main if std_competitiveness!=.
		assert round(r(mean),0.0001)==0		
		}
		
		if  `i'==8 {
		drop std_cgi_main
		qui su cgi_main if std_competitiveness!=.
		gen std_cgi_main=(cgi_main-r(mean))/r(sd)
		
		qui su std_cgi_main if std_competitiveness!=.
		assert round(r(mean),0.0001)==0		
		}
		if `i'==9{
		drop std_cgi_main
		qui su cgi_main if std_competitiveness!=.
		gen std_cgi_main=(cgi_main-r(mean))/r(sd)
		
		qui su std_cgi_main if std_competitiveness!=.
		assert round(r(mean),0.0001)==0
		}		
		if `i'==10{
		drop std_cgi_main
		qui su cgi_main if std_competitiveness!=.
		gen std_cgi_main=(cgi_main-r(mean))/r(sd)
		
		qui su std_cgi_main if std_competitiveness!=.
		assert round(r(mean),0.0001)==0
		}
		
	* Drop schools with only one student in this subsample: leverage = 1 breaks HC3.
	* The CGI coefficient is unchanged (the school dummy fits that student perfectly).
	if `z'==2 & "`controls'"=="i.school_new" {
		bysort school_new: drop if _N==1
	}

	if `z'== 1 { //no controls
		if `i'==1{
		qui reg std_staircase_risk std_cgi_main if female ==0, vce(hc3) 
		}	
		if `i'==2 |`i'==3 |`i'==4 |`i'==5 {
		qui reg std_hyp_risk std_cgi_main if female ==0, vce(hc3) 
		
		}		
		if `i'==6 {
		qui reg financial_market std_cgi_main if female ==0, vce(hc3)
		}		
		if `i'==7 | `i'==8 |`i'==9 |`i'==10{
		qui reg std_competitiveness std_cgi_main if female ==0, vce(hc3) 
		}
	}	

if `z' ==2{
		if `i'==1{
		qui reg std_staircase_risk std_cgi_main `controls' if female ==0, vce(hc3) 
		}	
		if `i'==2 |`i'==3 |`i'==4 |`i'==5 {
		qui reg std_hyp_risk std_cgi_main `controls' if female ==0, vce(hc3) 
	
		}		
		if `i'==6 {
		qui reg financial_market std_cgi_main `controls' if female ==0, vce(hc3)
		}		
		if `i'==7 | `i'==8 |`i'==9 |`i'==10{
		qui reg std_competitiveness std_cgi_main `controls' if female ==0, vce(hc3) 
		}
}	
	
	    ** Save estimates to be used in reg table
        local rsqum_`i': di %6.3f e(r2)
		local rsqum_`i' = trim("$`rsqum_`i''$")
				
		if `sign_female'>0 {
			beta_coeff1_pos std_cgi_main 
			local beta_m_cgi_`i' `r(beta)'
			local se_m_cgi_`i' `r(se)'
		}
		
		if `sign_female'<0 {
			beta_coeff1_neg std_cgi_main 
			local beta_m_cgi_`i' `r(beta)'
			local se_m_cgi_`i' `r(se)'
		}
		
		** save estimates to be used in meta analysis
		local beta_m_cgi_`i'_meta = _b[std_cgi_main]
		local se_m_cgi_`i'_meta = _se[std_cgi_main]
		local p_m_cgi_`i'_meta=2*ttail(e(df_r),abs(_b[std_cgi_main]/_se[std_cgi_main]))
		
			* save 1 tailed version
			qui test _b[std_cgi_main]=0 
			local sign_cgi = sign(_b[std_cgi_main])
			
			if `sign_female'>0 {
			local p_m_cgi_`i'_meta_1t = ttail(r(df_r),`sign_cgi'*sqrt(r(F))) // Ho: coef <= 0
			}
			if `sign_female'<0 {
			local p_m_cgi_`i'_meta_1t = 1-ttail(r(df_r),`sign_cgi'*sqrt(r(F))) // Ho: coef >= 0
			}
			
			* save R2 to be used for R2 meta analysis 
			local rsqum_`i'_meta = e(r2)
			local adjrsqum_`i'_meta = e(r2_a)
	
restore

*-----------------------------------------------------------------------------				
* Sample split coeff comparison
*-----------------------------------------------------------------------------				
* Panel D for females: 

/*
		if `i'==1{
		drop std_staircase_risk 
		qui su staircase_risk if female==1
		qui gen std_staircase_risk =(staircase_risk-r(mean))/r(sd)		
		
		qui su std_staircase_risk if female==1
		assert round(r(mean),0.0001)==0

		}	
		if `i'==2 |`i'==3 |`i'==4 |`i'==5 {
		drop std_hyp_risk 
		qui su hypothetical_risk if female==1
		qui gen std_hyp_risk  =(hypothetical_risk -r(mean))/r(sd)	
		
		qui su std_hyp_risk if female==1
		assert round(r(mean),0.0001)==0
		}			
		
		if `i'==7 | `i'==8 |`i'==9 |`i'==10{
		drop std_competitiveness 
		qui su competitiveness if female==1
		qui gen std_competitiveness =(competitiveness -r(mean))/r(sd)	
		
		qui su std_competitiveness  if female==1
		assert round(r(mean),0.0001)==0 
		}
		
		
		if `i'==1{
		drop std_cgi_main
		qui su cgi_main if std_staircase_risk!=. & female==1
		gen std_cgi_main=(cgi_main-r(mean))/r(sd)
		
		qui su std_cgi_main if std_staircase_risk!=. & female==1
		assert round(r(mean),0.0001)==0
		}	
		if `i'==2 {	
		drop std_cgi_main
		qui su cgi_main if std_hyp_risk!=. & female==1
		gen std_cgi_main=(cgi_main-r(mean))/r(sd)
		
		qui su std_cgi_main if  std_hyp_risk!=. & female==1
		assert round(r(mean),0.0001)==0
		}	
		if `i'==3  {
		drop std_cgi_main
		qui su cgi_main if std_hyp_risk!=. & female==1
		gen std_cgi_main=(cgi_main-r(mean))/r(sd)
		
		qui su std_cgi_main if std_hyp_risk!=. & female==1
		assert round(r(mean),0.0001)==0
		}	
		
		if `i'==4  {
		drop std_cgi_main
		qui su cgi_main if std_hyp_risk!=. & female==1
		gen std_cgi_main=(cgi_main-r(mean))/r(sd)
		
		qui su std_cgi_main if std_hyp_risk!=. & female==1
		assert round(r(mean),0.0001)==0
		}
		if `i'==5 {
		drop std_cgi_main
		qui su cgi_main if std_hyp_risk!=. & female==1
		gen std_cgi_main=(cgi_main-r(mean))/r(sd)
		
		qui su std_cgi_main if std_hyp_risk!=. & female==1
		assert round(r(mean),0.0001)==0		
		}	
		if `i'==6 {
		drop std_cgi_main
		qui su cgi_main if financial_market!=. & female==1
		gen std_cgi_main=(cgi_main-r(mean))/r(sd)
		
		qui su std_cgi_main if financial_market!=. & female==1
		assert round(r(mean),0.0001)==0
		}	
		
		if `i'==7 {
		drop std_cgi_main
		qui su cgi_main if std_competitiveness!=. & female==1
		gen std_cgi_main=(cgi_main-r(mean))/r(sd)
		
		qui su std_cgi_main if std_competitiveness!=. & female==1
		assert round(r(mean),0.0001)==0		
		}
		
		if  `i'==8 {
		drop std_cgi_main
		qui su cgi_main if std_competitiveness!=. & female==1
		gen std_cgi_main=(cgi_main-r(mean))/r(sd)
		
		qui su std_cgi_main if std_competitiveness!=. & female==1
		assert round(r(mean),0.0001)==0		
		}
		if `i'==9{
		drop std_cgi_main
		qui su cgi_main if std_competitiveness!=. & female==1
		gen std_cgi_main=(cgi_main-r(mean))/r(sd)
		
		qui su std_cgi_main if std_competitiveness!=. & female==1
		assert round(r(mean),0.0001)==0
		}		
		if `i'==10{
		drop std_cgi_main
		qui su cgi_main if std_competitiveness!=. & female==1
		gen std_cgi_main=(cgi_main-r(mean))/r(sd)
		
		qui su std_cgi_main if std_competitiveness!=. & female==1
		assert round(r(mean),0.0001)==0
		}
*/

	if `z'== 1 { //no controls
		if `i'==1{
		qui reg std_staircase_risk std_cgi_main if female ==1
		}	
		if `i'==2 |`i'==3 |`i'==4 |`i'==5 {
		qui reg std_hyp_risk std_cgi_main if female ==1
		}		
		if `i'==6 {
		qui reg financial_market std_cgi_main if female ==1
		}		
		if `i'==7 | `i'==8 |`i'==9 |`i'==10{
		qui reg std_competitiveness std_cgi_main if female ==1
		}
	}	

if `z' ==2{
		if `i'==1{
		qui reg std_staircase_risk std_cgi_main `controls' if female ==1
		}	
		if `i'==2 |`i'==3 |`i'==4 |`i'==5 {
		qui reg std_hyp_risk std_cgi_main `controls' if female ==1
		}		
		if `i'==6 {
		qui reg financial_market std_cgi_main `controls' if female ==1
		}		
		if `i'==7 | `i'==8 |`i'==9 |`i'==10{
		qui reg std_competitiveness std_cgi_main `controls' if female ==1
		}
}	

	est store female_`i'

* Panel D for males: 
/*
		if `i'==1{
		drop std_staircase_risk 
		qui su staircase_risk if female ==0
		qui gen std_staircase_risk =(staircase_risk-r(mean))/r(sd)		
		
		qui su std_staircase_risk if female ==0
		assert round(r(mean),0.0001)==0

		}	
		if `i'==2 |`i'==3 |`i'==4 |`i'==5 {
		drop std_hyp_risk 
		qui su hypothetical_risk if female ==0
		qui gen std_hyp_risk  =(hypothetical_risk -r(mean))/r(sd)	
		
		qui su std_hyp_risk if female ==0
		assert round(r(mean),0.0001)==0
		}			
		
		if `i'==7 | `i'==8 |`i'==9 |`i'==10{
		drop std_competitiveness 
		qui su competitiveness if female ==0
		qui gen std_competitiveness =(competitiveness -r(mean))/r(sd)	
		
		qui su std_competitiveness if female ==0
		assert round(r(mean),0.0001)==0 
		}
		
		
		if `i'==1{
		drop std_cgi_main
		qui su cgi_main if std_staircase_risk!=. &  female ==0
		gen std_cgi_main=(cgi_main-r(mean))/r(sd)
		
		qui su std_cgi_main if std_staircase_risk!=. &  female ==0
		assert round(r(mean),0.0001)==0
		}	
		if `i'==2 {	
		drop std_cgi_main
		qui su cgi_main if std_hyp_risk!=. &  female ==0
		gen std_cgi_main=(cgi_main-r(mean))/r(sd)
		
		qui su std_cgi_main if  std_hyp_risk!=.  &  female ==0
		assert round(r(mean),0.0001)==0
		}	
		if `i'==3  {
		drop std_cgi_main
		qui su cgi_main if std_hyp_risk!=.  &  female ==0
		gen std_cgi_main=(cgi_main-r(mean))/r(sd)
		
		qui su std_cgi_main if std_hyp_risk!=.  &  female ==0
		assert round(r(mean),0.0001)==0
		}	
		
		if `i'==4  {
		drop std_cgi_main
		qui su cgi_main if std_hyp_risk!=.  &  female ==0
		gen std_cgi_main=(cgi_main-r(mean))/r(sd)
		
		qui su std_cgi_main if std_hyp_risk!=.  &  female ==0
		assert round(r(mean),0.0001)==0
		}
		if `i'==5 {
		drop std_cgi_main
		qui su cgi_main if std_hyp_risk!=.  &  female ==0
		gen std_cgi_main=(cgi_main-r(mean))/r(sd)
		
		qui su std_cgi_main if std_hyp_risk!=.  &  female ==0
		assert round(r(mean),0.0001)==0		
		}	
		if `i'==6 {
		drop std_cgi_main
		qui su cgi_main if financial_market!=.  &  female ==0
		gen std_cgi_main=(cgi_main-r(mean))/r(sd)
		
		qui su std_cgi_main if financial_market!=.  &  female ==0
		assert round(r(mean),0.0001)==0
		}	
		
		if `i'==7 {
		drop std_cgi_main
		qui su cgi_main if std_competitiveness!=.  &  female ==0
		gen std_cgi_main=(cgi_main-r(mean))/r(sd)
		
		qui su std_cgi_main if std_competitiveness!=.  &  female ==0
		assert round(r(mean),0.0001)==0		
		}
		
		if  `i'==8 {
		drop std_cgi_main
		qui su cgi_main if std_competitiveness!=.  &  female ==0
		gen std_cgi_main=(cgi_main-r(mean))/r(sd)
		
		qui su std_cgi_main if std_competitiveness!=.  &  female ==0
		assert round(r(mean),0.0001)==0		
		}
		if `i'==9{
		drop std_cgi_main
		qui su cgi_main if std_competitiveness!=.  &  female ==0
		gen std_cgi_main=(cgi_main-r(mean))/r(sd)
		
		qui su std_cgi_main if std_competitiveness!=.  &  female ==0
		assert round(r(mean),0.0001)==0
		}		
		if `i'==10{
		drop std_cgi_main
		qui su cgi_main if std_competitiveness!=.  &  female ==0
		gen std_cgi_main=(cgi_main-r(mean))/r(sd)
		
		qui su std_cgi_main if std_competitiveness!=.  &  female ==0
		assert round(r(mean),0.0001)==0
		}
*/

	if `z'== 1 { //no controls
		if `i'==1{
		qui reg std_staircase_risk std_cgi_main if female ==0
		}	
		if `i'==2 |`i'==3 |`i'==4 |`i'==5 {
		qui reg std_hyp_risk std_cgi_main if female ==0
		
		}		
		if `i'==6 {
		qui reg financial_market std_cgi_main if female ==0
		}		
		if `i'==7 | `i'==8 |`i'==9 |`i'==10{
		qui reg std_competitiveness std_cgi_main if female ==0
		}
	}	

if `z' ==2{
		if `i'==1{
		qui reg std_staircase_risk std_cgi_main `controls' if female ==0
		}	
		if `i'==2 |`i'==3 |`i'==4 |`i'==5 {
		qui reg std_hyp_risk std_cgi_main `controls' if female ==0
	
		}		
		if `i'==6 {
		qui reg financial_market std_cgi_main `controls' if female ==0
		}		
		if `i'==7 | `i'==8 |`i'==9 |`i'==10{
		qui reg std_competitiveness std_cgi_main `controls' if female ==0
		}
}	
	
est store male_`i'

suest female_`i' male_`i', vce(robust)
//test [female_`i'_mean]std_cgi_main=[male_`i'_mean]std_cgi_main
lincom _b[female_`i'_mean:std_cgi_main] - _b[male_`i'_mean:std_cgi_main] 
local panelD_test_`i': di %6.3f r(p)
local panelD_test_`i' = trim("$`panelD_test_`i''$")

*-----------------------------------------------------------------------------				
* Store the mean of each dependent variable 	
*-----------------------------------------------------------------------------				
		if `i'==1{
		qui su std_staircase_risk
        local mean_`i': di %6.0f round(r(mean))
		}	
		if `i'==2 |`i'==3 |`i'==4 |`i'==5 {
		qui su std_hyp_risk
		local  mean_`i': di %6.3f round(r(mean))
		
			if round(r(mean),0.0001)==0 { // i.e. standardized
			local mean_`i': di %6.0f round(r(mean))
		}
		}		
		if `i'==6 {
		qui su financial_market
		local  mean_`i': di %6.3f r(mean)
		}		
		if `i'==7 | `i'==8 |`i'==9 |`i'==10{
		qui su std_competitiveness
		local  mean_`i': di %6.3f round(r(mean))
		
			if round(r(mean),0.0001)==0 { // i.e. standardized
			local mean_`i': di %6.0f round(r(mean))
		}
		}	
}

*-----------------------------------------------------------------------------
*-----------------------------------------------------------------------------
* Write the Results
*-----------------------------------------------------------------------------
*-----------------------------------------------------------------------------

foreach path in out_path{
	
if `z' ==1{
        file open resultsfile using "$`path'/Tables_Main_Paper/`tableid'.tex", write replace
}	

if `z' ==2{
	   file open resultsfile using "$`path'/Tables_Controls/`tableid'.tex", write replace
}	


*-----------------------------------------------------------------------------
* Write Table header
*-----------------------------------------------------------------------------
//file write resultsfile "\begin{table}[H]"
//file write resultsfile "\begin{adjustbox}{max width=16cm}" 
//file write resultsfile "\begin{threeparttable}"

if `z' ==1{
file write resultsfile "\caption{CGI and Unincentivized Risk and Competitiveness Measures}" 
file write resultsfile "\label{table 4}"
}
if `z' ==2{
file write resultsfile "\caption{CGI and Unincentivized Risk and Competitiveness Measures (with controls)}" 
}
file write resultsfile "\centering" 
file write resultsfile "\begin{tabular}" 
file write resultsfile "{p{1.7cm} M{1.7cm} M{1.7cm} M{1.7cm} M{1.7cm} M{1.7cm} M{1.7cm} M{1.7cm} M{1.7cm} M{1.7cm} M{1.7cm}}" 
file write resultsfile "\toprule \toprule"

file write resultsfile "\multicolumn{1}{l}{Measure} & \multicolumn{1}{c}{\thead{Staircase \\ Risk}} & \multicolumn{4}{c}{Risk} & \multicolumn{1}{c}{\thead{Financial \\ Risk}} & \multicolumn{4}{c}{Competitiveness} \\ "
file write resultsfile "\cmidrule(lr){2-2} \cmidrule(lr){3-6}\cmidrule(lr){7-7}\cmidrule(lr){8-11} \\"
file write resultsfile "\multicolumn{1}{l}{Sample} & \thead{Swiss \\ Uni} & \thead{Swiss \\ Uni}  & \thead{U.S \\ Adults} & \thead{Swiss \\ Teens} & \thead{Swedish \\ Youths} & \thead{US \\ Adults} & \thead{Swiss \\ Uni} & \thead{U.S \\ Adults} & \thead{Swiss \\ Teens}  & \thead{Swedish \\ Youths}  \\"
file write resultsfile "& (1) & (2) & (3) & (4) & (5) & (6) & (7) & (8) & (9) & (10) \\"
file write resultsfile "\midrule"
file write resultsfile" \addlinespace[0.2cm]"


*-----------------------------------------------------------------------------
* Write Panel A
*-----------------------------------------------------------------------------

file write resultsfile "\multicolumn{5}{l}{\textbf{Panel A. Binary gender}} \\" _n
file write resultsfile " \multicolumn{1}{l}{Female} & $`beta_a_sex_1'$  &	$`beta_a_sex_2'$ &	$`beta_a_sex_3'$ &	$`beta_a_sex_4'$  &	$`beta_a_sex_5'$ &	$`beta_a_sex_6'$ &	$`beta_a_sex_7'$ &	$`beta_a_sex_8'$ &	$`beta_a_sex_9'$ &	$`beta_a_sex_10'$\\" _n
file write resultsfile " & (`se_a_sex_1')	&	(`se_a_sex_2')    &	(`se_a_sex_3') &	(`se_a_sex_4') &	(`se_a_sex_5') &	(`se_a_sex_6') &	(`se_a_sex_7') &	(`se_a_sex_8') &	(`se_a_sex_9') &	(`se_a_sex_10') \\" _n
file write resultsfile "\addlinespace[0.1cm]"
file write resultsfile " \multicolumn{1}{l}{$\text{R}^2$}			& `rsqua_1'	  &	`rsqua_2' &	`rsqua_3' &	`rsqua_4' &	`rsqua_5' &	`rsqua_6' &	`rsqua_7' &	`rsqua_8' &	`rsqua_9' &	`rsqua_10' \\ \\" _n
file write resultsfile "\addlinespace[-0.3cm]"
file write resultsfile "\midrule"

*-----------------------------------------------------------------------------
* Write Panel B
*-----------------------------------------------------------------------------
file write resultsfile "\multicolumn{5}{l}{\textbf{Panel B. Gender identity}} \\" _n
file write resultsfile " \multicolumn{1}{l}{CGI (feminine)} & $`beta_b_cgi_1'$  &	$`beta_b_cgi_2'$ &	$`beta_b_cgi_3'$ &	$`beta_b_cgi_4'$ &	$`beta_b_cgi_5'$ & $`beta_b_cgi_6'$ & $`beta_b_cgi_7'$ & $`beta_b_cgi_8'$ & $`beta_b_cgi_9'$ & $`beta_b_cgi_10'$\\" _n
file write resultsfile "  &	(`se_b_cgi_1')  &	(`se_b_cgi_2')   &(`se_b_cgi_3') &	(`se_b_cgi_4') &	(`se_b_cgi_5') & (`se_b_cgi_6') & (`se_b_cgi_7') & (`se_b_cgi_8') & (`se_b_cgi_9') & (`se_b_cgi_10')\\" _n
file write resultsfile "\addlinespace[0.1cm]"
file write resultsfile " \multicolumn{1}{l}{$\text{R}^2$}			& `rsqub_1'	& `rsqub_2' & `rsqub_3' &	`rsqub_4' &	`rsqub_5' &	`rsqub_6' &	`rsqub_7' &	`rsqub_8' &	`rsqub_9' &	`rsqub_10'  \\ \\" _n
file write resultsfile "\addlinespace[-0.3cm]"
file write resultsfile "\midrule"

*-----------------------------------------------------------------------------
* Write Panel C
*-----------------------------------------------------------------------------
file write resultsfile "\multicolumn{5}{l}{\textbf{Panel C. Binary gender and gender identity}} \\" _n
file write resultsfile " \multicolumn{1}{l}{Female} & $`beta_c_sex_1'$  &	$`beta_c_sex_2'$	& $`beta_c_sex_3'$ 	&	$`beta_c_sex_4'$ &	$`beta_c_sex_5'$ 	&	$`beta_c_sex_6'$ &	$`beta_c_sex_7'$ &	$`beta_c_sex_8'$ &	$`beta_c_sex_9'$ &	$`beta_c_sex_10'$\\" _n
file write resultsfile " & (`se_c_sex_1')	   &	(`se_c_sex_2')	& (`se_c_sex_3')  &	(`se_c_sex_4') &	(`se_c_sex_5') &	(`se_c_sex_6') &	(`se_c_sex_7') &	(`se_c_sex_8') &	(`se_c_sex_9') &	(`se_c_sex_10')\\ \\" _n
file write resultsfile "\addlinespace[-0.3cm]"
file write resultsfile " \multicolumn{1}{l}{CGI (feminine)} & $`beta_c_cgi_1'$  &	$`beta_c_cgi_2'$ &	$`beta_c_cgi_3'$ &	$`beta_c_cgi_4'$ &	$`beta_c_cgi_5'$ &	$`beta_c_cgi_6'$ &	$`beta_c_cgi_7'$ &	$`beta_c_cgi_8'$ &	$`beta_c_cgi_9'$ &	$`beta_c_cgi_10'$ \\" _n
file write resultsfile " & (`se_c_cgi_1')	 &	(`se_c_cgi_2')    &	(`se_c_cgi_3')	&	(`se_c_cgi_4') &	(`se_c_cgi_5') & (`se_c_cgi_6') & (`se_c_cgi_7') & (`se_c_cgi_8') & (`se_c_cgi_9') & (`se_c_cgi_10') \\" _n
file write resultsfile "\addlinespace[0.1cm]"
file write resultsfile " \multicolumn{1}{l}{$\text{R}^2$}	& `rsquc_1' & `rsquc_2' &	`rsquc_3' & `rsquc_4' &	`rsquc_5' &	`rsquc_6' &	`rsquc_7' &	`rsquc_8' &	`rsquc_9' &	`rsquc_10'  \\ \\" _n		
file write resultsfile "\addlinespace[-0.3cm]"
file write resultsfile "\midrule"

*-----------------------------------------------------------------------------
* Write Panel D
*-----------------------------------------------------------------------------
file write resultsfile "\multicolumn{5}{l}{\textbf{Panel D. Sample split by binary gender}} \\" _n
file write resultsfile "  \multicolumn{1}{l}{Female: CGI (feminine)}  & $`beta_f_cgi_1'$  &	$`beta_f_cgi_2'$ &	$`beta_f_cgi_3'$ &	$`beta_f_cgi_4'$ &	$`beta_f_cgi_5'$ &	$`beta_f_cgi_6'$ &	$`beta_f_cgi_7'$ &	$`beta_f_cgi_8'$ &	$`beta_f_cgi_9'$ &	$`beta_f_cgi_10'$ \\" _n
file write resultsfile "  & (`se_f_cgi_1')	   &	(`se_f_cgi_2') &	(`se_f_cgi_3')	&	(`se_f_cgi_4') &	(`se_f_cgi_5') &  (`se_f_cgi_6') &  (`se_f_cgi_7') &  (`se_f_cgi_8') &  (`se_f_cgi_9') &  (`se_f_cgi_10') \\" _n	
file write resultsfile "\addlinespace[0.1cm]"
file write resultsfile " \multicolumn{1}{l}{$\text{R}^2$}	& `rsquf_1'	&	`rsquf_2'   &	`rsquf_3' &	`rsquf_4' &	`rsquf_5' &	`rsquf_6' &	`rsquf_7' &	`rsquf_8' &	`rsquf_9' &	`rsquf_10' \\ \\" _n
file write resultsfile "\addlinespace[-0.3cm]"	

file write resultsfile " \multicolumn{1}{l}{Male: CGI (feminine)} & $`beta_m_cgi_1'$  &	$`beta_m_cgi_2'$ &	$`beta_m_cgi_3'$ &	$`beta_m_cgi_4'$ &	$`beta_m_cgi_5'$ & $`beta_m_cgi_6'$ & $`beta_m_cgi_7'$ & $`beta_m_cgi_8'$ & $`beta_m_cgi_9'$ & $`beta_m_cgi_10'$ \\" _n
file write resultsfile " & (`se_m_cgi_1')	  &	(`se_m_cgi_2') &	(`se_m_cgi_3') &	(`se_m_cgi_4') &	(`se_m_cgi_5') & (`se_m_cgi_6') & (`se_m_cgi_7') & (`se_m_cgi_8') & (`se_m_cgi_9') & (`se_m_cgi_10')\\" _n
file write resultsfile "\addlinespace[0.1cm]"
file write resultsfile " \multicolumn{1}{l}{$\text{R}^2$}	& `rsqum_1'	 & `rsqum_2'   &	`rsqum_3' &	`rsqum_4' &	`rsqum_5' &	`rsqum_6' &	`rsqum_7' &	`rsqum_8' &	`rsqum_9' &	`rsqum_10' \\ \\" _n	
file write resultsfile "\addlinespace[-0.3cm]"
file write resultsfile "\multicolumn{5}{l}{Test: male sample split CGI = female sample split CGI} \\" _n
file write resultsfile "\addlinespace[-0.6cm]"
file write resultsfile " \multicolumn{1}{l}{p-value} & $`panelD_test_1'$  &	$`panelD_test_2'$ &	$`panelD_test_3'$ &	$`panelD_test_4'$ &	$`panelD_test_5'$ &	$`panelD_test_6'$ &	$`panelD_test_7'$ &	$`panelD_test_8'$ &	$`panelD_test_9'$ &	$`panelD_test_10'$  \\" _n
file write resultsfile "\addlinespace[-0.5cm]"
file write resultsfile "\midrule"

*-----------------------------------------------------------------------------
* Write Obs number row
*-----------------------------------------------------------------------------
file write resultsfile " \multicolumn{1}{l}{Observations} & `N_1' & `N_2' & `N_3' & `N_4' & `N_5' & `N_6' & `N_7' & `N_8' & `N_9' & `N_10' \\ \\" _n
file write resultsfile "\addlinespace[-0.3cm]"


*-----------------------------------------------------------------------------
* Write mean of dependent variable
*-----------------------------------------------------------------------------
* get rid of the mean decimals for the standardized variables
		
file write resultsfile "\multicolumn{1}{l}{Mean of Dependent Variable}  & `mean_1' & `mean_2' & `mean_3' & `mean_4' & `mean_5' & `mean_6' & `mean_7' & `mean_8' & `mean_9' & `mean_10' \\ \\" _n
file write resultsfile "\addlinespace[-0.3cm]"

*-----------------------------------------------------------------------------
* Write Table footer
*-----------------------------------------------------------------------------
file write resultsfile "\bottomrule\bottomrule"
file write resultsfile "\end{tabular}"
//file write resultsfile "\begin{tablenotes}[para,flushleft] \small"
//if `z'==1 {
//file write resultsfile "\item \textit{Notes:} The table presents results from regressing unincentivized measures of risk attitudes and competitiveness on our standardized measure of CGI. Swiss Uni, U.S. Adults (age 30-59), Swiss Teens, and Swedish Youth samples are used. The estimates in each column and panel come from a separate regression. Staircase risk is a categorical certainty equivalence measure of risk-taking based on a series of hypothetical allocation decisions. Risk is a self-reported measure of risk-taking. Financial risk is a dummy that takes the value 1 for those who report to actively trade in securities. Competitiveness is a self-reported measure of competitiveness. A higher value means higher risk taking or competitiveness. All measures except financial market risk are standardized (to have a mean of 0 and a standard deviation of 1). Robust standard errors are reported in parentheses. Significance levels in Panels B, C and D are determined by a one-tailed test in the direction of the coefficient estimate of female in Panel A. *** p$<$0.005, ** p$<$0.01, * p$<$0.05."
//}

//if `z'==2 {
//file write resultsfile "\item \textit{Notes:} The table presents results from regressing unincentivized measures of risk attitudes and competitiveness on our standardized measure of CGI. Swiss Uni, U.S. Adults (age 30-59), Swiss Teens, and Swedish Youth samples are used. The controls are as follows: quadratic age, race, division and wave for US Adults; quadratic age and education level for Swiss Uni; grade level and survey round for Swiss Teens; school for Swedish Youth. The estimates in each column and panel come from a separate regression. Staircase risk is a categorical certainty equivalence measure of risk-taking based on a series of hypothetical allocation decisions. Risk is a self-reported measure of risk-taking. Financial risk is a dummy that takes the value 1 for those who report to actively trade in securities. Competitiveness is a self-reported measure of competitiveness. A higher value means higher risk taking or competitiveness. A higher value means higher risk taking or competitiveness. All measures except financial market risk are standardized (to have a mean of 0 and a standard deviation of 1). Robust standard errors are reported in parentheses. Significance levels in Panels B, C and D are determined by a one-tailed test in the direction of the coefficient estimate of female in Panel A. *** p$<$0.005, ** p$<$0.01, * p$<$0.05."
//}
	
	
//file write resultsfile "\end{tablenotes}"
//file write resultsfile "\end{threeparttable}"
//file write resultsfile "\end{adjustbox}"
//file write resultsfile "\end{table}"
file close resultsfile
}

*-----------------------------------------------------------------------------
*-----------------------------------------------------------------------------
* Finally, store the results to be used for the meta analysis
*-----------------------------------------------------------------------------
*-----------------------------------------------------------------------------
preserve
if `z' == 1 { //no controls

    * Create an empty dataset
    clear
    set obs `colno'

	gen beta_c_cgi=.
	gen se_c_cgi=.
	gen p_c_cgi=.
	gen p_c_cgi_1t=.
	gen col_num=. 
	gen table_id="`tableid'"
	gen dropped_panelC=0
	
    * Save coefficients	
	forvalues i=1/`colno'{
		replace beta_c_cgi = `beta_c_cgi_`i'_meta' in `i' //beta
		replace se_c_cgi = `se_c_cgi_`i'_meta' in `i' //se
		replace p_c_cgi = `p_c_cgi_`i'_meta' in `i' //pval
		replace p_c_cgi_1t = `p_c_cgi_`i'_meta_1t' in `i' //pval 1 tail		
		replace col_num = `i' in `i' //column number as shown the table
	}

    * Save the dataset to a Stata data file
    save "$path/1_data/5_meta/1_pval/`tableid'_panelC.dta", replace
}

*-------------------------------------------------------------------------------
*-----------------------------------------------------------------------------
* pval CDF for males vs females
if `z' == 1 { //no controls

    * Create an empty dataset
    clear
    set obs `colno'

	gen p_f_cgi=.
	gen p_f_cgi_1t=.
	gen p_m_cgi=.
	gen p_m_cgi_1t=.
	gen col_num=.
	gen table_id="`tableid'"
	gen dropped_panelC=0
	
    * Save coefficients	
	forvalues i=1/`colno'{
		replace p_f_cgi = `p_f_cgi_`i'_meta' in `i' //pval
		replace p_m_cgi = `p_m_cgi_`i'_meta' in `i' //pval
		replace p_f_cgi_1t = `p_f_cgi_`i'_meta_1t' in `i' //pval 1t
		replace p_m_cgi_1t = `p_m_cgi_`i'_meta_1t' in `i' //pval 1t
		replace col_num = `i' in `i' //column number as shown the table
	}

    * Save the dataset to a Stata data file
    save "$path/1_data/5_meta/1_pval/`tableid'_panelD.dta", replace
}

*-------------------------------------------------------------------------------
*-------------------------------------------------------------------------------
* Save the non-adj R2 values for the Meta Analysis

if `z' == 1 {
	
* Create an empty dataset
	clear
	set obs `colno'
	
	gen panelA=.
	gen panelC=.
	gen panelD_f=.
	gen panelD_m=.
	gen col_num=.
	gen table_id="`tableid'"
	gen dropped_panelC=0
	
	forvalues i=1/`colno' {
	replace panelA = `rsqua_`i'_meta' in `i'
	replace panelC = `rsquc_`i'_meta' in `i'
	replace panelD_f = `rsquf_`i'_meta' in `i'
	replace panelD_m = `rsqum_`i'_meta' in `i'
	replace col_num = `i' in `i' //column number as shown on the table. 
	}
	
	* Save the dataset to a Stata data file
    save "$path/1_data/5_meta/2_R2/`tableid'.dta", replace
	

}
*-------------------------------------------------------------------------------

*-------------------------------------------------------------------------------
* Save the adj R2 values for the Meta Analysis

if `z' == 1 {
	
	* Create an empty dataset
	clear
	set obs `colno'
	
	gen panelA=.
	gen panelC=.
	gen col_number=.
	gen table_id="`tableid'"
	gen dropped_panelC=0

	forvalues i=1/`colno'{
	replace panelA = `adjrsqua_`i'_meta' in `i'
	replace panelC = `adjrsquc_`i'_meta' in `i'
	replace col_num= `i' in `i' //column number as shown on the table. 
	}

	* Save the dataset to a Stata data file
    save "$path/1_data/5_meta/3_adjR2/`tableid'.dta", replace

restore 

}
}
*-------------------------------------------------------------------------------




