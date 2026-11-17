clear all

global out_path "$path/3_out" 
		
local tableid "table_7"
local colno "8" 

* short code to save reg coeffs
do "$path/2_do/2_analysis/0_reg_fnc/0_regressions.do" // 2 tailed 
do "$path/2_do/2_analysis/0_reg_fnc/0_regressions_1t_+.do" // 1 tailed if sign_female>0
do "$path/2_do/2_analysis/0_reg_fnc/0_regressions_1t_-.do" // 1 tailed if sign_female<0


/* Table 7 
Column 1: Income - US Adults
Column 2: Full-time homemaker - US Adults
Column 3: Yearly working hours - US Adults
Column 4: Female industry share - US Adults (Wave 1)
Column 5: Managerial responibility - US Adults
Column 6: Performance Pay - US Adults (Wave 1)
Column 7: Wage Negotiation - US Adults
Column 8: Work Flexibility - US Adults (Wave 1)
//Column 9: Private Sector (Wave 1)
*/

forvalues z =1/1 { // no-controls version only, as in the other interaction tables
		local variables_8 income_cont homemaker yearly_work_hours_weeklyaverage industry_share manager perf_pay_yes negot_yes std_work_hours 
		local i=1

foreach var of local variables_8 {
	use "$path/1_data/2_prepared/1_usadults_w1_w2_30_60.dta", replace   	
	local controls "c.age##c.age black all_other_races i.division wave1"
	
	
* Restandardize std_cgi_main as it was standardized for age 20-60.
		drop std_cgi_main
		qui su cgi_main
		qui gen std_cgi_main=(cgi_main-r(mean))/r(sd)
		
*-----------------------------------------------------------------------------
* Sanity checks with standardizations before we start the regression analysis
*-----------------------------------------------------------------------------
		qui su std_work_hours
		assert round(r(mean),0.0001)==0
		
		qui su std_cgi_main
		assert round(r(mean),0.0001)==0
		
		qui su std_cgi_main if `var'!=.
		
		if round(r(mean),0.0001)!=0	{
		drop std_cgi_main
		qui su cgi_main if `var'!=.
		gen std_cgi_main=(cgi_main-r(mean))/r(sd)
		}
		
		
*-----------------------------------------------------------------------------
* Panel A: biological gender	 
*-----------------------------------------------------------------------------
    if `z' ==1{
	qui reg `var' female, vce(hc3)
	}
	if `z' ==2{
	qui reg `var' female `controls', vce(hc3)
	}
	
	    * Save estimates
		local rsqua_`i': di %6.3f e(r2)
		local rsqua_`i' = trim("$`rsqua_`i''$")
		beta_coeff2 female 
		local beta_a_sex_`i' `r(beta)' 
		local se_a_sex_`i' `r(se)'
		
		**** save R2 to be used for R2 meta analysis ***
		local rsqua_`i'_meta = e(r2)
		local adjrsqua_`i'_meta = e(r2_a)
		
		local sign_female = sign(_b[female])

*-----------------------------------------------------------------------------				
* Panel B: cgi	 
*-----------------------------------------------------------------------------	
	if `z' ==1{
    qui reg `var' std_cgi_main, vce(hc3)	
	}
	if `z' ==2{
	qui reg `var' std_cgi_main age squared_age black all_other_races i.division, vce(hc3)
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
	if `z' ==1{
    qui reg `var' std_cgi_main female, vce(hc3)	
	}
	if `z' ==2{
	qui reg `var' std_cgi_main female `controls', vce(hc3)
	}
	    ** Save estimates to be used in reg table
        local N_`i': di %11.0gc e(N)
        local rsquc_`i': di %6.3f e(r2)
		local rsquc_`i' = trim("$`rsquc_`i''$")
		
		if `sign_female'>0 {
			beta_coeff1_pos female
			local beta_c_sex_`i' `r(beta)'
			local se_c_sex_`i' `r(se)'
		}
		if `sign_female'<0 {
			beta_coeff1_neg female
			local beta_c_sex_`i' `r(beta)'
			local se_c_sex_`i' `r(se)'
		}
		if `sign_female'>0 {
			beta_coeff1_pos std_cgi_main 
			local beta_c_cgi_`i' `r(beta)'
			local se_c_cgi_`i' `r(se)'
		}
		
		if `sign_female'<0 {
			beta_coeff1_neg std_cgi_main 
			local beta_c_cgi_`i' `r(beta)'
			local se_c_cgi_`i' `r(se)'
		}

*-----------------------------------------------------------------------------				
* Panel D: cgi for males and cgi for females
*-----------------------------------------------------------------------------			
* Panel D for females: 
preserve
keep if female==1

		drop std_work_hours
		qui su work_hours
		qui gen std_work_hours =(work_hours -r(mean))/r(sd)	
		
		qui su std_work_hours
		assert round(r(mean),0.0001)==0
		
		drop std_cgi_main
		qui su cgi_main if `var'!=.
		gen std_cgi_main=(cgi_main-r(mean))/r(sd)
		
		
	if `z' ==1{
    qui reg `var' std_cgi_main if female == 1, vce(hc3)	  
	}
	if `z' ==2{
	qui reg `var' std_cgi_main `controls' if female == 1, vce(hc3)
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
restore
* Panel D for males: 

preserve
keep if female==0

		drop std_work_hours
		qui su work_hours
		qui gen std_work_hours =(work_hours -r(mean))/r(sd)	
		
		qui su std_work_hours
		assert round(r(mean),0.0001)==0
		
		drop std_cgi_main
		qui su cgi_main if `var'!=.
		gen std_cgi_main=(cgi_main-r(mean))/r(sd)
		
		
	if `z' ==1{
    qui reg `var' std_cgi_main if female == 0, vce(hc3)	 
	}
	if `z' ==2{
	qui reg `var' std_cgi_main `controls' if female == 0, vce(hc3)
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
restore			

*-----------------------------------------------------------------------------				
* Panel E: Interaction Female*CGI
*-----------------------------------------------------------------------------		
gen interaction=std_cgi_main*female
	
	if `z' ==1{
	qui reg `var' female std_cgi_main interaction, vce(hc3)
	}
	if `z' ==2{
	qui reg `var' female std_cgi_main interaction `controls', vce(hc3)
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
		qui su `var'
        local mean_`i': di %6.3f r(mean)
		if round(r(mean),0.0001)==0 { // i.e. standardized
			local mean_`i': di %6.0f round(r(mean))
		}
			
local i=`i'+1	
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

*-----------------------------------------------------------------------------
* Write Table header
*-----------------------------------------------------------------------------

//file write resultsfile "\begin{table}[H]"  
//file write resultsfile "\begin{adjustbox}{max width=16cm}" 
//file write resultsfile "\begin{threeparttable}"
if `z' ==1{
file write resultsfile "\caption{CGI and Labor Market Outcomes (with Binary Gender and CGI Interaction)}" 
file write resultsfile "\label{table 7}"
}

file write resultsfile "\centering" 
file write resultsfile "\begin{tabular}" 
file write resultsfile "{p{1.7cm} M{2.3cm} M{2.3cm} M{2.5cm} M{2.5cm} M{2.4cm} M{2.3cm} M{2.3cm} M{2.2cm}}" 
file write resultsfile "\toprule \toprule"
file write resultsfile "\multicolumn{1}{l}{Measure} & Income & \thead{Full-time \\ Homemaker}  & \thead{Weekly Ave. \\ Work Hours} & \thead{Female \\ Industry Share}  & \thead{Managerial \\ Responsibilities} &  \thead{Performance \\ Pay} &\thead{Wage \\ Negotiation} & \thead{Work \\ Flexibility}\\"
file write resultsfile "& (1) & (2) & (3) & (4) & (5) & (6) & (7) & (8) \\"
file write resultsfile "\midrule"
file write resultsfile" \addlinespace[0.2cm]"


*-----------------------------------------------------------------------------
* Write Panel A
*-----------------------------------------------------------------------------

file write resultsfile "\multicolumn{5}{l}{\textbf{Panel A. Binary gender}} \\" _n
file write resultsfile " \multicolumn{1}{l}{Female} & $`beta_a_sex_1'$  &	$`beta_a_sex_2'$ &	$`beta_a_sex_3'$ &	$`beta_a_sex_4'$  &	$`beta_a_sex_5'$ &	$`beta_a_sex_6'$ &	$`beta_a_sex_7'$ &	$`beta_a_sex_8'$ \\" _n
file write resultsfile " & (`se_a_sex_1')	&	(`se_a_sex_2')    &	(`se_a_sex_3') &	(`se_a_sex_4') &	(`se_a_sex_5') &	(`se_a_sex_6') &	(`se_a_sex_7') &	(`se_a_sex_8')  \\" _n
file write resultsfile "\addlinespace[0.1cm]"
file write resultsfile " \multicolumn{1}{l}{$\text{R}^2$}			& `rsqua_1'	  &	`rsqua_2' &	`rsqua_3' &	`rsqua_4' &	`rsqua_5' &	`rsqua_6' &	`rsqua_7' &	`rsqua_8' \\ \\" _n
file write resultsfile "\addlinespace[-0.3cm]"
file write resultsfile "\midrule"

*-----------------------------------------------------------------------------
* Write Panel B
*-----------------------------------------------------------------------------
file write resultsfile "\multicolumn{5}{l}{\textbf{Panel B. Gender identity}} \\" _n
file write resultsfile " \multicolumn{1}{l}{CGI (feminine)} & $`beta_b_cgi_1'$  &	$`beta_b_cgi_2'$ &	$`beta_b_cgi_3'$ &	$`beta_b_cgi_4'$ &	$`beta_b_cgi_5'$ & $`beta_b_cgi_6'$ & $`beta_b_cgi_7'$ & $`beta_b_cgi_8'$\\" _n
file write resultsfile "  &	(`se_b_cgi_1')  &	(`se_b_cgi_2')   &(`se_b_cgi_3') &	(`se_b_cgi_4') &	(`se_b_cgi_5') & (`se_b_cgi_6') & (`se_b_cgi_7') & (`se_b_cgi_8')  \\" _n
file write resultsfile "\addlinespace[0.1cm]"
file write resultsfile " \multicolumn{1}{l}{$\text{R}^2$}			& `rsqub_1'	& `rsqub_2' & `rsqub_3' &	`rsqub_4' &	`rsqub_5' &	`rsqub_6' &	`rsqub_7' &	`rsqub_8' \\ \\" _n
file write resultsfile "\addlinespace[-0.3cm]"
file write resultsfile "\midrule"

*-----------------------------------------------------------------------------
* Write Panel C
*-----------------------------------------------------------------------------
file write resultsfile "\multicolumn{5}{l}{\textbf{Panel C. Binary gender and gender identity}} \\" _n
file write resultsfile " \multicolumn{1}{l}{Female} & $`beta_c_sex_1'$  &	$`beta_c_sex_2'$	& $`beta_c_sex_3'$ 	&	$`beta_c_sex_4'$ &	$`beta_c_sex_5'$ 	&	$`beta_c_sex_6'$ &	$`beta_c_sex_7'$ &	$`beta_c_sex_8'$  \\" _n
file write resultsfile " & (`se_c_sex_1')	   &	(`se_c_sex_2')	& (`se_c_sex_3')  &	(`se_c_sex_4') &	(`se_c_sex_5') &	(`se_c_sex_6') &	(`se_c_sex_7') &	(`se_c_sex_8')  \\ \\" _n
file write resultsfile "\addlinespace[-0.3cm]"
file write resultsfile " \multicolumn{1}{l}{CGI (feminine)} & $`beta_c_cgi_1'$  &	$`beta_c_cgi_2'$ &	$`beta_c_cgi_3'$ &	$`beta_c_cgi_4'$ &	$`beta_c_cgi_5'$ &	$`beta_c_cgi_6'$ &	$`beta_c_cgi_7'$ &	$`beta_c_cgi_8'$  \\" _n
file write resultsfile " & (`se_c_cgi_1')	 &	(`se_c_cgi_2')    &	(`se_c_cgi_3')	&	(`se_c_cgi_4') &	(`se_c_cgi_5') & (`se_c_cgi_6') & (`se_c_cgi_7') & (`se_c_cgi_8')   \\" _n
file write resultsfile "\addlinespace[0.1cm]"
file write resultsfile " \multicolumn{1}{l}{$\text{R}^2$}	& `rsquc_1' & `rsquc_2' &	`rsquc_3' & `rsquc_4' &	`rsquc_5' &	`rsquc_6' &	`rsquc_7' &	`rsquc_8'  \\ \\" _n		
file write resultsfile "\addlinespace[-0.3cm]"
file write resultsfile "\midrule"

*-----------------------------------------------------------------------------
* Write Panel D
*-----------------------------------------------------------------------------
file write resultsfile "\multicolumn{5}{l}{\textbf{Panel D. Sample split by binary gender}} \\" _n
file write resultsfile "  \multicolumn{1}{l}{Female: CGI (feminine)}  & $`beta_f_cgi_1'$  &	$`beta_f_cgi_2'$ &	$`beta_f_cgi_3'$ &	$`beta_f_cgi_4'$ &	$`beta_f_cgi_5'$ &	$`beta_f_cgi_6'$ &	$`beta_f_cgi_7'$ &	$`beta_f_cgi_8'$ \\" _n
file write resultsfile "  & (`se_f_cgi_1')	   &	(`se_f_cgi_2') &	(`se_f_cgi_3')	&	(`se_f_cgi_4') &	(`se_f_cgi_5') &  (`se_f_cgi_6') &  (`se_f_cgi_7') &  (`se_f_cgi_8') \\" _n	
file write resultsfile "\addlinespace[0.1cm]"
file write resultsfile " \multicolumn{1}{l}{$\text{R}^2$}	& `rsquf_1'	&	`rsquf_2'   &	`rsquf_3' &	`rsquf_4' &	`rsquf_5' &	`rsquf_6' &	`rsquf_7' &	`rsquf_8'\\ \\" _n
file write resultsfile "\addlinespace[-0.3cm]"	

file write resultsfile " \multicolumn{1}{l}{Male: CGI (feminine)} & $`beta_m_cgi_1'$  &	$`beta_m_cgi_2'$ &	$`beta_m_cgi_3'$ &	$`beta_m_cgi_4'$ &	$`beta_m_cgi_5'$ & $`beta_m_cgi_6'$ & $`beta_m_cgi_7'$ & $`beta_m_cgi_8'$  \\" _n
file write resultsfile " & (`se_m_cgi_1')	  &	(`se_m_cgi_2') &	(`se_m_cgi_3') &	(`se_m_cgi_4') &	(`se_m_cgi_5') & (`se_m_cgi_6') & (`se_m_cgi_7') & (`se_m_cgi_8')  \\" _n
file write resultsfile "\addlinespace[0.1cm]"
file write resultsfile " \multicolumn{1}{l}{$\text{R}^2$}	& `rsqum_1'	 & `rsqum_2'   &	`rsqum_3' &	`rsqum_4' &	`rsqum_5' &	`rsqum_6' &	`rsqum_7' &	`rsqum_8' \\ \\" _n	
file write resultsfile "\addlinespace[-0.3cm]"
file write resultsfile "\midrule"

*-----------------------------------------------------------------------------
* Write Panel E
*-----------------------------------------------------------------------------
file write resultsfile "\multicolumn{5}{l}{\textbf{Panel E. Binary gender and CGI Interaction}} \\" _n
file write resultsfile " \multicolumn{1}{l}{Female} & $`beta_e_sex_1'$ &	$`beta_e_sex_2'$ &	$`beta_e_sex_3'$ &	$`beta_e_sex_4'$ &	$`beta_e_sex_5'$ &	$`beta_e_sex_6'$ &	$`beta_e_sex_7'$ &	$`beta_e_sex_8'$  \\" _n
file write resultsfile " & (`se_e_sex_1') &	(`se_e_sex_2') &	(`se_e_sex_3') &	(`se_e_sex_4') &	(`se_e_sex_5') &	(`se_e_sex_6') &	(`se_e_sex_7') &	(`se_e_sex_8')  \\ \\" _n
file write resultsfile "\addlinespace[-0.3cm]"
file write resultsfile " \multicolumn{1}{l}{CGI (feminine)} & $`beta_e_cgi_1'$ &	$`beta_e_cgi_2'$ &	$`beta_e_cgi_3'$ &	$`beta_e_cgi_4'$ &	$`beta_e_cgi_5'$ &	$`beta_e_cgi_6'$ &	$`beta_e_cgi_7'$ &	$`beta_e_cgi_8'$  \\" _n
file write resultsfile " & (`se_e_cgi_1') &	(`se_e_cgi_2') &	(`se_e_cgi_3') &	(`se_e_cgi_4') &	(`se_e_cgi_5') &	(`se_e_cgi_6') &	(`se_e_cgi_7') &	(`se_e_cgi_8')   \\" _n
file write resultsfile "\addlinespace[0.1cm]"
file write resultsfile " \multicolumn{1}{l}{Female*CGI} & $`beta_e_interaction_1'$ &	$`beta_e_interaction_2'$ &	$`beta_e_interaction_3'$ &	$`beta_e_interaction_4'$ &	$`beta_e_interaction_5'$ &	$`beta_e_interaction_6'$ &	$`beta_e_interaction_7'$ &	$`beta_e_interaction_8'$  \\" _n
file write resultsfile " & (`se_e_interaction_1') &	(`se_e_interaction_2') &	(`se_e_interaction_3') &	(`se_e_interaction_4') &	(`se_e_interaction_5') &	(`se_e_interaction_6') &	(`se_e_interaction_7') &	(`se_e_interaction_8')   \\" _n
file write resultsfile "\addlinespace[0.1cm]"
file write resultsfile " \multicolumn{1}{l}{$\text{R}^2$} & `rsque_1' &	`rsque_2' &	`rsque_3' &	`rsque_4' &	`rsque_5' &	`rsque_6' &	`rsque_7' &	`rsque_8'   \\ \\" _n
file write resultsfile "\addlinespace[-0.3cm]"
file write resultsfile "\midrule"

*-----------------------------------------------------------------------------
* Write Obs number row
*-----------------------------------------------------------------------------
file write resultsfile " \multicolumn{1}{l}{Observations} & `N_1' & `N_2' & `N_3' & `N_4' & `N_5' & `N_6' & `N_7' & `N_8' \\ \\" _n
file write resultsfile "\addlinespace[-0.3cm]"


*-----------------------------------------------------------------------------
* Write mean of dependent variable
*-----------------------------------------------------------------------------
* get rid of the mean decimals for the standardized variables
		
file write resultsfile "\multicolumn{1}{l}{Mean of Dependent Variable}  & `mean_1' & `mean_2' & `mean_3' & `mean_4' & `mean_5' & `mean_6' & `mean_7' & `mean_8'  \\ \\" _n
file write resultsfile "\addlinespace[-0.3cm]"

*-----------------------------------------------------------------------------
* Write Table footer
*-----------------------------------------------------------------------------
file write resultsfile "\bottomrule\bottomrule"
file write resultsfile "\end{tabular}"
file close resultsfile
}

}
*-------------------------------------------------------------------------------
