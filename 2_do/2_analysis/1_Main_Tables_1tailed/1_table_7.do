clear all

global out_path "$path/3_out" 
		
local tableid "table_7"
local colno "8" 

* short code to save reg coeffs
do "$path/2_do/2_analysis/0_reg_fnc/0_regressions.do" // 2 tailed 
do "$path/2_do/2_analysis/0_reg_fnc/0_regressions_1t_+.do" // 1 tailed if sign_female>0
do "$path/2_do/2_analysis/0_reg_fnc/0_regressions_1t_-.do" // 1 tailed if sign_female<0


/* Table 9 
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

forvalues z =1/2 { 
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
* Panel D: cgi for males and cgi for females
*-----------------------------------------------------------------------------			
* Panel D for females: 

	if `z' ==1{
    qui reg `var' std_cgi_main if female == 1
	}
	if `z' ==2{
	qui reg `var' std_cgi_main `controls' if female == 1
	}

 	est store female_`i'	

* Panel D for males: 
	if `z' ==1{
    qui reg `var' std_cgi_main if female == 0
	}
	if `z' ==2{
	qui reg `var' std_cgi_main `controls' if female == 0
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
file write resultsfile "\caption{CGI and Labor Market Outcomes}" 
file write resultsfile "\label{table 7}"
}
if `z' ==2{
file write resultsfile "\caption{CGI and Labor Market Outcomes (with controls)}" 
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
file write resultsfile "\multicolumn{5}{l}{Test: male sample split CGI = female sample split CGI} \\" _n
file write resultsfile "\addlinespace[-0.6cm]"
file write resultsfile " \multicolumn{1}{l}{p-value} & $`panelD_test_1'$  &	$`panelD_test_2'$ &	$`panelD_test_3'$ &	$`panelD_test_4'$ &	$`panelD_test_5'$ &	$`panelD_test_6'$ &	$`panelD_test_7'$ &	$`panelD_test_8'$ \\" _n
file write resultsfile "\addlinespace[-0.5cm]"
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
//file write resultsfile "\begin{tablenotes}[para,flushleft] \small"

//if `z'==1 {
//file write resultsfile "\item  \textit{Notes:} The table regresses the labor market outcomes on our standardized measure of CGI. The sample of the U.S. Adults (age 30-59) is used. The estimates in each column and panel come from a separate regression. Income is a self-reported categorical measure in thousand U.S. dollars.Full-time homemaker is a dummy for working full-time at home. Weekly average work hours is a proxy measure constructed from weeks worked and hours worked, using the product of the two categorical measures and dividing by 52. Female share industry is the share of female employees in a given industry. Managerial responibilities is a dummy for having managerial responsibilities at work. Performance pay is a dummy that is equal to 1 if the respondent's current or most recent job has performance-related pay. Wage negotiation is a dummy that is equal to 1 if the respondent ever negotiated wage. Work flexibility is a categorical measure of flexibility in working hours where 0 is no flexibility, 0.5 is can adapt work hours and 1 is full flexibility, which is standardized to have a mean of zero and a standard deviation of 1. Robust standard errors are reported in the parentheses. Significance levels in Panels B, C and D are determined by a one-tailed test in the direction of the coefficient estimate of female in Panel A. *** p$<$0.005, ** p$<$0.01, * p$<$0.05."
//}

//if `z'==2{
//file write resultsfile "\item  \textit{Notes:} The table regresses the labor market outcomes on our standardized measure of CGI. The sample of the U.S. Adults (age 30-59) is used. The controls are as follows: quadratic age, race, division and wave. The estimates in each column and panel come from a separate regression. Income is a self-reported categorical measure in thousand U.S. dollars.Full-time homemaker is a dummy for working full-time at home. Weekly average work hours is a proxy measure constructed from weeks worked and hours worked, using the product of the two categorical measures and dividing by 52. Female share industry is the share of female employees in a given industry. Managerial responibilities is a dummy for having managerial responsibilities at work. Performance pay is a dummy that is equal to 1 if the respondent's current or most recent job has performance-related pay. Wage negotiation is a dummy that is equal to 1 if the respondent ever negotiated wage. Work flexibility is a categorical measure of flexibility in working hours where 0 is no flexibility, 0.5 is can adapt work hours and 1 is full flexibility, which is standardized to have a mean of zero and a standard deviation of 1. Robust standard errors are reported in the parentheses. Significance levels in Panels B, C and D are determined by a one-tailed test in the direction of the coefficient estimate of female in Panel A. *** p$<$0.005, ** p$<$0.01, * p$<$0.05."
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




