clear all

global out_path "$path/3_out" 
		
local tableid "table_6"
local colno "5" 

* short code to save reg coeffs
do "$path/2_do/2_analysis/0_reg_fnc/0_regressions.do" // 2 tailed 
do "$path/2_do/2_analysis/0_reg_fnc/0_regressions_1t_+.do" // 1 tailed if sign_female>0
do "$path/2_do/2_analysis/0_reg_fnc/0_regressions_1t_-.do" // 1 tailed if sign_female<0


/*
Table 6 
CGI and educational choices 

Column 1: Female Share - US adults
Column 2: Female Share - Swiss Teens
Column 3: Female Share - Swedish Youth
Column 4: Math (Skill requirements) - Swiss Teens
Column 5: Language (Skill requirements) - Swiss Teens
*/

forvalues z =1/2{ 

forvalues i=1/5{ 
	if `i'==1{
		use "$path/1_data/2_prepared/1_usadults_w1_w2_30_60.dta", clear
		local controls "c.age##c.age black all_other_races i.division wave1"
		
		* Restandardize std_cgi_main as it was standardized for age 20-60.
		drop std_cgi_main
		qui su cgi_main
		qui gen std_cgi_main=(cgi_main-r(mean))/r(sd)
		
	}		
	if `i'==2 | `i'==4 | `i'==5{
		use "$path/1_data/2_prepared/1_swissteens.dta", clear
		local controls "grade_8 grade_9 march_survey"
	}	
	if `i'==3{
		use "$path/1_data/2_prepared/1_Swedishyouth.dta", clear
		local controls "i.school_new"
	}
	
	
*-----------------------------------------------------------------------------
* Sanity checks with standardizations before we start the regression analysis
*-----------------------------------------------------------------------------
		if `i'==4 {
		qui su std_math_avg_ALL 
		assert round(r(mean),0.0001)==0 
		}
		
		if `i'==5 {
		qui su std_language_avg_ALL 
		assert round(r(mean),0.0001)==0		
		}
		
		if `i'==1 {
		qui su std_cgi_main if major_share!=.
		// assert round(r(mean),0.0001)==0	
		
		drop std_cgi_main
		qui su cgi_main if major_share!=.
		gen std_cgi_main=(cgi_main-r(mean))/r(sd)
		
		qui su std_cgi_main if major_share!=.
		assert round(r(mean),0.0001)==0	
		}		
		if `i'==2 {
		qui su std_cgi_main if Female_share_avg_ALL!=.
		//assert round(r(mean),0.0001)==0	
		
		drop std_cgi_main
		qui su cgi_main if Female_share_avg_ALL!=.
		gen std_cgi_main=(cgi_main-r(mean))/r(sd)
		
		qui su std_cgi_main if Female_share_avg_ALL!=.
		assert round(r(mean),0.0001)==0	
		}
		if `i'==3 {
		qui su std_cgi_main if ShareFemaleAccepted!=.
		assert round(r(mean),0.0001)==0	
		}
		if `i'==4 {
		qui su std_cgi_main if std_math_avg_ALL!=.
		//assert round(r(mean),0.0001)==0	
		
		drop std_cgi_main
		qui su cgi_main if std_math_avg_ALL!=.
		gen std_cgi_main=(cgi_main-r(mean))/r(sd)
		
		qui su std_cgi_main if std_math_avg_ALL!=.
		assert round(r(mean),0.0001)==0	
		}
		if `i'==5 {
		qui su std_cgi_main if std_language_avg_ALL!=.
		//assert round(r(mean),0.0001)==0	
		
		drop std_cgi_main
		qui su cgi_main if std_language_avg_ALL!=.
		gen std_cgi_main=(cgi_main-r(mean))/r(sd)
		
		qui su std_cgi_main if std_language_avg_ALL!=.
		assert round(r(mean),0.0001)==0	
		}

*-----------------------------------------------------------------------------
* Panel A: biological gender	 
*-----------------------------------------------------------------------------
	if `z'== 1 { //no controls
		if `i'==1 {
		qui reg major_share female, vce(hc3) 
		}		
		if `i'==2 {
		qui reg Female_share_avg_ALL female, vce(hc3) 
		}
		if `i'==3 {
		qui reg ShareFemaleAccepted female, vce(hc3) 
		}
		if `i'==4 {
		qui reg std_math_avg_ALL female, vce(hc3) 
		}
		if `i'==5 {
		qui reg std_language_avg_ALL female, vce(hc3) 
		}
	}
		
	if `z'== 2 { 
		if `i'==1 {
		qui reg major_share female `controls', vce(hc3) 
		}		
		if `i'==2 {
		qui reg Female_share_avg_ALL female `controls', vce(hc3) 
		}
		if `i'==3 {
		qui reg ShareFemaleAccepted female `controls', vce(hc3) 
		}
		if `i'==4 {
		qui reg std_math_avg_ALL female `controls', vce(hc3) 
		}
		if `i'==5 {
		qui reg std_language_avg_ALL female `controls', vce(hc3) 
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
		if `i'==1 {
		qui reg major_share std_cgi_main, vce(hc3) 
		}		
		if `i'==2 {
		qui reg Female_share_avg_ALL std_cgi_main, vce(hc3) 
		}
		if `i'==3 {
		qui reg ShareFemaleAccepted std_cgi_main, vce(hc3) 
		}
		if `i'==4 {
		qui reg std_math_avg_ALL std_cgi_main, vce(hc3) 
		}
		if `i'==5 {
		qui reg std_language_avg_ALL std_cgi_main, vce(hc3) 
		}
	}
		
	if `z'== 2 { 
		if `i'==1 {
		qui reg major_share std_cgi_main `controls', vce(hc3) 
		}		
		if `i'==2 {
		qui reg Female_share_avg_ALL std_cgi_main `controls', vce(hc3) 
		}
		if `i'==3 {
		qui reg ShareFemaleAccepted std_cgi_main `controls', vce(hc3) 
		}
		if `i'==4 {
		qui reg std_math_avg_ALL std_cgi_main `controls', vce(hc3) 
		}
		if `i'==5 {
		qui reg std_language_avg_ALL std_cgi_main `controls', vce(hc3) 
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
		if `i'==1 {
		qui reg major_share female std_cgi_main, vce(hc3) 
		}		
		if `i'==2 {
		qui reg Female_share_avg_ALL female std_cgi_main, vce(hc3) 
		}
		if `i'==3 {
		qui reg ShareFemaleAccepted female std_cgi_main, vce(hc3) 
		}
		if `i'==4 {
		qui reg std_math_avg_ALL female std_cgi_main, vce(hc3) 
		}
		if `i'==5 {
		qui reg std_language_avg_ALL female std_cgi_main, vce(hc3) 
		}
	}
		
	if `z'== 2 { 
		if `i'==1 {
		qui reg major_share female std_cgi_main `controls', vce(hc3) 
		}		
		if `i'==2 {
		qui reg Female_share_avg_ALL female std_cgi_main `controls', vce(hc3) 
		}
		if `i'==3 {
		qui reg ShareFemaleAccepted female std_cgi_main `controls', vce(hc3) 
		}
		if `i'==4 {
		qui reg std_math_avg_ALL female std_cgi_main `controls', vce(hc3) 
		}
		if `i'==5 {
		qui reg std_language_avg_ALL female std_cgi_main `controls', vce(hc3) 
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

		if `i'==4 {
		drop std_math_avg_ALL 
		qui su math_avg_ALL 
		qui gen std_math_avg_ALL =(math_avg_ALL -r(mean))/r(sd)	
		
		qui su std_math_avg_ALL 
		assert round(r(mean),0.0001)==0 
		}
		
		if `i'==5 {
		drop std_language_avg_ALL 
		qui su language_avg_ALL 
		qui gen std_language_avg_ALL  =(language_avg_ALL  -r(mean))/r(sd)	
		
		qui su std_language_avg_ALL 
		assert round(r(mean),0.0001)==0		
		}
		
		if `i'==1 {
		drop std_cgi_main
		qui su cgi_main if major_share!=.
		gen std_cgi_main=(cgi_main-r(mean))/r(sd)
		
		qui su std_cgi_main if major_share!=.
		assert round(r(mean),0.0001)==0	
		}		
		if `i'==2 {
		drop std_cgi_main
		qui su cgi_main if Female_share_avg_ALL!=.
		gen std_cgi_main=(cgi_main-r(mean))/r(sd)
		
		qui su std_cgi_main if Female_share_avg_ALL!=.
		assert round(r(mean),0.0001)==0	
		}
		
		if `i'==3 {
		drop std_cgi_main
		qui su cgi_main if ShareFemaleAccepted!=.
		gen std_cgi_main=(cgi_main-r(mean))/r(sd)
			
		qui su std_cgi_main if ShareFemaleAccepted!=.
		assert round(r(mean),0.0001)==0	
		}
		
		if `i'==4 {
		drop std_cgi_main
		qui su cgi_main if std_math_avg_ALL!=.
		gen std_cgi_main=(cgi_main-r(mean))/r(sd)
		
		qui su std_cgi_main if std_math_avg_ALL!=.
		assert round(r(mean),0.0001)==0	
		}
		
		if `i'==5 {
		drop std_cgi_main
		qui su cgi_main if std_language_avg_ALL!=.
		gen std_cgi_main=(cgi_main-r(mean))/r(sd)
		
		qui su std_cgi_main if std_language_avg_ALL!=.
		assert round(r(mean),0.0001)==0	
		}
		
	* Drop schools with only one student in this subsample: leverage = 1 breaks HC3.
	* The CGI coefficient is unchanged (the school dummy fits that student perfectly).
	if `z'==2 & "`controls'"=="i.school_new" {
		bysort school_new: drop if _N==1
	}		
		
  	if `z'== 1 { //no controls
		if `i'==1 {
		qui reg major_share std_cgi_main if female==1, vce(hc3) 
		}		
		if `i'==2 {
		qui reg Female_share_avg_ALL std_cgi_main if female==1, vce(hc3) 
		}
		if `i'==3 {
		qui reg ShareFemaleAccepted std_cgi_main if female==1, vce(hc3) 
		}
		if `i'==4 {
		qui reg std_math_avg_ALL std_cgi_main if female==1, vce(hc3) 
		}
		if `i'==5 {
		qui reg std_language_avg_ALL std_cgi_main if female==1, vce(hc3) 
		}
	}
		
	if `z'== 2 { 
		if `i'==1 {
		qui reg major_share std_cgi_main `controls' if female==1, vce(hc3) 
		}		
		if `i'==2 {
		qui reg Female_share_avg_ALL std_cgi_main `controls' if female==1, vce(hc3) 
		}
		if `i'==3 {
		qui reg ShareFemaleAccepted std_cgi_main `controls' if female==1, vce(hc3) 
		}
		if `i'==4 {
		qui reg std_math_avg_ALL std_cgi_main `controls' if female==1, vce(hc3) 
		}
		if `i'==5 {
		qui reg std_language_avg_ALL std_cgi_main `controls' if female==1, vce(hc3) 
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

		if `i'==4 {
		drop std_math_avg_ALL 
		qui su math_avg_ALL 
		qui gen std_math_avg_ALL =(math_avg_ALL -r(mean))/r(sd)	
		
		qui su std_math_avg_ALL 
		assert round(r(mean),0.0001)==0 
		}
		
		if `i'==5 {
		drop std_language_avg_ALL 
		qui su language_avg_ALL 
		qui gen std_language_avg_ALL  =(language_avg_ALL  -r(mean))/r(sd)	
		
		qui su std_language_avg_ALL 
		assert round(r(mean),0.0001)==0		
		}
		
		if `i'==1 {
		drop std_cgi_main
		qui su cgi_main if major_share!=.
		gen std_cgi_main=(cgi_main-r(mean))/r(sd)
		
		qui su std_cgi_main if major_share!=.
		assert round(r(mean),0.0001)==0	
		}		
		if `i'==2 {
		drop std_cgi_main
		qui su cgi_main if Female_share_avg_ALL!=.
		gen std_cgi_main=(cgi_main-r(mean))/r(sd)
		
		qui su std_cgi_main if Female_share_avg_ALL!=.
		assert round(r(mean),0.0001)==0	
		}
		
		if `i'==3 {
		drop std_cgi_main
		qui su cgi_main if ShareFemaleAccepted!=.
		gen std_cgi_main=(cgi_main-r(mean))/r(sd)
			
		qui su std_cgi_main if ShareFemaleAccepted!=.
		assert round(r(mean),0.0001)==0	
		}
		
		if `i'==4 {
		drop std_cgi_main
		qui su cgi_main if std_math_avg_ALL!=.
		gen std_cgi_main=(cgi_main-r(mean))/r(sd)
		
		qui su std_cgi_main if std_math_avg_ALL!=.
		assert round(r(mean),0.0001)==0	
		}
		
		if `i'==5 {
		drop std_cgi_main
		qui su cgi_main if std_language_avg_ALL!=.
		gen std_cgi_main=(cgi_main-r(mean))/r(sd)
		
		qui su std_cgi_main if std_language_avg_ALL!=.
		assert round(r(mean),0.0001)==0	
		}
		
	* Drop schools with only one student in this subsample: leverage = 1 breaks HC3.
	* The CGI coefficient is unchanged (the school dummy fits that student perfectly).
	if `z'==2 & "`controls'"=="i.school_new" {
		bysort school_new: drop if _N==1
	}
  	if `z'== 1 { //no controls
		if `i'==1 {
		qui reg major_share std_cgi_main if female==0, vce(hc3) 
		}		
		if `i'==2 {
		qui reg Female_share_avg_ALL std_cgi_main if female==0, vce(hc3) 
		}
		if `i'==3 {
		qui reg ShareFemaleAccepted std_cgi_main if female==0, vce(hc3) 
		}
		if `i'==4 {
		qui reg std_math_avg_ALL std_cgi_main if female==0, vce(hc3) 
		}
		if `i'==5 {
		qui reg std_language_avg_ALL std_cgi_main if female==0, vce(hc3) 
		}
	}
		
	if `z'== 2 { 
		if `i'==1 {
		qui reg major_share std_cgi_main `controls' if female==0, vce(hc3) 
		}		
		if `i'==2 {
		qui reg Female_share_avg_ALL std_cgi_main `controls' if female==0, vce(hc3) 
		}
		if `i'==3 {
		qui reg ShareFemaleAccepted std_cgi_main `controls' if female==0, vce(hc3) 
		}
		if `i'==4 {
		qui reg std_math_avg_ALL std_cgi_main `controls' if female==0, vce(hc3) 
		}
		if `i'==5 {
		qui reg std_language_avg_ALL std_cgi_main `controls' if female==0, vce(hc3) 
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

		
  	if `z'== 1 { //no controls
		if `i'==1 {
		qui reg major_share std_cgi_main if female==1
		}		
		if `i'==2 {
		qui reg Female_share_avg_ALL std_cgi_main if female==1
		}
		if `i'==3 {
		qui reg ShareFemaleAccepted std_cgi_main if female==1
		}
		if `i'==4 {
		qui reg std_math_avg_ALL std_cgi_main if female==1
		}
		if `i'==5 {
		qui reg std_language_avg_ALL std_cgi_main if female==1
		}
	}
		
	if `z'== 2 { 
		if `i'==1 {
		qui reg major_share std_cgi_main `controls' if female==1
		}		
		if `i'==2 {
		qui reg Female_share_avg_ALL std_cgi_main `controls' if female==1
		}
		if `i'==3 {
		qui reg ShareFemaleAccepted std_cgi_main `controls' if female==1
		}
		if `i'==4 {
		qui reg std_math_avg_ALL std_cgi_main `controls' if female==1
		}
		if `i'==5 {
		qui reg std_language_avg_ALL std_cgi_main `controls' if female==1
		}
	}	
	
		est store female_`i'	


* Panel D for males: 

  	if `z'== 1 { //no controls
		if `i'==1 {
		qui reg major_share std_cgi_main if female==0
		}		
		if `i'==2 {
		qui reg Female_share_avg_ALL std_cgi_main if female==0
		}
		if `i'==3 {
		qui reg ShareFemaleAccepted std_cgi_main if female==0 
		}
		if `i'==4 {
		qui reg std_math_avg_ALL std_cgi_main if female==0
		}
		if `i'==5 {
		qui reg std_language_avg_ALL std_cgi_main if female==0
		}
	}
		
	if `z'== 2 { 
		if `i'==1 {
		qui reg major_share std_cgi_main `controls' if female==0
		}		
		if `i'==2 {
		qui reg Female_share_avg_ALL std_cgi_main `controls' if female==0
		}
		if `i'==3 {
		qui reg ShareFemaleAccepted std_cgi_main `controls' if female==0
		}
		if `i'==4 {
		qui reg std_math_avg_ALL std_cgi_main `controls' if female==0
		}
		if `i'==5 {
		qui reg std_language_avg_ALL std_cgi_main `controls' if female==0 
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
	if `i'==1 {
		qui su major_share
		local  mean_`i': di %6.3f r(mean)
		}		
		if `i'==2 {
		qui su Female_share_avg_ALL 
		local  mean_`i': di %6.3f r(mean)
		}
		if `i'==3 {
		qui su ShareFemaleAccepted
		local  mean_`i': di %6.3f r(mean)
		}
		if `i'==4 {
		qui su std_math_avg_ALL
		local  mean_`i': di %6.3f round(r(mean))
		
		if round(r(mean),0.0001)==0 { // i.e. standardized
			local mean_`i': di %6.0f round(r(mean))
		}
		}
		if `i'==5 {
		qui su std_language_avg_ALL
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
//file write resultsfile "\begin{adjustbox}{max width=14cm}" 
//file write resultsfile "\begin{threeparttable}"
if `z' ==1{
file write resultsfile "\caption{CGI and Educational Choice}" 
file write resultsfile "\label{table 6}"
}
if `z' ==2{
file write resultsfile "\caption{CGI and Educational Choice (with controls)}" 
}
file write resultsfile "\centering" 
file write resultsfile "\begin{tabular}" 
file write resultsfile "{p{1.7cm} M{2.7cm} M{2.7cm} M{2.9cm} M{2.7cm} M{2.7cm}}" 
file write resultsfile "\toprule \toprule"
file write resultsfile "\multicolumn{1}{l}{Measure} & \multicolumn{3}{c}{Female Educational Track Share} &  \multicolumn{2}{c}{Skill Requirements} \\"
file write resultsfile "\cmidrule(lr){2-4} \cmidrule(lr){5-6} "
file write resultsfile "\multicolumn{4}{l}{} & Math  & Language  \\"
file write resultsfile "\cmidrule(lr){5-5} \cmidrule(lr){6-6} "
file write resultsfile "\multicolumn{1}{l}{Sample} & U.S Adults  & Swiss Teens & Swedish Youths &  Swiss Teens & Swiss Teens \\"
file write resultsfile "& (1) & (2) & (3) & (4)  & (5) \\"
file write resultsfile "\midrule"
file write resultsfile " \addlinespace[0.2cm]"


*-----------------------------------------------------------------------------
* Write Panel A
*-----------------------------------------------------------------------------

file write resultsfile "\multicolumn{5}{l}{\textbf{Panel A. Binary gender}} \\" _n
file write resultsfile " \multicolumn{1}{l}{Female} & $`beta_a_sex_1'$  &	$`beta_a_sex_2'$ &	$`beta_a_sex_3'$ &	$`beta_a_sex_4'$  &	$`beta_a_sex_5'$ \\" _n
file write resultsfile " & (`se_a_sex_1')	&	(`se_a_sex_2')    &	(`se_a_sex_3') &	(`se_a_sex_4') &	(`se_a_sex_5') \\" _n
file write resultsfile "\addlinespace[0.1cm]"
file write resultsfile " \multicolumn{1}{l}{$\text{R}^2$}			& `rsqua_1'	  &	`rsqua_2' &	`rsqua_3' &	`rsqua_4' &	`rsqua_5' \\ \\" _n
file write resultsfile "\addlinespace[-0.3cm]"
file write resultsfile "\midrule"

*-----------------------------------------------------------------------------
* Write Panel B
*-----------------------------------------------------------------------------
file write resultsfile "\multicolumn{5}{l}{\textbf{Panel B. Gender identity}} \\" _n
file write resultsfile " \multicolumn{1}{l}{CGI (feminine)} & $`beta_b_cgi_1'$  &	$`beta_b_cgi_2'$ &	$`beta_b_cgi_3'$ &	$`beta_b_cgi_4'$ &	$`beta_b_cgi_5'$ \\" _n
file write resultsfile "  &	(`se_b_cgi_1')  &	(`se_b_cgi_2')   &(`se_b_cgi_3') &	(`se_b_cgi_4') &	(`se_b_cgi_5') \\" _n
file write resultsfile "\addlinespace[0.1cm]"
file write resultsfile " \multicolumn{1}{l}{$\text{R}^2$}			& `rsqub_1'	& `rsqub_2' & `rsqub_3' &	`rsqub_4' &	`rsqub_5' \\ \\" _n
file write resultsfile "\addlinespace[-0.3cm]"
file write resultsfile "\midrule"

*-----------------------------------------------------------------------------
* Write Panel C
*-----------------------------------------------------------------------------
file write resultsfile "\multicolumn{5}{l}{\textbf{Panel C. Binary gender and gender identity}} \\" _n
file write resultsfile " \multicolumn{1}{l}{Female} & $`beta_c_sex_1'$  &	$`beta_c_sex_2'$	& $`beta_c_sex_3'$ 	&	$`beta_c_sex_4'$ &	$`beta_c_sex_5'$ \\" _n
file write resultsfile " & (`se_c_sex_1')	   &	(`se_c_sex_2')	& (`se_c_sex_3')  &	(`se_c_sex_4') &	(`se_c_sex_5') \\ \\" _n
file write resultsfile "\addlinespace[-0.3cm]"
file write resultsfile " \multicolumn{1}{l}{CGI (feminine)} & $`beta_c_cgi_1'$  &	$`beta_c_cgi_2'$ &	$`beta_c_cgi_3'$ &	$`beta_c_cgi_4'$ &	$`beta_c_cgi_5'$ \\" _n
file write resultsfile " & (`se_c_cgi_1')	 &	(`se_c_cgi_2')    &	(`se_c_cgi_3')	&	(`se_c_cgi_4') &	(`se_c_cgi_5') \\" _n
file write resultsfile "\addlinespace[0.1cm]"
file write resultsfile " \multicolumn{1}{l}{$\text{R}^2$}	& `rsquc_1' & `rsquc_2' &	`rsquc_3' & `rsquc_4' &	`rsquc_5' \\ \\" _n		
file write resultsfile "\addlinespace[-0.3cm]"
file write resultsfile "\midrule"

*-----------------------------------------------------------------------------
* Write Panel D
*-----------------------------------------------------------------------------
file write resultsfile "\multicolumn{5}{l}{\textbf{Panel D. Sample split by binary gender}} \\" _n
file write resultsfile "  \multicolumn{1}{l}{Female: CGI (feminine)}  & $`beta_f_cgi_1'$  &	$`beta_f_cgi_2'$ &	$`beta_f_cgi_3'$ &	$`beta_f_cgi_4'$ &	$`beta_f_cgi_5'$ \\" _n
file write resultsfile "  & (`se_f_cgi_1')	   &	(`se_f_cgi_2') &	(`se_f_cgi_3')	&	(`se_f_cgi_4') &	(`se_f_cgi_5')  \\" _n	
file write resultsfile "\addlinespace[0.1cm]"
file write resultsfile " \multicolumn{1}{l}{$\text{R}^2$}	& `rsquf_1'	&	`rsquf_2'   &	`rsquf_3' &	`rsquf_4' &	`rsquf_5' \\ \\" _n
file write resultsfile "\addlinespace[-0.3cm]"	

file write resultsfile " \multicolumn{1}{l}{Male: CGI (feminine)} & $`beta_m_cgi_1'$  &	$`beta_m_cgi_2'$ &	$`beta_m_cgi_3'$ &	$`beta_m_cgi_4'$ &	$`beta_m_cgi_5'$  \\" _n
file write resultsfile " & (`se_m_cgi_1')	  &	(`se_m_cgi_2') &	(`se_m_cgi_3') &	(`se_m_cgi_4') &	(`se_m_cgi_5') \\" _n
file write resultsfile "\addlinespace[0.1cm]"
file write resultsfile " \multicolumn{1}{l}{$\text{R}^2$}	& `rsqum_1'	 & `rsqum_2'   &	`rsqum_3' &	`rsqum_4' &	`rsqum_5' \\ \\" _n	
file write resultsfile "\addlinespace[-0.3cm]"
file write resultsfile "\multicolumn{5}{l}{Test: male sample split CGI = female sample split CGI} \\" _n
file write resultsfile "\addlinespace[-0.6cm]"
file write resultsfile " \multicolumn{1}{l}{p-value} & $`panelD_test_1'$  &	$`panelD_test_2'$ &	$`panelD_test_3'$ &	$`panelD_test_4'$ &	$`panelD_test_5'$  \\" _n
file write resultsfile "\addlinespace[-0.5cm]"
file write resultsfile "\midrule"

*-----------------------------------------------------------------------------
* Write Obs number row
*-----------------------------------------------------------------------------
file write resultsfile " \multicolumn{1}{l}{Observations} & `N_1' & `N_2' & `N_3' & `N_4' & `N_5' \\ \\" _n
file write resultsfile "\addlinespace[-0.3cm]"


*-----------------------------------------------------------------------------
* Write mean of dependent variable
*-----------------------------------------------------------------------------
* get rid of the mean decimals for the standardized variables
		
file write resultsfile "\multicolumn{1}{l}{Mean of Dependent Variable}  & `mean_1' & `mean_2' & `mean_3' & `mean_4' & `mean_5' \\ \\" _n
file write resultsfile "\addlinespace[-0.3cm]"

*-----------------------------------------------------------------------------
* Write Table footer
*-----------------------------------------------------------------------------
file write resultsfile "\bottomrule\bottomrule"
file write resultsfile "\end{tabular}"
//file write resultsfile "\begin{tablenotes}[para,flushleft] \small"

//if `z'==1 {
//file write resultsfile "\item \textit{Notes:} The table regresses the occupational choice measures on our standardized measure of CGI. U.S. Adults (age 30-59), Swiss Teens and Swedish Youths samples are used. The estimates in each column and panel come from a separate regression. Female study field share is the percentage of women enrolling in a field of study among graduates of bachelor's degree or higher for US Adults; the percentage of women from past cohorts of graduates from the apprenticeship for Swiss Teens. Skills requirements, including math and native language skills, are based on expert evaluation of the job content in occupations chosen by Swiss Teens to start apprenticeships. The skill requirement measures are standardized to have a mean of 0 and a standard deviation of 1. Robust standard errors are reported in the parenthesis. Significance levels in Panels B, C and D are determined by a one-tailed test in the direction of the coefficient estimate of female in Panel A. *** p$<$0.005, ** p$<$0.01, * p$<$0.05." 
//}

//if `z'==2 {
//file write resultsfile "\item \textit{Notes:} The table regresses the occupational choice measures on our standardized measure of CGI. U.S. Adults (age 30-59), Swiss Teens and Swedish Youths samples are used. The controls are as follows: quadratic age, race, division and wave for US adults;  grade level and survey round for Swiss Teens; school for Swedish Youth. The estimates in each column and panel come from a separate regression. Female study field share is the percentage of women enrolling in a field of study among graduates of bachelor's degree or higher for US Adults; the percentage of women from past cohorts of graduates from the apprenticeship for Swiss Teens. Skills requirements, including math and native language skills, are based on expert evaluation of the job content in occupations chosen by Swiss Teens to start apprenticeships. The skill requirement measures are standardized to have a mean of 0 and a standard deviation of 1. Robust standard errors are reported in the parenthesis. Significance levels in Panels B, C and D are determined by a one-tailed test in the direction of the coefficient estimate of female in Panel A. *** p$<$0.005, ** p$<$0.01, * p$<$0.05." 
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
	replace col_num = `i' in `i' //column number as shown the table
	}
	
	* Save the dataset to a Stata data file
    save "$path/1_data/5_meta/3_adjR2/`tableid'.dta", replace

restore 

}
}
*-------------------------------------------------------------------------------




