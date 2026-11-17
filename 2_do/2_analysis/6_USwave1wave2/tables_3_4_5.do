clear all

global out_path "$path/3_out" 
		
local tableid "tables_3_4_5"

* short code to save reg coeffs
do "$path/2_do/2_analysis/0_reg_fnc/0_regressions.do" // 2 tailed 
do "$path/2_do/2_analysis/0_reg_fnc/0_regressions_1t_+.do" // 1 tailed if sign_female>0
do "$path/2_do/2_analysis/0_reg_fnc/0_regressions_1t_-.do" // 1 tailed if sign_female<0


use "$path/1_data/2_prepared/1_usadults_w1_w2_30_60.dta", clear

* standardization at wave level
local var_to_std incentivized_risk hypothetical_risk competitiveness redistribution donation
foreach var of local var_to_std {
forvalues z =1/2{ 
qui su `var' if Wave==`z'
gen w`z'_std_`var'=(`var'-r(mean))/r(sd)
}
}
* Restandardize std_cgi_main at wave level.
drop std_cgi_main
forvalues z =1/2{ 
qui su cgi_main if Wave==`z'
qui gen w`z'_std_cgi_main=(cgi_main-r(mean))/r(sd)
}

gen  w1_std_financial_market=financial_market // financial market risk is the only non-standardized variable. I am adding std_ at the beginning so that I can loop through all variables

gen  w2_std_financial_market=financial_market

forvalues z =1/2{ // wave 1 and 2
local variables incentivized_risk hypothetical_risk financial_market competitiveness redistribution donation
local i=1

foreach var of local variables {	
*-----------------------------------------------------------------------------
* Panel A: biological gender	 
*-----------------------------------------------------------------------------
	qui reg w`z'_std_`var' female if Wave==`z',  vce(hc3)
	
	    * Save estimates
		local w`z'_rsqua_`i': di %6.3f e(r2)
		local w`z'_rsqua_`i' = trim("$`w`z'_rsqua_`i''$")
		beta_coeff2 female 
		local w`z'_beta_a_sex_`i' `r(beta)' 
		local w`z'_se_a_sex_`i' `r(se)'
		
		local w`z'_sign_female = sign(_b[female])

*-----------------------------------------------------------------------------	* Panel B: cgi	 
*-----------------------------------------------------------------------------	
	qui reg w`z'_std_`var' w`z'_std_cgi_main if Wave==`z', vce(hc3)

	    * Save estimates
        local w`z'_rsqub_`i': di %6.3f e(r2)
		local w`z'_rsqub_`i' = trim("$`w`z'_rsqub_`i''$")
		
		if `w`z'_sign_female'>0 {
			beta_coeff1_pos w`z'_std_cgi_main 
			local w`z'_beta_b_cgi_`i' `r(beta)'
			local w`z'_se_b_cgi_`i' `r(se)'
		}
		
		if `w`z'_sign_female'<0 {
			beta_coeff1_neg w`z'_std_cgi_main
			local w`z'_beta_b_cgi_`i' `r(beta)'
			local w`z'_se_b_cgi_`i' `r(se)'
		}
*-----------------------------------------------------------------------------	* Panel C: biological gender and cgi 
*-----------------------------------------------------------------------------
    qui reg w`z'_std_`var' w`z'_std_cgi_main female if Wave==`z', vce(hc3)	

	    ** Save estimates to be used in reg table
        local w`z'_rsquc_`i': di %6.3f e(r2)
		local w`z'_rsquc_`i' = trim("$`w`z'_rsquc_`i''$")
		
		beta_coeff2 female
		local w`z'_beta_c_sex_`i' `r(beta)'
		local w`z'_se_c_sex_`i' `r(se)'			

		if `w`z'_sign_female'>0 {
			beta_coeff1_pos w`z'_std_cgi_main
			local w`z'_beta_c_cgi_`i' `r(beta)'
			local w`z'_se_c_cgi_`i' `r(se)'
		}
		
		if `w`z'_sign_female'<0 {
			beta_coeff1_neg w`z'_std_cgi_main
			local w`z'_beta_c_cgi_`i' `r(beta)'
			local w`z'_se_c_cgi_`i' `r(se)'
		}

*-----------------------------------------------------------------------------	* Panel D: cgi for males and cgi for females
*-----------------------------------------------------------------------------				
* Panel D for females: 
preserve
use "$path/1_data/2_prepared/1_usadults_w1_w2_30_60.dta", clear
keep if female==1

* standardization at wave level
local var_to_std incentivized_risk hypothetical_risk competitiveness redistribution donation
foreach var_2 of local var_to_std {
forvalues z_2 =1/2{ 
qui su `var_2' if Wave==`z_2'
gen w`z_2'_std_`var_2'=(`var_2'-r(mean))/r(sd)
}
}

* Restandardize std_cgi_main at wave level.
forvalues z_2 =1/2{ 
qui su cgi_main if Wave==`z_2'
qui gen w`z_2'_std_cgi_main=(cgi_main-r(mean))/r(sd)
}

gen  w1_std_financial_market=financial_market // financial market risk is the only non-standardized variable. I am adding std_ at the beginning so that I can loop through all variables
gen  w2_std_financial_market=financial_market

    qui reg w`z'_std_`var' w`z'_std_cgi_main if female == 1  & Wave==`z', vce(hc3)	  
	
	    ** Save estimates to be used in reg table
		local w`z'_rsquf_`i': di %6.3f `e(r2)'
		local w`z'_rsquf_`i' = trim("$`w`z'_rsquf_`i''$")

		if `w`z'_sign_female'>0 {
			beta_coeff1_pos w`z'_std_cgi_main
			local w`z'_beta_f_cgi_`i' `r(beta)'
			local w`z'_se_f_cgi_`i' `r(se)'
			
		}
		
		if `w`z'_sign_female'<0 {
			beta_coeff1_neg w`z'_std_cgi_main
			local w`z'_beta_f_cgi_`i' `r(beta)'
			local w`z'_se_f_cgi_`i' `r(se)'
		}
		
restore

* Panel D for males: 
preserve
use "$path/1_data/2_prepared/1_usadults_w1_w2_30_60.dta", clear
keep if female==0

* standardization at wave level
local var_to_std incentivized_risk hypothetical_risk competitiveness redistribution donation
foreach var_2 of local var_to_std {
forvalues z_2 =1/2{ 
qui su `var_2' if Wave==`z_2'
gen w`z_2'_std_`var_2'=(`var_2'-r(mean))/r(sd)
}
}

* Restandardize std_cgi_main at wave level.
forvalues z_2 =1/2{ 
qui su cgi_main if Wave==`z_2'
qui gen w`z_2'_std_cgi_main=(cgi_main-r(mean))/r(sd)
}

gen  w1_std_financial_market=financial_market // financial market risk is the only non-standardized variable. I am adding std_ at the beginning so that I can loop through all variables
gen  w2_std_financial_market=financial_market
	qui reg w`z'_std_`var' w`z'_std_cgi_main if female == 0 & Wave==`z', vce(hc3)
	
	    ** Save estimates to be used in reg table
        local w`z'_rsqum_`i': di %6.3f e(r2)
		local w`z'_rsqum_`i' = trim("$`w`z'_rsqum_`i''$")
				
		if `w`z'_sign_female'>0 {
			beta_coeff1_pos w`z'_std_cgi_main
			local w`z'_beta_m_cgi_`i' `r(beta)'
			local w`z'_se_m_cgi_`i' `r(se)'
		}
		
		if `w`z'_sign_female'<0 {
			beta_coeff1_neg w`z'_std_cgi_main
			local w`z'_beta_m_cgi_`i' `r(beta)'
			local w`z'_se_m_cgi_`i' `r(se)'
		}	
restore

		qui su w`z'_std_`var' if  Wave==`z' 
        local w`z'_mean_`i': di %6.3f r(mean)
		if `w`z'_mean_`i''<0.0001 {
			local w`z'_mean_`i': di %6.0f round(r(mean))
		}
		local  w`z'_N_`i': di %11.0gc r(N)

local i=`i'+1		
}
}

*-----------------------------------------------------------------------------
*-----------------------------------------------------------------------------
* Write the Results
*-----------------------------------------------------------------------------
*-----------------------------------------------------------------------------
foreach path in out_path{

        file open resultsfile using "$`path'/USwave1wave2/`tableid'_bywaves.tex", write replace

*-----------------------------------------------------------------------------
* Write Table header
*-----------------------------------------------------------------------------
//file write resultsfile "\begin{table}[H]"
//file write resultsfile "\centering"
//file write resultsfile "\begin{adjustbox}{max width=22cm}"
//file write resultsfile "\begin{threeparttable}"
file write resultsfile "\caption{CGI and Preference Measures by U.S Waves}" 
file write resultsfile "\begin{tabular} {p{2cm} M{2.2cm} M{2.2cm} M{2.2cm} M{2.2cm} M{2.2cm} M{2.2cm} M{2.2cm} M{2.2cm} M{2.2cm} M{2.2cm} M{2.2cm} M{2.2cm} M{2.2cm}}" 
file write resultsfile "\toprule\toprule"
file write resultsfile "\addlinespace[0.2cm]"
file write resultsfile "\multicolumn{1}{l}{} & \multicolumn{2}{c}{Incentivized Risk} & \multicolumn{2}{c}{Unincentivized Risk}  & \multicolumn{2}{c}{Financial Risk} & \multicolumn{2}{c}{Competitiveness} & \multicolumn{2}{c}{Redistribution} & \multicolumn{2}{c}{Alturism}   \\"
file write resultsfile "\cmidrule(lr){2-3} \cmidrule(lr){4-5} \cmidrule(lr){6-7} \cmidrule(lr){8-9} \cmidrule(lr){10-11} \cmidrule(lr){12-13} \\"
file write resultsfile " & Wave 1 & Wave 2 & Wave 1 & Wave 2 &  Wave 1 & Wave 2 &  Wave 1 & Wave 2 &  Wave 1 & Wave 2 &  Wave 1 & Wave 2  \\"
file write resultsfile "& (1) & (2) & (3) & (4) & (5) & (6) & (7) & (8) & (9) & (10) & (11) & (12)  \\"
file write resultsfile "\midrule"
file write resultsfile" \addlinespace[0.2cm]"


*-----------------------------------------------------------------------------
* Write Panel A
*-----------------------------------------------------------------------------

file write resultsfile "\multicolumn{5}{l}{\textbf{Panel A. Binary gender}} \\" _n
file write resultsfile " \multicolumn{1}{l}{Female} & $ `w1_beta_a_sex_1'$ & $ `w2_beta_a_sex_1'$  & $`w1_beta_a_sex_2'$ & $`w2_beta_a_sex_2'$ & $`w1_beta_a_sex_3'$ & $`w2_beta_a_sex_3'$ & $`w1_beta_a_sex_4'$ & $`w2_beta_a_sex_4'$ &	$`w1_beta_a_sex_5'$ &	$`w2_beta_a_sex_5'$ & $`w1_beta_a_sex_6'$ & $`w2_beta_a_sex_6'$  \\" _n
file write resultsfile " & (`w1_se_a_sex_1') & (`w2_se_a_sex_1')	&	(`w1_se_a_sex_2') &	(`w2_se_a_sex_2')   &	(`w1_se_a_sex_3') &	(`w2_se_a_sex_3') &	(`w1_se_a_sex_4') &	(`w2_se_a_sex_4') &	(`w1_se_a_sex_5') &	(`w2_se_a_sex_5') &	(`w1_se_a_sex_6') &	(`w2_se_a_sex_6')  \\" _n
file write resultsfile "\addlinespace[0.1cm]"
file write resultsfile " \multicolumn{1}{l}{$\text{R}^2$}& `w1_rsqua_1'	& `w2_rsqua_1'  &  `w1_rsqua_2' &  `w2_rsqua_2' &	`w1_rsqua_3' &	`w2_rsqua_3' &	`w1_rsqua_4' &	`w2_rsqua_4' &	`w1_rsqua_5' &	`w2_rsqua_5' &	`w1_rsqua_6'  &	`w2_rsqua_6'\\ \\" _n
file write resultsfile "\addlinespace[-0.3cm]"
file write resultsfile "\midrule"

*-----------------------------------------------------------------------------
* Write Panel B
*-----------------------------------------------------------------------------
file write resultsfile "\multicolumn{5}{l}{\textbf{Panel B. Gender identity}} \\" _n
file write resultsfile " \multicolumn{1}{l}{CGI (feminine)} & $ `w1_beta_b_cgi_1'$ & $ `w2_beta_b_cgi_1'$  & $`w1_beta_b_cgi_2'$ & $`w2_beta_b_cgi_2'$ & $`w1_beta_b_cgi_3'$ & $`w2_beta_b_cgi_3'$ & $`w1_beta_b_cgi_4'$ & $`w2_beta_b_cgi_4'$ &	$`w1_beta_b_cgi_5'$ &	$`w2_beta_b_cgi_5'$ & \phantom{$`w1_beta_b_cgi_6'$} & \phantom{$`w2_beta_b_cgi_6'$}  \\" _n
file write resultsfile " & (`w1_se_b_cgi_1') & (`w2_se_b_cgi_1')	&	(`w1_se_b_cgi_2') &	(`w2_se_b_cgi_2')   &	(`w1_se_b_cgi_3') &	(`w2_se_b_cgi_3') &	(`w1_se_b_cgi_4') &	(`w2_se_b_cgi_4') &	(`w1_se_b_cgi_5') &	(`w2_se_b_cgi_5') &	\phantom{(`w1_se_b_cgi_6')} &	\phantom{(`w2_se_b_cgi_6')}  \\" _n
file write resultsfile "\addlinespace[0.1cm]"
file write resultsfile " \multicolumn{1}{l}{$\text{R}^2$}	& `w1_rsqub_1'	& `w2_rsqub_1'  &  `w1_rsqub_2' &  `w2_rsqub_2' &	`w1_rsqub_3' &	`w2_rsqub_3' &	`w1_rsqub_4' &	`w2_rsqub_4' &	`w1_rsqub_5' &	`w2_rsqub_5' &	\phantom{`w1_rsqub_6'}  &	\phantom{`w2_rsqub_6'} \\ \\" _n
file write resultsfile "\addlinespace[-0.3cm]"
file write resultsfile "\midrule"

*-----------------------------------------------------------------------------
* Write Panel C
*-----------------------------------------------------------------------------
file write resultsfile "\multicolumn{5}{l}{\textbf{Panel C. Binary gender and gender identity}} \\" _n
file write resultsfile " \multicolumn{1}{l}{Female} & $`w1_beta_c_sex_1'$  & $`w2_beta_c_sex_1'$ &	$`w1_beta_c_sex_2'$	& $`w2_beta_c_sex_2'$ & $`w1_beta_c_sex_3'$ & $`w2_beta_c_sex_3'$ 	&	$`w1_beta_c_sex_4'$ & $`w2_beta_c_sex_4'$ &	$`w1_beta_c_sex_5' &	$`w2_beta_c_sex_5' $ &	\phantom{$`w1_beta_c_sex_6'$} &	\phantom{$`w2_beta_c_sex_6'$} \\" _n
file write resultsfile " & (`w1_se_c_sex_1') & (`w2_se_c_sex_1') &	(`w1_se_c_sex_2') &	(`w2_se_c_sex_2')	& (`w1_se_c_sex_3') & (`w2_se_c_sex_3')  &	(`w1_se_c_sex_4') &	(`w2_se_c_sex_4') &	(`w1_se_c_sex_5') &	(`w2_se_c_sex_5') &	\phantom{(`w1_se_c_sex_6')} &	\phantom{(`w2_se_c_sex_6')}  \\ \\" _n
file write resultsfile "\addlinespace[-0.3cm]"
file write resultsfile " \multicolumn{1}{l}{CGI (feminine)} & $`w1_beta_c_cgi_1'$ & $`w2_beta_c_cgi_1'$ & $`w1_beta_c_cgi_2'$ & $`w2_beta_c_cgi_2'$ & $`w1_beta_c_cgi_3'$ & $`w2_beta_c_cgi_3'$ & $`w1_beta_c_cgi_4'$ & $`w2_beta_c_cgi_4'$ & $`w1_beta_c_cgi_5'$ & $`w2_beta_c_cgi_5'$ &	\phantom{$`w1_beta_c_cgi_6'$} &	\phantom{$`w2_beta_c_cgi_6'$} \\" _n
file write resultsfile " & (`w1_se_c_cgi_1')	& (`w2_se_c_cgi_1')  &	(`w1_se_c_cgi_2')  &	(`w2_se_c_cgi_2')  &	(`w1_se_c_cgi_3') &	(`w2_se_c_cgi_3')	&	(`w1_se_c_cgi_4') &	(`w2_se_c_cgi_4') &	(`w1_se_c_cgi_5') &	(`w2_se_c_cgi_5') & \phantom{(`w1_se_c_cgi_6')} & \phantom{(`w2_se_c_cgi_6')}   \\" _n
file write resultsfile "\addlinespace[0.1cm]"
file write resultsfile " \multicolumn{1}{l}{$\text{R}^2$}	& `w1_rsquc_1' & `w2_rsquc_1' & `w1_rsquc_2' & `w2_rsquc_2' &	`w1_rsquc_3' &	`w2_rsquc_3' & `w1_rsquc_4' & `w2_rsquc_4' &	`w1_rsquc_5' &	`w2_rsquc_5' &	\phantom{`w1_rsquc_6'} &	\phantom{`w2_rsquc_6'}  \\ \\" _n		
file write resultsfile "\addlinespace[-0.3cm]"
file write resultsfile "\midrule"

*-----------------------------------------------------------------------------
* Write Panel D
*-----------------------------------------------------------------------------
file write resultsfile "\multicolumn{5}{l}{\textbf{Panel D. Sample split by binary gender}} \\" _n
file write resultsfile "  \multicolumn{1}{l}{Female: CGI (feminine)}  & $`w1_beta_f_cgi_1'$  & $`w2_beta_f_cgi_1'$ &	$`w1_beta_f_cgi_2'$ &	$`w2_beta_f_cgi_2'$ &	$`w1_beta_f_cgi_3'$ &	$`w2_beta_f_cgi_3'$ &	$`w1_beta_f_cgi_4'$ &	$`w2_beta_f_cgi_4'$ &	$`w1_beta_f_cgi_5'$ &	$`w2_beta_f_cgi_5'$ &	\phantom{$`w1_beta_f_cgi_6'$}  &	\phantom{$`w2_beta_f_cgi_6'$} \\" _n
file write resultsfile "  & (`w1_se_f_cgi_1') & (`w2_se_f_cgi_1')  &	(`w1_se_f_cgi_2')  &	(`w2_se_f_cgi_2') & 	(`w1_se_f_cgi_3') & 	(`w2_se_f_cgi_3')	&	(`w1_se_f_cgi_4') &	(`w2_se_f_cgi_4') &	(`w1_se_f_cgi_5')  &	(`w2_se_f_cgi_5') &  \phantom{(`w1_se_f_cgi_6')}  &  \phantom{(`w2_se_f_cgi_6')} \\" _n	
file write resultsfile "\addlinespace[0.1cm]"
file write resultsfile " \multicolumn{1}{l}{$\text{R}^2$}	& `w1_rsquf_1' & `w2_rsquf_1'	&	`w1_rsquf_2' &	`w2_rsquf_2'   &	`w1_rsquf_3' &	`w2_rsquf_3' &	`w1_rsquf_4' &	`w2_rsquf_4' &	`w1_rsquf_5' &	`w2_rsquf_5' &	\phantom{`w1_rsquf_6'} &	\phantom{`w2_rsquf_6'} \\ \\" _n
file write resultsfile "\addlinespace[-0.3cm]"	

file write resultsfile " \multicolumn{1}{l}{Male: CGI (feminine)} & $`w1_beta_m_cgi_1'$ & $`w2_beta_m_cgi_1'$  &	$`w1_beta_m_cgi_2'$ &	$`w2_beta_m_cgi_2'$ &	$`w1_beta_m_cgi_3'$ &	$`w2_beta_m_cgi_3'$ &	$`w1_beta_m_cgi_4'$  &	$`w2_beta_m_cgi_4'$ &	$`w1_beta_m_cgi_5'$ & 	$`w2_beta_m_cgi_5'$ & \phantom{$`w1_beta_m_cgi_6'$}  & \phantom{$`w2_beta_m_cgi_6'$} \\" _n
file write resultsfile " & (`w1_se_m_cgi_1')  & (`w2_se_m_cgi_1') &	(`w1_se_m_cgi_2') &	(`w2_se_m_cgi_2') &	(`w1_se_m_cgi_3') &	(`w2_se_m_cgi_3') &	(`w1_se_m_cgi_4') &	(`w2_se_m_cgi_4') &	(`w1_se_m_cgi_5') &	(`w2_se_m_cgi_5') & \phantom{(`w1_se_m_cgi_6')} & \phantom{(`w2_se_m_cgi_6')} \\" _n
file write resultsfile "\addlinespace[0.1cm]"
file write resultsfile " \multicolumn{1}{l}{$\text{R}^2$}	& `w1_rsqum_1' & `w2_rsqum_1'	 & `w1_rsqum_2' & `w2_rsqum_2'   &	`w1_rsqum_3' &	`w2_rsqum_3' &	`w1_rsqum_4' &	`w2_rsqum_4' &	`w1_rsqum_5' &	`w2_rsqum_5' &	\phantom{`w1_rsqum_6'}  &	\phantom{`w2_rsqum_6'} \\ \\" _n	
file write resultsfile "\addlinespace[-0.3cm]"
file write resultsfile "\midrule"

*-----------------------------------------------------------------------------
* Write Obs number row
*-----------------------------------------------------------------------------
file write resultsfile " \multicolumn{1}{l}{Observations} & `w1_N_1' & `w2_N_1' & `w1_N_2' & `w2_N_2' & `w1_N_3' & `w2_N_3' & `w1_N_4' & `w2_N_4' & `w1_N_5' & `w2_N_5' & `w1_N_6' & `w2_N_6'  \\ \\" _n
file write resultsfile "\addlinespace[-0.3cm]"

*-----------------------------------------------------------------------------
* Write mean of dependent variable
*-----------------------------------------------------------------------------
* get rid of the mean decimals for the standardized variables
		
file write resultsfile "\multicolumn{1}{l}{Mean of Dependent Variable}  & `w1_mean_1' & `w2_mean_1' & `w1_mean_2' & `w2_mean_2' & `w1_mean_3' & `w2_mean_3' & `w1_mean_4' & `w2_mean_4' & `w1_mean_5' & `w2_mean_5' & `w1_mean_6'  & `w2_mean_6'   \\ \\" _n
file write resultsfile "\addlinespace[-0.3cm]"

*-----------------------------------------------------------------------------
* Write Table footer
*-----------------------------------------------------------------------------
file write resultsfile "\bottomrule\bottomrule"
file write resultsfile "\end{tabular}"
//file write resultsfile "\begin{tablenotes}"
//file write resultsfile "\item  \textit{Notes.} "
//file write resultsfile "\end{tablenotes}"
//file write resultsfile "\end{threeparttable}"
//file write resultsfile "\end{adjustbox}"
//file write resultsfile "\end{table}"
file close resultsfile
}


