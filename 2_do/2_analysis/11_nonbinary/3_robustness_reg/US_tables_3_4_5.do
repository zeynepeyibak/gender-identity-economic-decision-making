clear all

global out_path "$path/3_out" 
		
local tableid "US_tables_3_4_5"

* short code to save reg coeffs
do "$path/2_do/2_analysis/0_reg_fnc/0_regressions.do" // 2 tailed 
do "$path/2_do/2_analysis/0_reg_fnc/0_regressions_1t_+.do" // 1 tailed if sign_female>0
do "$path/2_do/2_analysis/0_reg_fnc/0_regressions_1t_-.do" // 1 tailed if sign_female<0

* binary only
use "$path/1_data/2_prepared/1_usadults_w2_30_60.dta", clear

local var_to_std incentivized_risk hypothetical_risk competitiveness redistribution donation
foreach var of local var_to_std {
qui su `var' 
gen b_std_`var'=(`var'-r(mean))/r(sd)
}

drop std_cgi_main
qui su cgi_main 
qui gen b_std_cgi_main=(cgi_main-r(mean))/r(sd)

gen  b_std_financial_market=financial_market // financial market risk is the only non-standardized variable. I am adding std_ at the beginning so that I can loop through all variables

keep b_* female 
gen data="b"

tempfile binary
save `binary'

* nonbinary
use "$path/2_do/2_analysis/11_nonbinary/1_usadults_w2_30_60.dta", clear
local var_to_std incentivized_risk hypothetical_risk competitiveness redistribution donation
foreach var of local var_to_std {
qui su `var' 
gen nb_std_`var'=(`var'-r(mean))/r(sd)
}

drop std_cgi_main
qui su cgi_main 
qui gen nb_std_cgi_main=(cgi_main-r(mean))/r(sd)

gen  nb_std_financial_market=financial_market // financial market risk is the only non-standardized variable. I am adding std_ at the beginning so that I can loop through all variables

keep nb_* female 
gen data="nb"

append using `binary'


foreach z in "b" "nb" { 
local variables incentivized_risk hypothetical_risk financial_market competitiveness redistribution donation
local i=1

foreach var of local variables {	
*-----------------------------------------------------------------------------
* Panel A: biological gender	 
*-----------------------------------------------------------------------------
	qui reg `z'_std_`var' female ,  vce(hc3)

	    * Save estimates
		local `z'_rsqua_`i': di %6.3f e(r2)
		local `z'_rsqua_`i' = trim("$``z'_rsqua_`i''$")
		beta_coeff2 female 
		local `z'_beta_a_sex_`i' `r(beta)' 
		local `z'_se_a_sex_`i' `r(se)'
		
		local `z'_sign_female = sign(_b[female])

*-----------------------------------------------------------------------------	* Panel B: cgi	 
*-----------------------------------------------------------------------------	
	qui reg `z'_std_`var' `z'_std_cgi_main, vce(hc3)

	    * Save estimates
        local `z'_rsqub_`i': di %6.3f e(r2)
		local `z'_rsqub_`i' = trim("$``z'_rsqub_`i''$")
		
		if ``z'_sign_female'>0 {
			beta_coeff1_pos `z'_std_cgi_main 
			local `z'_beta_b_cgi_`i' `r(beta)'
			local `z'_se_b_cgi_`i' `r(se)'
		}
		
		if ``z'_sign_female'<0 {
			beta_coeff1_neg `z'_std_cgi_main
			local `z'_beta_b_cgi_`i' `r(beta)'
			local `z'_se_b_cgi_`i' `r(se)'
		}
*-----------------------------------------------------------------------------	* Panel C: biological gender and cgi 
*-----------------------------------------------------------------------------
    qui reg `z'_std_`var' `z'_std_cgi_main female, vce(hc3)	

	    ** Save estimates to be used in reg table
        local `z'_rsquc_`i': di %6.3f e(r2)
		local `z'_rsquc_`i' = trim("$``z'_rsquc_`i''$")
		
		beta_coeff2 female
		local `z'_beta_c_sex_`i' `r(beta)'
		local `z'_se_c_sex_`i' `r(se)'			

		if ``z'_sign_female'>0 {
			beta_coeff1_pos `z'_std_cgi_main
			local `z'_beta_c_cgi_`i' `r(beta)'
			local `z'_se_c_cgi_`i' `r(se)'
		}
		
		if ``z'_sign_female'<0 {
			beta_coeff1_neg `z'_std_cgi_main
			local `z'_beta_c_cgi_`i' `r(beta)'
			local `z'_se_c_cgi_`i' `r(se)'
		}

*-----------------------------------------------------------------------------	* Panel D: cgi for males and cgi for females
*-----------------------------------------------------------------------------				
* Panel D for females: 
preserve

* binary only
use "$path/1_data/2_prepared/1_usadults_w2_30_60.dta", clear
keep if female==1
local var_to_std incentivized_risk hypothetical_risk competitiveness redistribution donation
foreach v of local var_to_std {
qui su `v' 
gen b_std_`v'=(`var'-r(mean))/r(sd)
}

drop std_cgi_main
qui su cgi_main 
qui gen b_std_cgi_main=(cgi_main-r(mean))/r(sd)

gen  b_std_financial_market=financial_market // financial market risk is the only non-standardized variable. I am adding std_ at the beginning so that I can loop through all variables

keep b_* female 
gen data="b"

tempfile binary
save `binary'

* nonbinary
use "$path/2_do/2_analysis/11_nonbinary/1_usadults_w2_30_60.dta", clear
keep if female==1
local var_to_std incentivized_risk hypothetical_risk competitiveness redistribution donation
foreach v of local var_to_std {
qui su `v' 
gen nb_std_`v'=(`var'-r(mean))/r(sd)
}

drop std_cgi_main
qui su cgi_main 
qui gen nb_std_cgi_main=(cgi_main-r(mean))/r(sd)

gen  nb_std_financial_market=financial_market // financial market risk is the only non-standardized variable. I am adding std_ at the beginning so that I can loop through all variables

keep nb_* female 
gen data="nb"

append using `binary'



    qui reg `z'_std_`var' `z'_std_cgi_main if female == 1, vce(hc3)	  
	
	    ** Save estimates to be used in reg table
		local `z'_rsquf_`i': di %6.3f `e(r2)'
		local `z'_rsquf_`i' = trim("$``z'_rsquf_`i''$")

		if ``z'_sign_female'>0 {
			beta_coeff1_pos `z'_std_cgi_main
			local `z'_beta_f_cgi_`i' `r(beta)'
			local `z'_se_f_cgi_`i' `r(se)'	
		}
		
		if ``z'_sign_female'<0 {
			beta_coeff1_neg `z'_std_cgi_main
			local `z'_beta_f_cgi_`i' `r(beta)'
			local `z'_se_f_cgi_`i' `r(se)'
		}
		
restore

* Panel D for males: 
preserve

* binary only
use "$path/1_data/2_prepared/1_usadults_w2_30_60.dta", clear

keep if female==0
local var_to_std incentivized_risk hypothetical_risk competitiveness redistribution donation
foreach v of local var_to_std {
qui su `v' 
gen b_std_`v'=(`var'-r(mean))/r(sd)
}

drop std_cgi_main
qui su cgi_main 
qui gen b_std_cgi_main=(cgi_main-r(mean))/r(sd)

gen  b_std_financial_market=financial_market // financial market risk is the only non-standardized variable. I am adding std_ at the beginning so that I can loop through all variables

keep b_* female 
gen data="b"

tempfile binary
save `binary'

* nonbinary
use "$path/2_do/2_analysis/11_nonbinary/1_usadults_w2_30_60.dta", clear
keep if female==0
local v_to_std incentivized_risk hypothetical_risk competitiveness redistribution donation
foreach v of local var_to_std {
qui su `v' 
gen nb_std_`v'=(`var'-r(mean))/r(sd)
}

drop std_cgi_main
qui su cgi_main 
qui gen nb_std_cgi_main=(cgi_main-r(mean))/r(sd)

gen  nb_std_financial_market=financial_market // financial market risk is the only non-standardized variable. I am adding std_ at the beginning so that I can loop through all variables

keep nb_* female 
gen data="nb"

append using `binary'
	qui reg `z'_std_`var' `z'_std_cgi_main if female == 0, vce(hc3)
	
	    ** Save estimates to be used in reg table
        local `z'_rsqum_`i': di %6.3f e(r2)
		local `z'_rsqum_`i' = trim("$``z'_rsqum_`i''$")
				
		if ``z'_sign_female'>0 {
			beta_coeff1_pos `z'_std_cgi_main
			local `z'_beta_m_cgi_`i' `r(beta)'
			local `z'_se_m_cgi_`i' `r(se)'
		}
		
		if ``z'_sign_female'<0 {
			beta_coeff1_neg `z'_std_cgi_main
			local `z'_beta_m_cgi_`i' `r(beta)'
			local `z'_se_m_cgi_`i' `r(se)'
		}	
restore

		qui su `z'_std_`var' 
        local `z'_mean_`i': di %6.3f r(mean)
		if ``z'_mean_`i''<0.0001 {
			local `z'_mean_`i': di %6.0f round(r(mean))
		}
		local  `z'_N_`i': di %11.0gc r(N)

local i=`i'+1		
}
}

*-----------------------------------------------------------------------------
*-----------------------------------------------------------------------------
* Write the Results
*-----------------------------------------------------------------------------
*-----------------------------------------------------------------------------
foreach path in out_path{

        file open resultsfile using "$`path'/NonBinary/`tableid'_nb_b.tex", write replace

*-----------------------------------------------------------------------------
* Write Table header
*-----------------------------------------------------------------------------
//file write resultsfile "\begin{table}[H]"
//file write resultsfile "\centering"
//file write resultsfile "\begin{adjustbox}{max width=22cm}"
//file write resultsfile "\begin{threeparttable}"
file write resultsfile "\caption{CGI and U.S. Adults Preference Measures with and without Non-binary Participants}" 
file write resultsfile "\begin{tabular} {p{2cm} M{2.3cm} M{2.3cm} M{2.3cm} M{2.3cm} M{2.3cm} M{2.3cm} M{2.3cm} M{2.3cm} M{2.3cm} M{2.3cm} M{2.3cm} M{2.3cm} M{2.3cm}}" 
file write resultsfile "\toprule\toprule"
file write resultsfile "\addlinespace[0.2cm]"
file write resultsfile "\multicolumn{1}{l}{} & \multicolumn{2}{c}{Incentivized Risk} & \multicolumn{2}{c}{Unincentivized Risk}  & \multicolumn{2}{c}{Financial Risk} & \multicolumn{2}{c}{Competitiveness} & \multicolumn{2}{c}{Redistribution} & \multicolumn{2}{c}{Alturism}   \\"
file write resultsfile "\cmidrule(lr){2-3} \cmidrule(lr){4-5} \cmidrule(lr){6-7} \cmidrule(lr){8-9} \cmidrule(lr){10-11} \cmidrule(lr){12-13} \\"
file write resultsfile " & exclude nonbinary & include nonbinary & exclude nonbinary & include nonbinary   & exclude nonbinary & include nonbinary  & exclude nonbinary & include nonbinary   & exclude nonbinary & include nonbinary   & exclude nonbinary & include nonbinary   \\"
file write resultsfile "& (1) & (2) & (3) & (4) & (5) & (6) & (7) & (8) & (9) & (10) & (11) & (12)  \\"
file write resultsfile "\midrule"
file write resultsfile" \addlinespace[0.2cm]"


*-----------------------------------------------------------------------------
* Write Panel A
*-----------------------------------------------------------------------------

file write resultsfile "\multicolumn{5}{l}{\textbf{Panel A. Binary gender}} \\" _n
file write resultsfile " \multicolumn{1}{l}{Female} & $ `b_beta_a_sex_1'$ & $ `nb_beta_a_sex_1'$  & $`b_beta_a_sex_2'$ & $`nb_beta_a_sex_2'$ & $`b_beta_a_sex_3'$ & $`nb_beta_a_sex_3'$ & $`b_beta_a_sex_4'$ & $`nb_beta_a_sex_4'$ &	$`b_beta_a_sex_5'$ &	$`nb_beta_a_sex_5'$ & $`b_beta_a_sex_6'$ & $`nb_beta_a_sex_6'$  \\" _n
file write resultsfile " & (`b_se_a_sex_1') & (`nb_se_a_sex_1')	&	(`b_se_a_sex_2') &	(`nb_se_a_sex_2')   &	(`b_se_a_sex_3') &	(`nb_se_a_sex_3') &	(`b_se_a_sex_4') &	(`nb_se_a_sex_4') &	(`b_se_a_sex_5') &	(`nb_se_a_sex_5') &	(`b_se_a_sex_6') &	(`nb_se_a_sex_6')  \\" _n
file write resultsfile "\addlinespace[0.1cm]"
file write resultsfile " \multicolumn{1}{l}{$\text{R}^2$}& `b_rsqua_1'	& `nb_rsqua_1'  &  `b_rsqua_2' &  `nb_rsqua_2' &	`b_rsqua_3' &	`nb_rsqua_3' &	`b_rsqua_4' &	`nb_rsqua_4' &	`b_rsqua_5' &	`nb_rsqua_5' &	`b_rsqua_6'  &	`nb_rsqua_6'\\ \\" _n
file write resultsfile "\addlinespace[-0.3cm]"
file write resultsfile "\midrule"

*-----------------------------------------------------------------------------
* Write Panel B
*-----------------------------------------------------------------------------
file write resultsfile "\multicolumn{5}{l}{\textbf{Panel B. Gender identity}} \\" _n
file write resultsfile " \multicolumn{1}{l}{CGI (feminine)} & $ `b_beta_b_cgi_1'$ & $ `nb_beta_b_cgi_1'$  & $`b_beta_b_cgi_2'$ & $`nb_beta_b_cgi_2'$ & $`b_beta_b_cgi_3'$ & $`nb_beta_b_cgi_3'$ & $`b_beta_b_cgi_4'$ & $`nb_beta_b_cgi_4'$ &	$`b_beta_b_cgi_5'$ &	$`nb_beta_b_cgi_5'$ & \phantom{$`b_beta_b_cgi_6'$} & \phantom{$`nb_beta_b_cgi_6'$}  \\" _n
file write resultsfile " & (`b_se_b_cgi_1') & (`nb_se_b_cgi_1')	&	(`b_se_b_cgi_2') &	(`nb_se_b_cgi_2')   &	(`b_se_b_cgi_3') &	(`nb_se_b_cgi_3') &	(`b_se_b_cgi_4') &	(`nb_se_b_cgi_4') &	(`b_se_b_cgi_5') &	(`nb_se_b_cgi_5') &	\phantom{(`b_se_b_cgi_6')} &	\phantom{(`nb_se_b_cgi_6')}  \\" _n
file write resultsfile "\addlinespace[0.1cm]"
file write resultsfile " \multicolumn{1}{l}{$\text{R}^2$}	& `b_rsqub_1'	& `nb_rsqub_1'  &  `b_rsqub_2' &  `nb_rsqub_2' &	`b_rsqub_3' &	`nb_rsqub_3' &	`b_rsqub_4' &	`nb_rsqub_4' &	`b_rsqub_5' &	`nb_rsqub_5' &	\phantom{`b_rsqub_6'}  &	\phantom{`nb_rsqub_6'} \\ \\" _n
file write resultsfile "\addlinespace[-0.3cm]"
file write resultsfile "\midrule"

*-----------------------------------------------------------------------------
* Write Panel C
*-----------------------------------------------------------------------------
file write resultsfile "\multicolumn{5}{l}{\textbf{Panel C. Binary gender and gender identity}} \\" _n
file write resultsfile " \multicolumn{1}{l}{Female} & $`b_beta_c_sex_1'$  & $`nb_beta_c_sex_1'$ &	$`b_beta_c_sex_2'$	& $`nb_beta_c_sex_2'$ & $`b_beta_c_sex_3'$ & $`nb_beta_c_sex_3'$ 	&	$`b_beta_c_sex_4'$ & $`nb_beta_c_sex_4'$ &	$`b_beta_c_sex_5' &	$`nb_beta_c_sex_5' $ &	\phantom{$`b_beta_c_sex_6'$} &	\phantom{$`nb_beta_c_sex_6'$} \\" _n
file write resultsfile " & (`b_se_c_sex_1') & (`nb_se_c_sex_1') &	(`b_se_c_sex_2') &	(`nb_se_c_sex_2')	& (`b_se_c_sex_3') & (`nb_se_c_sex_3')  &	(`b_se_c_sex_4') &	(`nb_se_c_sex_4') &	(`b_se_c_sex_5') &	(`nb_se_c_sex_5') &	\phantom{(`b_se_c_sex_6')} &	\phantom{(`nb_se_c_sex_6')}  \\ \\" _n
file write resultsfile "\addlinespace[-0.3cm]"
file write resultsfile " \multicolumn{1}{l}{CGI (feminine)} & $`b_beta_c_cgi_1'$ & $`nb_beta_c_cgi_1'$ & $`b_beta_c_cgi_2'$ & $`nb_beta_c_cgi_2'$ & $`b_beta_c_cgi_3'$ & $`nb_beta_c_cgi_3'$ & $`b_beta_c_cgi_4'$ & $`nb_beta_c_cgi_4'$ & $`b_beta_c_cgi_5'$ & $`nb_beta_c_cgi_5'$ &	\phantom{$`b_beta_c_cgi_6'$} &	\phantom{$`nb_beta_c_cgi_6'$} \\" _n
file write resultsfile " & (`b_se_c_cgi_1')	& (`nb_se_c_cgi_1')  &	(`b_se_c_cgi_2')  &	(`nb_se_c_cgi_2')  &	(`b_se_c_cgi_3') &	(`nb_se_c_cgi_3')	&	(`b_se_c_cgi_4') &	(`nb_se_c_cgi_4') &	(`b_se_c_cgi_5') &	(`nb_se_c_cgi_5') & \phantom{(`b_se_c_cgi_6')} & \phantom{(`nb_se_c_cgi_6')}   \\" _n
file write resultsfile "\addlinespace[0.1cm]"
file write resultsfile " \multicolumn{1}{l}{$\text{R}^2$}	& `b_rsquc_1' & `nb_rsquc_1' & `b_rsquc_2' & `nb_rsquc_2' &	`b_rsquc_3' &	`nb_rsquc_3' & `b_rsquc_4' & `nb_rsquc_4' &	`b_rsquc_5' &	`nb_rsquc_5' &	\phantom{`b_rsquc_6'} &	\phantom{`nb_rsquc_6'}  \\ \\" _n		
file write resultsfile "\addlinespace[-0.3cm]"
file write resultsfile "\midrule"

*-----------------------------------------------------------------------------
* Write Panel D
*-----------------------------------------------------------------------------
file write resultsfile "\multicolumn{5}{l}{\textbf{Panel D. Sample split by binary gender}} \\" _n
file write resultsfile "  \multicolumn{1}{l}{Female: CGI (feminine)}  & $`b_beta_f_cgi_1'$  & $`nb_beta_f_cgi_1'$ &	$`b_beta_f_cgi_2'$ &	$`nb_beta_f_cgi_2'$ &	$`b_beta_f_cgi_3'$ &	$`nb_beta_f_cgi_3'$ &	$`b_beta_f_cgi_4'$ &	$`nb_beta_f_cgi_4'$ &	$`b_beta_f_cgi_5'$ &	$`nb_beta_f_cgi_5'$ &	\phantom{$`b_beta_f_cgi_6'$}  &	\phantom{$`nb_beta_f_cgi_6'$} \\" _n
file write resultsfile "  & (`b_se_f_cgi_1') & (`nb_se_f_cgi_1')  &	(`b_se_f_cgi_2')  &	(`nb_se_f_cgi_2') & 	(`b_se_f_cgi_3') & 	(`nb_se_f_cgi_3')	&	(`b_se_f_cgi_4') &	(`nb_se_f_cgi_4') &	(`b_se_f_cgi_5')  &	(`nb_se_f_cgi_5') &  \phantom{(`b_se_f_cgi_6')}  &  \phantom{(`nb_se_f_cgi_6')} \\" _n	
file write resultsfile "\addlinespace[0.1cm]"
file write resultsfile " \multicolumn{1}{l}{$\text{R}^2$}	& `b_rsquf_1' & `nb_rsquf_1'	&	`b_rsquf_2' &	`nb_rsquf_2'   &	`b_rsquf_3' &	`nb_rsquf_3' &	`b_rsquf_4' &	`nb_rsquf_4' &	`b_rsquf_5' &	`nb_rsquf_5' &	\phantom{`b_rsquf_6'} &	\phantom{`nb_rsquf_6'} \\ \\" _n
file write resultsfile "\addlinespace[-0.3cm]"	

file write resultsfile " \multicolumn{1}{l}{Male: CGI (feminine)} & $`b_beta_m_cgi_1'$ & $`nb_beta_m_cgi_1'$  &	$`b_beta_m_cgi_2'$ &	$`nb_beta_m_cgi_2'$ &	$`b_beta_m_cgi_3'$ &	$`nb_beta_m_cgi_3'$ &	$`b_beta_m_cgi_4'$  &	$`nb_beta_m_cgi_4'$ &	$`b_beta_m_cgi_5'$ & 	$`nb_beta_m_cgi_5'$ & \phantom{$`b_beta_m_cgi_6'$}  & \phantom{$`nb_beta_m_cgi_6'$} \\" _n
file write resultsfile " & (`b_se_m_cgi_1')  & (`nb_se_m_cgi_1') &	(`b_se_m_cgi_2') &	(`nb_se_m_cgi_2') &	(`b_se_m_cgi_3') &	(`nb_se_m_cgi_3') &	(`b_se_m_cgi_4') &	(`nb_se_m_cgi_4') &	(`b_se_m_cgi_5') &	(`nb_se_m_cgi_5') & \phantom{(`b_se_m_cgi_6')} & \phantom{(`nb_se_m_cgi_6')} \\" _n
file write resultsfile "\addlinespace[0.1cm]"
file write resultsfile " \multicolumn{1}{l}{$\text{R}^2$}	& `b_rsqum_1' & `nb_rsqum_1'	 & `b_rsqum_2' & `nb_rsqum_2'   &	`b_rsqum_3' &	`nb_rsqum_3' &	`b_rsqum_4' &	`nb_rsqum_4' &	`b_rsqum_5' &	`nb_rsqum_5' &	\phantom{`b_rsqum_6'}  &	\phantom{`nb_rsqum_6'} \\ \\" _n	
file write resultsfile "\addlinespace[-0.3cm]"
file write resultsfile "\midrule"

*-----------------------------------------------------------------------------
* Write Obs number row
*-----------------------------------------------------------------------------
file write resultsfile " \multicolumn{1}{l}{Observations} & `b_N_1' & `nb_N_1' & `b_N_2' & `nb_N_2' & `b_N_3' & `nb_N_3' & `b_N_4' & `nb_N_4' & `b_N_5' & `nb_N_5' & `b_N_6' & `nb_N_6'  \\ \\" _n
file write resultsfile "\addlinespace[-0.3cm]"

*-----------------------------------------------------------------------------
* Write mean of dependent variable
*-----------------------------------------------------------------------------
* get rid of the mean decimals for the standardized variables
		
file write resultsfile "\multicolumn{1}{l}{Mean of Dependent Variable}  & `b_mean_1' & `nb_mean_1' & `b_mean_2' & `nb_mean_2' & `b_mean_3' & `nb_mean_3' & `b_mean_4' & `nb_mean_4' & `b_mean_5' & `nb_mean_5' & `b_mean_6'  & `nb_mean_6'   \\ \\" _n
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


