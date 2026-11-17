clear all

global out_path "$path/3_out" 
				
local tableid "table_5"
local colno "6" 
local dropped_panelC "4"

* short code to save reg coeffs
do "$path/2_do/2_analysis/0_reg_fnc/0_regressions.do" // 2 tailed 
do "$path/2_do/2_analysis/0_reg_fnc/0_regressions_1t_+.do" // 1 tailed if sign_female>0
do "$path/2_do/2_analysis/0_reg_fnc/0_regressions_1t_-.do" // 1 tailed if sign_female<0


/*
Column 1: Redistribution - Swiss Uni
Column 2: Redistribution - US adults

Column 3: Donation - Swiss Uni
Column 4: Donation - US adults
Column 5: Donation - Swiss Teens
Column 6: Donation - Swedish Youth
*/

forvalues z =1/1{ 

forvalues i=1/6{ 
	if `i'==1| `i'==3{
		use "$path/1_data/2_prepared/1_SwissUni.dta", clear
		local controls "c.age##c.age educ_control"

	}	
	if `i'==2 | `i'==4{
		use "$path/1_data/2_prepared/1_usadults_w1_w2_30_60.dta", clear
		local controls "c.age##c.age black all_other_races i.division wave1"	
		
		* Restandardize std_cgi_main as it was standardized for age 20-60.
		drop std_cgi_main
		qui su cgi_main
		qui gen std_cgi_main=(cgi_main-r(mean))/r(sd)
		
		* Restandardize the outcome variables as they were standardized for age 20-60.
		drop std_redistribution
		qui su redistribution
		qui gen std_redistribution=(redistribution-r(mean))/r(sd)
		
		* Restandardize the outcome variables as they were standardized for age 20-60.
		drop std_donation
		qui su donation
		qui gen std_donation=(donation-r(mean))/r(sd)	
	}
	if `i'==5{
		use "$path/1_data/2_prepared/1_swissteens.dta", clear
		local controls "grade_8 grade_9 march_survey"
	}
	if `i'==6{
		use "$path/1_data/2_prepared/1_Swedishyouth.dta", clear
		local controls "i.school_new"
	}
	
	
*-----------------------------------------------------------------------------
* Sanity checks with standardizations before we start the regression analysis
*-----------------------------------------------------------------------------
		
* Outcome variables
		if `i'==1 |`i'==2 {
		qui su std_redistribution
		assert round(r(mean),0.0001)==0
		}		
		if `i'==3 | `i'==4 |`i'==5 |`i'==6{
		qui su std_donation 
		assert round(r(mean),0.001)==0
		}
		
		
* CGI
		if `i'==1  {
		qui su std_cgi_main if std_redistribution!=.
		assert round(r(mean),0.0001)==0		
		}		
		if `i'==2 {
		qui su std_cgi_main if std_redistribution!=.
		assert round(r(mean),0.0001)==0		
		}	
		if `i'==3 {
		qui su std_cgi_main if std_donation!=.
		assert round(r(mean),0.0001)==0		
		}
		if `i'==4 {
		qui su std_cgi_main if std_donation!=.
		assert round(r(mean),0.0001)==0				
		}
		if `i'==5 {
		qui su std_cgi_main if std_donation!=.
		//assert round(r(mean),0.0001)==0		
		drop std_cgi_main
		qui su cgi_main if std_donation!=.
		gen std_cgi_main=(cgi_main-r(mean))/r(sd)
		
		qui su std_cgi_main if std_donation!=.
		assert round(r(mean),0.0001)==0	
		}
		if `i'==6 {
		qui su std_cgi_main if std_donation!=.
		assert round(r(mean),0.0001)==0		
		}

*-----------------------------------------------------------------------------
* Panel A: biological gender	 
*-----------------------------------------------------------------------------
	if `z'== 1 { //no controls
		if `i'==1 |`i'==2 {
		qui reg std_redistribution female, vce(hc3) 
		}		
		if `i'==3 | `i'==4 |`i'==5 |`i'==6{
		qui reg std_donation female, vce(hc3) 
		}
	}	
	if `z' ==2 {// with controls
		if `i'==1 |`i'==2 {
		qui reg std_redistribution female `controls', vce(hc3) 
		}		
		if `i'==3 | `i'==4 |`i'==5 |`i'==6{
		qui reg std_donation female `controls', vce(hc3) 
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
		if `i'==1 |`i'==2 {
		qui reg std_redistribution std_cgi_main, vce(hc3) 
		}		
		if `i'==3 | `i'==4 |`i'==5 |`i'==6{
		qui reg std_donation std_cgi_main, vce(hc3) 
		}
	}	
	if `z' ==2 {// with controls       
		if `i'==1 |`i'==2 {
		qui reg std_redistribution std_cgi_main `controls', vce(hc3) 
		}		
		if `i'==3 | `i'==4 |`i'==5 |`i'==6{
		qui reg std_donation std_cgi_main `controls', vce(hc3) 
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
		if `i'==1 |`i'==2 {
		qui reg std_redistribution female std_cgi_main, vce(hc3) 
		}		
		if `i'==3 | `i'==4 |`i'==5 |`i'==6{
		qui reg std_donation female std_cgi_main, vce(hc3) 
		}
	}	
	if `z' ==2 {// with controls  
		if `i'==1 |`i'==2 {
		qui reg std_redistribution female std_cgi_main `controls', vce(hc3) 
		}		
		if `i'==3 | `i'==4 |`i'==5 |`i'==6{
		qui reg std_donation female std_cgi_main `controls', vce(hc3) 
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

* Outcome variables
		if `i'==1 |`i'==2 {
		drop std_redistribution
		qui su redistribution
		qui gen std_redistribution =(redistribution-r(mean))/r(sd)		
		
		qui su std_redistribution
		assert round(r(mean),0.0001)==0
		}		
		
		if `i'==3 | `i'==4 |`i'==5 |`i'==6{
		drop std_donation
		qui su donation
		qui gen std_donation =(donation-r(mean))/r(sd)		
		
		qui su std_donation 
		assert round(r(mean),0.0001)==0
		}
		
		
* CGI
		if `i'==1  {
		drop std_cgi_main
		qui su cgi_main if std_redistribution!=.!=.
		gen std_cgi_main=(cgi_main-r(mean))/r(sd)
		
		qui su std_cgi_main if std_redistribution!=.!=.
		assert round(r(mean),0.0001)==0		

		}		
		if `i'==2 {
		drop std_cgi_main
		qui su cgi_main if std_redistribution!=.!=.
		gen std_cgi_main=(cgi_main-r(mean))/r(sd)
		
		qui su std_cgi_main if std_redistribution!=.!=.
		assert round(r(mean),0.0001)==0		
		}	
		if `i'==3 {
		drop std_cgi_main
		qui su cgi_main if std_donation!=.
		gen std_cgi_main=(cgi_main-r(mean))/r(sd)
		
		qui su std_cgi_main if std_donation!=.
		assert round(r(mean),0.0001)==0		
		}
		if `i'==4 {
		drop std_cgi_main
		qui su cgi_main if std_donation!=.
		gen std_cgi_main=(cgi_main-r(mean))/r(sd)
		
		qui su std_cgi_main if std_donation!=.
		assert round(r(mean),0.0001)==0				
		}
		if `i'==5 {
		drop std_cgi_main
		qui su cgi_main if std_donation!=.
		gen std_cgi_main=(cgi_main-r(mean))/r(sd)
		
		qui su std_cgi_main if std_donation!=.
		assert round(r(mean),0.0001)==0	
		}
		if `i'==6 {
		drop std_cgi_main
		qui su cgi_main if std_donation!=.
		gen std_cgi_main=(cgi_main-r(mean))/r(sd)
		
		qui su std_cgi_main if std_donation!=.
		assert round(r(mean),0.0001)==0		
		}


	if `z'== 1 { //no controls
		if `i'==1 |`i'==2 {
		qui reg std_redistribution female std_cgi_main if female==1, vce(hc3) 
		}		
		if `i'==3 | `i'==4 |`i'==5 |`i'==6{
		qui reg std_donation female std_cgi_main if female==1, vce(hc3) 
		}
	}	
	if `z' ==2 {// with controls   
    	if `i'==1 |`i'==2 {
		qui reg std_redistribution female std_cgi_main `controls' if female==1, vce(hc3) 
		}		
		if `i'==3 | `i'==4 |`i'==5 |`i'==6{
		qui reg std_donation female std_cgi_main `controls' if female==1, vce(hc3) 
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

preserve			
* Panel D for males: 
keep if female==0
* Outcome variables
		if `i'==1 |`i'==2 {
		drop std_redistribution
		qui su redistribution
		qui gen std_redistribution =(redistribution-r(mean))/r(sd)		
		
		qui su std_redistribution
		assert round(r(mean),0.0001)==0

		}		
		if `i'==3 | `i'==4 |`i'==5 |`i'==6{
		drop std_donation
		qui su donation
		qui gen std_donation =(donation-r(mean))/r(sd)		
		
		qui su std_donation 
		assert round(r(mean),0.0001)==0
		}
		
		
* CGI
	if `i'==1  {
		drop std_cgi_main
		qui su cgi_main if std_redistribution!=.!=.
		gen std_cgi_main=(cgi_main-r(mean))/r(sd)
		
		qui su std_cgi_main if std_redistribution!=.!=.
		assert round(r(mean),0.0001)==0		

		}		
		if `i'==2 {
		drop std_cgi_main
		qui su cgi_main if std_redistribution!=.!=.
		gen std_cgi_main=(cgi_main-r(mean))/r(sd)
		
		qui su std_cgi_main if std_redistribution!=.!=.
		assert round(r(mean),0.0001)==0		
		}	
		if `i'==3 {
		drop std_cgi_main
		qui su cgi_main if std_donation!=.
		gen std_cgi_main=(cgi_main-r(mean))/r(sd)
		
		qui su std_cgi_main if std_donation!=.
		assert round(r(mean),0.0001)==0		
		}
		if `i'==4 {
		drop std_cgi_main
		qui su cgi_main if std_donation!=.
		gen std_cgi_main=(cgi_main-r(mean))/r(sd)
		
		qui su std_cgi_main if std_donation!=.
		assert round(r(mean),0.0001)==0				
		}
		if `i'==5 {
		drop std_cgi_main
		qui su cgi_main if std_donation!=.
		gen std_cgi_main=(cgi_main-r(mean))/r(sd)
		
		qui su std_cgi_main if std_donation!=.
		assert round(r(mean),0.0001)==0	
		}
		if `i'==6 {
		drop std_cgi_main
		qui su cgi_main if std_donation!=.
		gen std_cgi_main=(cgi_main-r(mean))/r(sd)
		
		qui su std_cgi_main if std_donation!=.
		assert round(r(mean),0.0001)==0		
		}
	if `z'== 1 { //no controls
		if `i'==1 |`i'==2 {
		qui reg std_redistribution female std_cgi_main if female==0, vce(hc3) 
		}		
		if `i'==3 | `i'==4 |`i'==5 |`i'==6{
		qui reg std_donation female std_cgi_main if female==0, vce(hc3) 
		}
	}	
	if `z' ==2 {// with controls    
		if `i'==1 |`i'==2 {
		qui reg std_redistribution female std_cgi_main `controls' if female==0, vce(hc3) 
		}		
		if `i'==3 | `i'==4 |`i'==5 |`i'==6{
		qui reg std_donation female std_cgi_main `controls' if female==0, vce(hc3) 
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
* Panel E: Interaction Female*CGI
*-----------------------------------------------------------------------------			
gen interaction=std_cgi_main*female
	
	if `z'== 1 { //no controls
		if `i'==1 |`i'==2 {
		qui reg std_redistribution female std_cgi_main interaction, vce(hc3) 
		}		
		if `i'==3 | `i'==4 |`i'==5 |`i'==6{
		qui reg std_donation female std_cgi_main interaction, vce(hc3) 
		}
	}	
	if `z' ==2 {// with controls  
		if `i'==1 |`i'==2 {
		qui reg std_redistribution female std_cgi_main interaction `controls', vce(hc3) 
		}		
		if `i'==3 | `i'==4 |`i'==5 |`i'==6{
		qui reg std_donation female std_cgi_main interaction `controls', vce(hc3) 
		}
	}	

	    ** Save estimates to be used in reg table
		local rsque_`i': di %6.3f `e(r2)'
		local rsque_`i' = trim("$`rsque_`i''$")

		if `sign_female'>0 {
			beta_coeff1_pos female		
			local beta_e_sex_`i' `r(beta)'
			local se_e_sex_`i' `r(se)'	
			
			beta_coeff1_pos std_cgi_main 
			local beta_e_cgi_`i' `r(beta)'
			local se_e_cgi_`i' `r(se)'
		}
		
		if `sign_female'<0 {
			beta_coeff1_neg female		
			local beta_e_sex_`i' `r(beta)'
			local se_e_sex_`i' `r(se)'	
			
			beta_coeff1_neg std_cgi_main 
			local beta_e_cgi_`i' `r(beta)'
			local se_e_cgi_`i' `r(se)'
		}
		
		beta_coeff2 interaction
		local beta_e_interaction_`i' `r(beta)'
		local se_e_interaction_`i' `r(se)'
		
*-----------------------------------------------------------------------------				
* Store the mean of each dependent variable 	
*-----------------------------------------------------------------------------					
		if `i'==1 |`i'==2 {
		qui su std_redistribution
		local  mean_`i': di %6.3f round(r(mean))
		
			if round(r(mean),0.0001)==0 { // i.e. standardized
			local mean_`i': di %6.0f round(r(mean))
		}
		}			
		if `i'==3 | `i'==4 |`i'==5 |`i'==6{
		qui su std_donation
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

foreach path in out_path {
	
if `z' ==1{
        file open resultsfile using "$`path'/Tables_Main_Interaction/`tableid'.tex", write replace
}	

/*
if `z' ==2{
	   file open resultsfile using "$`path'/Tables_Controls/`tableid'.tex", write replace
}	
*/


*-----------------------------------------------------------------------------
* Write Table header
*-----------------------------------------------------------------------------
//file write resultsfile "\begin{table}[H]"  
//file write resultsfile "\begin{adjustbox}{max width=14cm}" 
//file write resultsfile "\begin{threeparttable}"
 
if `z' ==1{
file write resultsfile "\caption{CGI and Unincentivized Distributional Preferences (with Binary Gender and CGI Interaction) }" 
file write resultsfile "\label{table 5}"
}

file write resultsfile "\centering" 
file write resultsfile "\begin{tabular}" 
file write resultsfile "{p{1.7cm} M{2.5cm} M{2.5cm} M{2.5cm} M{2.5cm} M{2.5cm} M{2.9cm}}" 
file write resultsfile "\toprule \toprule"
file write resultsfile "\addlinespace[0.2cm]"
file write resultsfile "\multicolumn{1}{l}{Measure} & \multicolumn{2}{c}{Redistribution} & \multicolumn{4}{c}{Altruism} \\"
file write resultsfile "\cmidrule(lr){2-3} \cmidrule(lr){4-7} \\"
file write resultsfile "\multicolumn{1}{l}{Sample} & Swiss Uni & U.S. Adults & Swiss Uni & U.S. Adults & Swiss Teens & Swedish Youths \\"
file write resultsfile "& (1) & (2) & (3) & (4) & (5) & (6) \\"
file write resultsfile "\midrule"
file write resultsfile" \addlinespace[0.2cm]"

*-----------------------------------------------------------------------------
* Write Panel A
*-----------------------------------------------------------------------------

file write resultsfile "\multicolumn{5}{l}{\textbf{Panel A. Binary gender}} \\" _n
file write resultsfile " \multicolumn{1}{l}{Female} & $`beta_a_sex_1'$  &	$`beta_a_sex_2'$ &	$`beta_a_sex_3'$ &	$`beta_a_sex_4'$ &	$`beta_a_sex_5'$ &	$`beta_a_sex_6'$ \\" _n
file write resultsfile " & (`se_a_sex_1')	&	(`se_a_sex_2')    &	(`se_a_sex_3') &	(`se_a_sex_4') &	(`se_a_sex_5') &	(`se_a_sex_6') \\" _n
file write resultsfile "\addlinespace[0.1cm]"
file write resultsfile " \multicolumn{1}{l}{$\text{R}^2$}			& `rsqua_1'	  &	`rsqua_2' &	`rsqua_3' &	`rsqua_4' &	`rsqua_5' &	`rsqua_6' \\ \\" _n
file write resultsfile "\addlinespace[-0.3cm]"
file write resultsfile "\midrule"

*-----------------------------------------------------------------------------
* Write Panel B
*-----------------------------------------------------------------------------
file write resultsfile "\multicolumn{5}{l}{\textbf{Panel B. Gender identity}} \\" _n
file write resultsfile " \multicolumn{1}{l}{CGI (feminine)} & $`beta_b_cgi_1'$  &	$`beta_b_cgi_2'$ &	$`beta_b_cgi_3'$ &	\phantom{$`beta_b_cgi_4'$} &	$`beta_b_cgi_5'$ &	$`beta_b_cgi_6'$\\" _n
file write resultsfile "  &	(`se_b_cgi_1')  &	(`se_b_cgi_2')   &(`se_b_cgi_3') &	\phantom{(`se_b_cgi_4')} &	(`se_b_cgi_5') &	(`se_b_cgi_6')\\" _n
file write resultsfile "\addlinespace[0.1cm]"
file write resultsfile " \multicolumn{1}{l}{$\text{R}^2$}			& `rsqub_1'	& `rsqub_2' & `rsqub_3' &	\phantom{`rsqub_4'} &	`rsqub_5' &	`rsqub_6'  \\ \\" _n
file write resultsfile "\addlinespace[-0.3cm]"
file write resultsfile "\midrule"

*-----------------------------------------------------------------------------
* Write Panel C
*-----------------------------------------------------------------------------
file write resultsfile "\multicolumn{5}{l}{\textbf{Panel C. Binary gender and gender identity}} \\" _n
file write resultsfile " \multicolumn{1}{l}{Female} & $`beta_c_sex_1'$  &	$`beta_c_sex_2'$	& $`beta_c_sex_3'$ 	&	\phantom{$`beta_c_sex_4'$} &  $`beta_c_sex_5'$ &	$`beta_c_sex_6'$ \\" _n
file write resultsfile " & (`se_c_sex_1')	   &	(`se_c_sex_2')	& (`se_c_sex_3')  &	\phantom{(`se_c_sex_4')} &	(`se_c_sex_5') &	(`se_c_sex_6') \\ \\" _n
file write resultsfile "\addlinespace[-0.3cm]"
file write resultsfile " \multicolumn{1}{l}{CGI (feminine)} & $`beta_c_cgi_1'$  &	$`beta_c_cgi_2'$ &	$`beta_c_cgi_3'$ &	\phantom{$`beta_c_cgi_4'$}  &	$`beta_c_cgi_5'$ &	$`beta_c_cgi_6'$ \\" _n
file write resultsfile " & (`se_c_cgi_1')	 &	(`se_c_cgi_2')    &	(`se_c_cgi_3')	&	\phantom{(`se_c_cgi_4')} &	(`se_c_cgi_5') &	(`se_c_cgi_6') \\" _n
file write resultsfile "\addlinespace[0.1cm]"
file write resultsfile " \multicolumn{1}{l}{$\text{R}^2$}	& `rsquc_1' & `rsquc_2' &	`rsquc_3' & \phantom{`rsquc_4'} & `rsquc_5' & `rsquc_6' \\ \\" _n		
file write resultsfile "\addlinespace[-0.3cm]"
file write resultsfile "\midrule"

*-----------------------------------------------------------------------------
* Write Panel D
*-----------------------------------------------------------------------------
file write resultsfile "\multicolumn{5}{l}{\textbf{Panel D. Sample split by binary gender}} \\" _n
file write resultsfile "  \multicolumn{1}{l}{Female: CGI (feminine)}  & $`beta_f_cgi_1'$  &	$`beta_f_cgi_2'$ &	$`beta_f_cgi_3'$ &	\phantom{$`beta_f_cgi_4'$} &	$`beta_f_cgi_5'$ &	$`beta_f_cgi_6'$ \\" _n
file write resultsfile "  & (`se_f_cgi_1')	   &	(`se_f_cgi_2') &	(`se_f_cgi_3')	&	\phantom{(`se_f_cgi_4')} &	(`se_f_cgi_5') &	(`se_f_cgi_6')\\" _n	
file write resultsfile "\addlinespace[0.1cm]"
file write resultsfile " \multicolumn{1}{l}{$\text{R}^2$}	& `rsquf_1'	&	`rsquf_2'   &	`rsquf_3' &	\phantom{`rsquf_4'} &	`rsquf_5' &	`rsquf_6' \\ \\" _n
file write resultsfile "\addlinespace[-0.3cm]"	

file write resultsfile " \multicolumn{1}{l}{Male: CGI (feminine)} & $`beta_m_cgi_1'$  &	$`beta_m_cgi_2'$ &	$`beta_m_cgi_3'$ &	\phantom{$`beta_m_cgi_4'$} &	$`beta_m_cgi_5'$ &	$`beta_m_cgi_6'$ \\" _n
file write resultsfile " & (`se_m_cgi_1')	  &	(`se_m_cgi_2') &	(`se_m_cgi_3') &	\phantom{(`se_m_cgi_4')} &	(`se_m_cgi_5') &	(`se_m_cgi_6') \\" _n
file write resultsfile "\addlinespace[0.1cm]"
file write resultsfile " \multicolumn{1}{l}{$\text{R}^2$}	& `rsqum_1'	 & `rsqum_2'   &	`rsqum_3' &	\phantom{`rsqum_4'} &	`rsqum_5' &	`rsqum_6'\\ \\" _n	
file write resultsfile "\addlinespace[-0.3cm]"
file write resultsfile "\midrule"


*-----------------------------------------------------------------------------
* Write Panel E
*-----------------------------------------------------------------------------
file write resultsfile "\multicolumn{5}{l}{\textbf{Panel E. Binary gender and CGI interaction}} \\" _n
file write resultsfile " \multicolumn{1}{l}{Female} & $`beta_e_sex_1'$  &	$`beta_e_sex_2'$ &	$`beta_e_sex_3'$	&	\phantom{$`beta_e_sex_4'$} &	$`beta_e_sex_5'$  &	$`beta_e_sex_6'$ \\" _n
file write resultsfile " & (`se_e_sex_1')	  &	(`se_e_sex_2') &	(`se_e_sex_3')	&	\phantom{(`se_e_sex_4')} &	(`se_e_sex_5') & (`se_e_sex_6') \\ \\" _n	
file write resultsfile "\addlinespace[-0.3cm]"
file write resultsfile " \multicolumn{1}{l}{CGI (feminine)} & $`beta_e_cgi_1'$  &	$`beta_e_cgi_2'$ &	$`beta_e_cgi_3'$ &	\phantom{$`beta_e_cgi_4'$} &	$`beta_e_cgi_5'$ &	$`beta_e_cgi_6'$  \\" _n
file write resultsfile " & (`se_e_cgi_1')	 &	(`se_e_cgi_2')    &	(`se_e_cgi_3')	&	\phantom{(`se_e_cgi_4')} &	(`se_e_cgi_5') & (`se_e_cgi_6')  \\" _n
file write resultsfile "\addlinespace[0.1cm]"
file write resultsfile " \multicolumn{1}{l}{Female*CGI} & $`beta_e_interaction_1'$  &	$`beta_e_interaction_2'$ &	$`beta_e_interaction_3'$ &	\phantom{$`beta_e_interaction_4'$} &	$`beta_e_interaction_5'$ &	$`beta_e_interaction_6'$  \\" _n
file write resultsfile " & (`se_e_interaction_1')	 &	(`se_e_interaction_2')    &	(`se_e_interaction_3')	&	\phantom{(`se_e_interaction_4')} &	(`se_e_interaction_5') & (`se_e_interaction_6')   \\" _n
file write resultsfile "\addlinespace[0.1cm]"
file write resultsfile " \multicolumn{1}{l}{$\text{R}^2$} & `rsque_1' & `rsque_2' &	`rsque_3' & \phantom{`rsque_4'} &	`rsque_5' &	`rsque_6'  \\ \\" _n		
file write resultsfile "\addlinespace[-0.3cm]"
file write resultsfile "\midrule"


*-----------------------------------------------------------------------------
* Write Obs number row
*-----------------------------------------------------------------------------
file write resultsfile " \multicolumn{1}{l}{Observations} & `N_1' & `N_2' & `N_3' & `N_4' & `N_5' & `N_6' \\ \\" _n
file write resultsfile "\addlinespace[-0.3cm]"

*-----------------------------------------------------------------------------
* Write mean of dependent variable
*-----------------------------------------------------------------------------
* get rid of the mean decimals for the standardized variables
		
file write resultsfile "\multicolumn{1}{l}{Mean of Dependent Variable}  & `mean_1' & `mean_2' & `mean_3' & `mean_4' & `mean_5' & `mean_6' \\ \\" _n
file write resultsfile "\addlinespace[-0.3cm]"

*-----------------------------------------------------------------------------
* Write Table footer
*-----------------------------------------------------------------------------
file write resultsfile "\bottomrule\bottomrule"
file write resultsfile "\end{tabular}"
//file write resultsfile "\begin{tablenotes}[para,flushleft] \small"
//if `z'==1{
//file write resultsfile "\item \textit{Notes:} The table presents results from regressing unincentivized distributional measures on our standardized measure of CGI. Swiss Uni, U.S. Adults (age 30-59), Swiss Teens and Swedish Youths samples are used. The estimates in each column and panel come from a separate regression. The table presents results from regressing self-reported preferences on redistribution and altruism on our standardized measure of CGI. Redistribution is a measure of how much economic redistribution one wants in the society. Altruism is a measure of how much one would donate with a windfall gain. A higher value means the greater willingness to redistribute or donate. All outcome measures are standardized (to have a mean of 0 and a standard deviation of 1). Robust standard errors are reported in the parentheses. Significance levels in Panels B, C and D are determined by a one-tailed test in the direction of the coefficient estimate of female in Panel A. *** p$<$0.005, ** p$<$0.01, * p$<$0.05."
//}

//if `z'==2{
//file write resultsfile "\item \textit{Notes:} The table presents results from regressing unincentivized distributional measures on our standardized measure of CGI. Swiss Uni, U.S. Adults (age 30-59), Swiss Teens and Swedish Youth samples are used. The controls are as follows: quadratic age, race, division and wave for US adults; quadratic age and education level for Swiss Uni; grade level and survey round for Swiss Teens; school for Swedish Youths. The estimates in each column and panel come from a separate regression. The table presents results from regressing self-reported preferences on redistribution and altruism on our standardized measure of CGI. Redistribution is a measure of how much economic redistribution one wants in the society. Altruism is a measure of how much one would donate with a windfall gain. A higher value means the greater willingness to redistribute or donate. All outcome measures are standardized (to have a mean of 0 and a standard deviation of 1). Robust standard errors are reported in the parentheses. Significance levels in Panels B, C and D are determined by a one-tailed test in the direction of the coefficient estimate of female in Panel A. *** p$<$0.005, ** p$<$0.01, * p$<$0.05."

//}

//file write resultsfile "\end{tablenotes}"
//file write resultsfile "\end{threeparttable}"
//file write resultsfile "\end{adjustbox}"
//file write resultsfile "\end{table}"
file close resultsfile
}


}

*-------------------------------------------------------------------------------














