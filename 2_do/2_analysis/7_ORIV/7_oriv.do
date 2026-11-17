clear all

global out_path "$path/3_out" 
		
grstyle init
grstyle set plain, horizontal grid

* short code to save reg coeffs
do "$path/2_do/2_analysis/0_reg_fnc/0_regressions.do" // 2 tailed 
do "$path/2_do/2_analysis/0_reg_fnc/0_CHI_regressions_1t_+.do" // 1 tailed if sign_female>0
do "$path/2_do/2_analysis/0_reg_fnc/0_CHI_regressions_1t_-.do" // 1 tailed if sign_female<0


*-----------------------------------------------------------------------------
* Bin scatter plot
*-----------------------------------------------------------------------------

use "$path/1_data/2_prepared/1_SwissUni.dta", clear

* Compute the corr
corr std_cgi_main_fo std_cgi_main
local corr_1 : di %9.3fc r(C)[1,2]
di `corr_1'


* Scatter plot with frequency weights
scatter std_cgi_main_fo std_cgi_main ||  lfit std_cgi_main_fo std_cgi_main,  legend(off)  note("Correlation: `corr_1'", size(medsmall))

foreach path in out_path {
 graph export "$`path'/oriv/scatter_SwissUni.jpg", replace
}	

* Scatter plot with frequency weights
bys std_cgi_main std_cgi_main_fo: gen weight_=_N
scatter std_cgi_main_fo std_cgi_main [fw = weight], msymbol(circle_hollow) ||  lfit std_cgi_main_fo std_cgi_main,  legend(off)  note("Correlation: `corr_1'", size(medsmall))

foreach path in out_path {
 graph export "$`path'/oriv/weightedscatter_SwissUni.jpg", replace
}	

graph close

* binscatter
binscatter std_cgi_main_fo std_cgi_main, line(qfit) discrete  ///
  ylabel(, nogrid) legend(off) ///		       
  xtitle("CGI") ///
  ytitle("Second CGI") mcolor(gs6) lcolor(gs8)  note("Correlation: `corr_1'", size(medium))

 
foreach path in out_path {
 graph export "$`path'/oriv/binscatter_SwissUni.jpg", replace
}	
graph close

use "$path/1_data/2_prepared/1_swissteens.dta", clear

* Standardize first and second march survey cgi
qui su cgi_1_dec //main
gen std_cgi_1_dec=(cgi_1_dec-r(mean))/r(sd)

qui su cgi_2_dec
gen std_cgi_2_dec=(cgi_2_dec-r(mean))/r(sd)

binscatter std_cgi_2_dec std_cgi_1_dec, line(qfit) ///
  ylabel(, nogrid) legend(off) ///		       
  xtitle("Single item CGI", size(medsmall)) ///
  ytitle("Second Single item CGI", size(medsmall)) lcolor(gs8) ///
  
  
foreach path in out_path {
 graph export "$`path'/oriv/binscatter_SwissTeens.jpg", replace
}	
graph close
*-----------------------------------------------------------------------------
* IVreg 
*-----------------------------------------------------------------------------
use "$path/1_data/2_prepared/1_SwissUni.dta", clear
 
local variables std_incentivized_risk incentivized_competitiveness rho std_staircase_risk std_hyp_risk std_competitiveness  std_redistribution std_donation 
	

local i=1

local z=1 // only no controls version

*-----------------------------------------------------------------------------
* Sanity checks with standardizations before we start the regression analysis
*-----------------------------------------------------------------------------

* Outcome variables
	qui su std_incentivized_risk
	assert round(r(mean),0.0001)==0

	qui su std_staircase_risk
	assert round(r(mean),0.0001)==0
	
	qui su std_hyp_risk 
	assert round(r(mean),0.0001)==0	
	
	qui su std_competitiveness
	assert round(r(mean),0.0001)==0	
	
	qui su std_redistribution
	assert round(r(mean),0.0001)==0	
	
	qui su std_donation 
	assert round(r(mean),0.0001)==0	
	
* CGI	
	qui su std_cgi_main if std_incentivized_risk!=.
	assert round(r(mean),0.0001)==0
	
	qui su std_cgi_main if incentivized_competitiveness!=.
	assert round(r(mean),0.0001)==0
	
	qui su std_cgi_main if rho!=.
	assert round(r(mean),0.0001)==0
	
	qui su std_cgi_main if std_staircase_risk!=.
	assert round(r(mean),0.0001)==0
	
	qui su std_cgi_main if std_hyp_risk !=.
	assert round(r(mean),0.0001)==0
	
	qui su std_cgi_main if std_competitiveness!=.
	assert round(r(mean),0.0001)==0
	
	qui su std_cgi_main if std_redistribution!=.
	assert round(r(mean),0.0001)==0
	
	qui su std_cgi_main if std_donation!=.
	assert round(r(mean),0.0001)==0
	
	
* CGI	follow up
	qui su std_cgi_main_fo if std_incentivized_risk!=.
	assert round(r(mean),0.0001)==0
	
	qui su std_cgi_main_fo if incentivized_competitiveness!=.
	assert round(r(mean),0.0001)==0
	
	qui su std_cgi_main_fo if rho!=.
	assert round(r(mean),0.0001)==0
	
	qui su std_cgi_main_fo if std_staircase_risk!=.
	assert round(r(mean),0.0001)==0
	
	qui su std_cgi_main_fo if std_hyp_risk !=.
	assert round(r(mean),0.0001)==0
	
	qui su std_cgi_main_fo if std_competitiveness!=.
	assert round(r(mean),0.0001)==0
	
	qui su std_cgi_main_fo if std_redistribution!=.
	assert round(r(mean),0.0001)==0
	
	qui su std_cgi_main_fo if std_donation!=.
	assert round(r(mean),0.0001)==0
	

	

foreach var of local variables{
*-----------------------------------------------------------------------------
* Panel A: biological gender	 
*-----------------------------------------------------------------------------
    if `z' ==1{
	qui reg `var' female, vce(hc3)
	}
	if `z' ==2{
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
	qui ivreg2 `var'  (std_cgi_main = std_cgi_main_fo), r

	}
	if `z' ==2{
	}

	    * Save estimates
        local rsqub_`i': di %6.3f e(r2)
		local rsqub_`i' = trim("$`rsqub_`i''$")
		
		if `sign_female'>0 {
			CHI_beta_coeff1_pos std_cgi_main 
			local beta_b_cgi_`i' `r(beta)'
			local se_b_cgi_`i' `r(se)'
		}
		
		if `sign_female'<0 {
			CHI_beta_coeff1_neg std_cgi_main 
			local beta_b_cgi_`i' `r(beta)'
			local se_b_cgi_`i' `r(se)'
		}
		
*-----------------------------------------------------------------------------				
* Panel C: biological gender and cgi 
*-----------------------------------------------------------------------------
	if `z' ==1{
	qui ivreg2 `var' female (std_cgi_main = std_cgi_main_fo), r
	}
	if `z' ==2{
	}
	    ** Save estimates to be used in reg table
        local N_`i': di %11.0gc e(N)
        local rsquc_`i': di %6.3f e(r2)
		local rsquc_`i' = trim("$`rsquc_`i''$")
		
		beta_coeff2 female
		local beta_c_sex_`i' `r(beta)'
		local se_c_sex_`i' `r(se)'			

		if `sign_female'>0 {
			CHI_beta_coeff1_pos std_cgi_main 
			local beta_c_cgi_`i' `r(beta)'
			local se_c_cgi_`i' `r(se)'
		}
		
		if `sign_female'<0 {
			CHI_beta_coeff1_neg std_cgi_main 
			local beta_c_cgi_`i' `r(beta)'
			local se_c_cgi_`i' `r(se)'
		}
		
	
*-----------------------------------------------------------------------------				
* Panel D: cgi for males and cgi for females
*-----------------------------------------------------------------------------				
* Panel D for females: 

	preserve
	
	keep if female==1
	
	drop std*
	
	* outcome var
	qui su incentivized_risk
 	gen std_incentivized_risk=(incentivized_risk-r(mean))/r(sd)
	qui su std_incentivized_risk
	assert round(r(mean),0.0001)==0
	
	qui su staircase_risk
 	gen std_staircase_risk=(staircase_risk-r(mean))/r(sd)
	qui su std_staircase_risk
	assert round(r(mean),0.0001)==0
	
	qui su hypothetical_risk
 	gen std_hyp_risk =(hypothetical_risk-r(mean))/r(sd)
	qui su std_hyp_risk 
	assert round(r(mean),0.0001)==0
	
	qui su competitiveness
 	gen std_competitiveness=(competitiveness-r(mean))/r(sd)
	qui su std_competitiveness
	assert round(r(mean),0.0001)==0
	
	qui su redistribution
 	gen std_redistribution=(redistribution-r(mean))/r(sd)
	qui su std_redistribution
	assert round(r(mean),0.0001)==0	
	
	qui su donation 
 	gen std_donation =(donation-r(mean))/r(sd)
	qui su std_donation
	assert round(r(mean),0.0001)==0	
	
	* cgi
	qui su cgi_main
 	gen std_cgi_main=(cgi_main-r(mean))/r(sd)
	qui su std_cgi_main 
	assert round(r(mean),0.0001)==0
	
	qui su cgi_main_fo
 	gen std_cgi_main_fo=(cgi_main_fo-r(mean))/r(sd)
	qui su std_cgi_main_fo
	assert round(r(mean),0.0001)==0
	
	
	if `z' ==1{
	qui ivreg2 `var' (std_cgi_main = std_cgi_main_fo) if female == 1, r
	}
	if `z' ==2{
	}
	    ** Save estimates to be used in reg table
		local rsquf_`i': di %6.3f `e(r2)'
		local rsquf_`i' = trim("$`rsquf_`i''$")

		if `sign_female'>0 {
			CHI_beta_coeff1_pos std_cgi_main 
			local beta_f_cgi_`i' `r(beta)'
			local se_f_cgi_`i' `r(se)'
			
		}
		
		if `sign_female'<0 {
			CHI_beta_coeff1_neg std_cgi_main 
			local beta_f_cgi_`i' `r(beta)'
			local se_f_cgi_`i' `r(se)'
		}
		
restore

* Panel D for males: 
	preserve
	
	keep if female==0
	
	drop std*
	
	* outcome var
	qui su incentivized_risk
 	gen std_incentivized_risk=(incentivized_risk-r(mean))/r(sd)
	qui su std_incentivized_risk
	assert round(r(mean),0.0001)==0
	
	qui su staircase_risk
 	gen std_staircase_risk=(staircase_risk-r(mean))/r(sd)
	qui su std_staircase_risk
	assert round(r(mean),0.0001)==0
	
	qui su hypothetical_risk
 	gen std_hyp_risk =(hypothetical_risk-r(mean))/r(sd)
	qui su std_hyp_risk 
	assert round(r(mean),0.0001)==0
	
	qui su competitiveness
 	gen std_competitiveness=(competitiveness-r(mean))/r(sd)
	qui su std_competitiveness
	assert round(r(mean),0.0001)==0
	
	qui su redistribution
 	gen std_redistribution=(redistribution-r(mean))/r(sd)
	qui su std_redistribution
	assert round(r(mean),0.0001)==0	
	
	qui su donation 
 	gen std_donation =(donation-r(mean))/r(sd)
	qui su std_donation
	assert round(r(mean),0.0001)==0	
	
	* cgi
	qui su cgi_main
 	gen std_cgi_main=(cgi_main-r(mean))/r(sd)
	qui su std_cgi_main 
	assert round(r(mean),0.0001)==0
	
	qui su cgi_main_fo
 	gen std_cgi_main_fo=(cgi_main_fo-r(mean))/r(sd)
	qui su std_cgi_main_fo
	assert round(r(mean),0.0001)==0
	
	
	
	if `z' ==1{
	qui ivreg2 `var' (std_cgi_main = std_cgi_main_fo) if female == 0, r
	}
	if `z' ==2{
	}
	    ** Save estimates to be used in reg table
        local rsqum_`i': di %6.3f e(r2)
		local rsqum_`i' = trim("$`rsqum_`i''$")
				
		if `sign_female'>0 {
			CHI_beta_coeff1_pos std_cgi_main 
			local beta_m_cgi_`i' `r(beta)'
			local se_m_cgi_`i' `r(se)'
		}
		
		if `sign_female'<0 {
			CHI_beta_coeff1_neg std_cgi_main 
			local beta_m_cgi_`i' `r(beta)'
			local se_m_cgi_`i' `r(se)'
		}

restore		
		qui su `var'
        local mean_`i': di %6.3f r(mean)
		
		if r(mean) < 0.0001 {
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
        file open resultsfile using "$`path'/oriv/ivreg_SwissUni.tex", write replace
}	



*-----------------------------------------------------------------------------
* Write Table header
*-----------------------------------------------------------------------------
//file write resultsfile "\begin{table}[H]"
//file write resultsfile "\centering"
//file write resultsfile "\begin{adjustbox}{max width=16cm}"
//file write resultsfile "\begin{threeparttable}"
file write resultsfile "\caption{ORIV Analysis - Swiss Uni Sample}"
file write resultsfile "\begin{tabular}"
file write resultsfile "{p{1.7cm} M{2.8cm} M{2.8cm} M{2.8cm} M{2.8cm} M{2.8cm} M{2.8cm} M{2.8cm} M{2.8cm}}" 
file write resultsfile "\toprule\toprule"
file write resultsfile "\addlinespace[0.2cm]"
file write resultsfile "\multicolumn{1}{l}{} & \multicolumn{3}{c}{Incentivized Measures} &  \multicolumn{5}{c}{Unincentivized Measures} \\"
file write resultsfile "\cmidrule(lr){2-4} \cmidrule(lr){5-9} \\"
file write resultsfile "\multicolumn{1}{l}{Measure} & Risk & Competitiveness  & Efficiency  & \thead{Staircase \\ Risk} &  Risk & Competitiveness & Redistribution & Alturism \\"
file write resultsfile "& (1) & (2) & (3) & (4) & (5) & (6) & (7) & (8)  \\"
file write resultsfile "\midrule"
file write resultsfile" \addlinespace[0.2cm]"


*-----------------------------------------------------------------------------
* Write Panel A
*-----------------------------------------------------------------------------

file write resultsfile "\multicolumn{5}{l}{\textbf{Panel A. Binary gender}} \\" _n
file write resultsfile " \multicolumn{1}{l}{Female} & $`beta_a_sex_1'$  &	$`beta_a_sex_2'$ &	$`beta_a_sex_3'$ &	$`beta_a_sex_4'$  &	$`beta_a_sex_5'$ &	$`beta_a_sex_6'$ &	$`beta_a_sex_7'$ &	$`beta_a_sex_8'$  \\" _n
file write resultsfile " & (`se_a_sex_1')	&	(`se_a_sex_2')    &	(`se_a_sex_3') &	(`se_a_sex_4') &	(`se_a_sex_5') &	(`se_a_sex_6') &	(`se_a_sex_7') &	(`se_a_sex_8')   \\" _n
file write resultsfile "\addlinespace[0.1cm]"
file write resultsfile " \multicolumn{1}{l}{$\text{R}^2$}	& `rsqua_1'	  &	`rsqua_2' &	`rsqua_3' &	`rsqua_4' &	`rsqua_5' &	`rsqua_6' &	`rsqua_7' &	`rsqua_8'  \\ \\" _n
file write resultsfile "\addlinespace[-0.3cm]"
file write resultsfile "\midrule"

*-----------------------------------------------------------------------------
* Write Panel B
*-----------------------------------------------------------------------------
file write resultsfile "\multicolumn{5}{l}{\textbf{Panel B. Gender identity}} \\" _n
file write resultsfile " \multicolumn{1}{l}{ORIV CGI (feminine)} & $`beta_b_cgi_1'$  &	$`beta_b_cgi_2'$ &	$`beta_b_cgi_3'$ &	$`beta_b_cgi_4'$ &	$`beta_b_cgi_5'$ & $`beta_b_cgi_6'$ & $`beta_b_cgi_7'$ & $`beta_b_cgi_8'$ \\" _n
file write resultsfile "  &	(`se_b_cgi_1')  &	(`se_b_cgi_2')   &(`se_b_cgi_3') &	(`se_b_cgi_4') &	(`se_b_cgi_5') & (`se_b_cgi_6') & (`se_b_cgi_7') & (`se_b_cgi_8') \\  \\" _n
file write resultsfile "\addlinespace[0.1cm]"
//file write resultsfile " \multicolumn{1}{l}{$\text{R}^2$}	& `rsqub_1'	& `rsqub_2' & `rsqub_3' &	`rsqub_4' &	`rsqub_5' &	`rsqub_6' &	`rsqub_7' &	`rsqub_8'   \\ \\" _n
file write resultsfile "\addlinespace[-0.3cm]"
file write resultsfile "\midrule"

*-----------------------------------------------------------------------------
* Write Panel C
*-----------------------------------------------------------------------------
file write resultsfile "\multicolumn{5}{l}{\textbf{Panel C. Binary gender and gender identity}} \\" _n
file write resultsfile " \multicolumn{1}{l}{Female} & $`beta_c_sex_1'$  &	$`beta_c_sex_2'$	& $`beta_c_sex_3'$ 	&	$`beta_c_sex_4'$ &	$`beta_c_sex_5'$ 	&	$`beta_c_sex_6'$ &	$`beta_c_sex_7'$ &	$`beta_c_sex_8'$  \\" _n
file write resultsfile " & (`se_c_sex_1')	   &	(`se_c_sex_2')	& (`se_c_sex_3')  &	(`se_c_sex_4') &	(`se_c_sex_5') &	(`se_c_sex_6') &	(`se_c_sex_7') &	(`se_c_sex_8')   \\ \\" _n
file write resultsfile "\addlinespace[-0.3cm]"
file write resultsfile " \multicolumn{1}{l}{ORIV CGI (feminine)} & $`beta_c_cgi_1'$  &	$`beta_c_cgi_2'$ &	$`beta_c_cgi_3'$ &	$`beta_c_cgi_4'$ &	$`beta_c_cgi_5'$ &	$`beta_c_cgi_6'$ &	$`beta_c_cgi_7'$ &	$`beta_c_cgi_8'$    \\" _n
file write resultsfile " & (`se_c_cgi_1')	 &	(`se_c_cgi_2')    &	(`se_c_cgi_3')	&	(`se_c_cgi_4') &	(`se_c_cgi_5') & (`se_c_cgi_6') & (`se_c_cgi_7') & (`se_c_cgi_8')   \\ \\" _n
file write resultsfile "\addlinespace[0.1cm]"
//file write resultsfile " \multicolumn{1}{l}{$\text{R}^2$}	& `rsquc_1' & `rsquc_2' &	`rsquc_3' & `rsquc_4' &	`rsquc_5' &	`rsquc_6' &	`rsquc_7' &	`rsquc_8'  \\ \\" _n		
file write resultsfile "\addlinespace[-0.3cm]"
file write resultsfile "\midrule"

*-----------------------------------------------------------------------------
* Write Panel D
*-----------------------------------------------------------------------------
file write resultsfile "\multicolumn{5}{l}{\textbf{Panel D. Sample split by binary gender}} \\" _n
file write resultsfile "  \multicolumn{1}{l}{Female: ORIV CGI (feminine)}  & $`beta_f_cgi_1'$  &	$`beta_f_cgi_2'$ &	$`beta_f_cgi_3'$ &	$`beta_f_cgi_4'$ &	$`beta_f_cgi_5'$ &	$`beta_f_cgi_6'$ &	$`beta_f_cgi_7'$ &	$`beta_f_cgi_8'$  \\" _n
file write resultsfile "  & (`se_f_cgi_1')	   &	(`se_f_cgi_2') &	(`se_f_cgi_3')	&	(`se_f_cgi_4') &	(`se_f_cgi_5') &  (`se_f_cgi_6') &  (`se_f_cgi_7') &  (`se_f_cgi_8') \\ \\" _n	
file write resultsfile "\addlinespace[0.1cm]"
//file write resultsfile " \multicolumn{1}{l}{$\text{R}^2$}	& `rsquf_1'	&	`rsquf_2'   &	`rsquf_3' &	`rsquf_4' &	`rsquf_5' &	`rsquf_6' &	`rsquf_7' &	`rsquf_8'  \\ \\" _n
file write resultsfile "\addlinespace[-0.3cm]"	

file write resultsfile " \multicolumn{1}{l}{Male: ORIV CGI (feminine)} & $`beta_m_cgi_1'$  &	$`beta_m_cgi_2'$ &	$`beta_m_cgi_3'$ &	$`beta_m_cgi_4'$ &	$`beta_m_cgi_5'$ & $`beta_m_cgi_6'$ & $`beta_m_cgi_7'$ & $`beta_m_cgi_8'$ \\" _n
file write resultsfile " & (`se_m_cgi_1')	  &	(`se_m_cgi_2') &	(`se_m_cgi_3') &	(`se_m_cgi_4') &	(`se_m_cgi_5') & (`se_m_cgi_6') & (`se_m_cgi_7') & (`se_m_cgi_8') \\  \\" _n
file write resultsfile "\addlinespace[0.1cm]"
//file write resultsfile " \multicolumn{1}{l}{$\text{R}^2$}	& `rsqum_1'	 & `rsqum_2'   &	`rsqum_3' &	`rsqum_4' &	`rsqum_5' &	`rsqum_6' &	`rsqum_7' &	`rsqum_8'  \\ \\" _n	
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
//file write resultsfile "\begin{tablenotes}"


//file write resultsfile "\item  \textit{Notes:} Swiss Uni sample is used. Panels B and C instrument our standardized single item gender identity question (10-point scale) with a similar question in the follow up survey (11-point scale).  "



//file write resultsfile "\end{tablenotes}"
//file write resultsfile "\end{threeparttable}"
//file write resultsfile "\end{adjustbox}"
//file write resultsfile "\end{table}"
file close resultsfile
}
