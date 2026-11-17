clear all

global out_path "$path/3_out" 
cd "$path/1_data/4_temp"

use "$path/1_data/2_prepared/1_usadults_w2_20_60.dta", replace

local colno "14"

local gender_measures cgi_main tmf_score magliozzi_fem magliozzi_mas wangnerud_fem wangnerud_mas osri_fem osri_mas cfni_score cmni_score bsri_fem bsri_masc cgi_other cgi_own
local variables redistribution competitiveness hypothetical_risk incentivized_risk major_share homemaker income_cont yearly_work_hours_weeklyaverage negot_yes manager financial_market 

foreach v of local variables {
	local i=1	
	foreach g of local gender_measures{
	preserve
*-----------------------------------------------------------------------------
* (Re)Standardization
*-----------------------------------------------------------------------------
	drop *_1 *_2 *_3 *_NPS_GROUP
	
	* Restandardize cgi after dropping outcome variables that are missing

	drop if `v'==.
	drop if std_`g'==.
	
	drop std_`g'
	qui su `g'
	gen  std_`g'=(`g'-r(mean))/r(sd)
	
	if inlist("`v'", "redistribution", "hypothetical_risk", "incentivized_risk", "competitiveness") {
		qui su `v' if std_`g'!=.
		replace `v'=(`v'-r(mean))/r(sd) // standardization of these variables
	}
	
*-----------------------------------------------------------------------------
* Mean Dependent variable
*-----------------------------------------------------------------------------
	qui su `v' if std_`g'!=.
	local mean_`i': di %6.3f r(mean)
	
	if `mean_`i''<0.0001 {
	local mean_`i': di %6.0f round(r(mean)) // get rid of the decimals for standardized outcome means
	}
			

*-----------------------------------------------------------------------------
* Panel A : Female
*-----------------------------------------------------------------------------
	qui reg `v' female, vce(hc3)

	local rsqua_`i': di %6.3f e(r2)
	local rsqua_`i' = trim("$`rsqua_`i''$")
	
	beta_coeff2 female
	local beta_a_sex_`i' `r(beta)'
	local se_a_sex_`i' `r(se)'	
	
	local sign_female = sign(_b[female])
	
*-----------------------------------------------------------------------------
* Panel B : Continuous Gender
*-----------------------------------------------------------------------------
	
	qui reg `v' std_`g', vce(hc3)
	
	local rsqub_`i': di %6.3f e(r2)
	local rsqub_`i' = trim("$`rsqub_`i''$")
	
	if inlist("`g'", "cgi_main", "cgi_other", "cgi_own", "tmf_score", "magliozzi_fem", "wangnerud_fem", "osri_fem", "cfni_score", "bsri_fem") {
		if `sign_female'>0 {
			beta_coeff1_pos std_`g'
			local beta_b_cgi_`i' `r(beta)'
			local se_b_cgi_`i' `r(se)'
		}

		if `sign_female'<0 {
			beta_coeff1_neg std_`g'
			local beta_b_cgi_`i' `r(beta)'
			local se_b_cgi_`i' `r(se)'
		}
	}
	
	if inlist("`g'", "magliozzi_mas", "wangnerud_mas", "osri_mas", "cmni_score", "bsri_masc") {
		if `sign_female'<0 {
			beta_coeff1_pos std_`g'
			local beta_b_cgi_`i' `r(beta)'
			local se_b_cgi_`i' `r(se)'
		}

		if `sign_female'>0 {
			beta_coeff1_neg std_`g'
			local beta_b_cgi_`i' `r(beta)'
			local se_b_cgi_`i' `r(se)'
		}
	}
	
*-----------------------------------------------------------------------------
* Panel C: female and continuous gender
*-----------------------------------------------------------------------------
	qui reg `v' female std_`g', vce(hc3)
	
    local N_`i': di %11.0gc e(N)
    local rsquc_`i': di %6.3f e(r2)
	local rsquc_`i' = trim("$`rsquc_`i''$")
		
	beta_coeff2 female
	local beta_c_sex_`i' `r(beta)'
	local se_c_sex_`i' `r(se)'	
	
	if inlist("`g'", "cgi_main", "cgi_other", "cgi_own", "tmf_score", "magliozzi_fem", "wangnerud_fem", "osri_fem", "cfni_score", "bsri_fem") {
		if `sign_female'>0 {
			beta_coeff1_pos std_`g' 
			local beta_c_cgi_`i' `r(beta)'
			local se_c_cgi_`i' `r(se)'
		}

		if `sign_female'<0 {
			beta_coeff1_neg std_`g'
			local beta_c_cgi_`i' `r(beta)'
			local se_c_cgi_`i' `r(se)'
		}
	}
	
	if inlist("`g'", "magliozzi_mas", "wangnerud_mas", "osri_mas", "cmni_score", "bsri_masc") {
		if `sign_female'<0 {
			beta_coeff1_pos std_`g'
			local beta_c_cgi_`i' `r(beta)'
			local se_c_cgi_`i' `r(se)'
		}

		if `sign_female'>0 {
			beta_coeff1_neg std_`g'
			local beta_c_cgi_`i' `r(beta)'
			local se_c_cgi_`i' `r(se)'
		}
	}
			** save estimates to be used in meta analysis
		local beta_c_cgi_`i'_meta = _b[std_`g']
		local se_c_cgi_`i'_meta = _se[std_`g']
		local p_c_cgi_`i'_meta=2*ttail(e(df_r),abs(_b[std_`g']/_se[std_`g']))
		
			* save 1 tailed version
			qui test _b[std_`g']=0 
			local sign_cgi = sign(_b[std_`g'])
			
			if inlist("`g'", "cgi_main", "cgi_other", "cgi_own", "tmf_score", "magliozzi_fem", "wangnerud_fem", "osri_fem", "cfni_score", "bsri_fem") {
			
			if `sign_female'>0 {
			local p_c_cgi_`i'_meta_1t = ttail(r(df_r),`sign_cgi'*sqrt(r(F))) // Ho: coef <= 0
			}
			if `sign_female'<0 {
			local p_c_cgi_`i'_meta_1t = 1-ttail(r(df_r),`sign_cgi'*sqrt(r(F))) // Ho: coef >= 0
			}
			
			}
			
	if inlist("`g'", "magliozzi_mas", "wangnerud_mas", "osri_mas", "cmni_score", "bsri_masc") {
			if `sign_female'<0 {
			local p_c_cgi_`i'_meta_1t = ttail(r(df_r),`sign_cgi'*sqrt(r(F))) // Ho: coef <= 0
			}
			if `sign_female'>0 {
			local p_c_cgi_`i'_meta_1t = 1-ttail(r(df_r),`sign_cgi'*sqrt(r(F))) // Ho: coef >= 0
			}
		
	}	
			* save R2 to be used for R2 meta analysis ***
			local rsquc_`i'_meta = e(r2)
			local adjrsquc_`i'_meta = e(r2_a)

restore		
*-----------------------------------------------------------------------------
* Panel D (female) : Sample Split by Binary Sex
*-----------------------------------------------------------------------------
preserve	

	use "$path/1_data/2_prepared/1_usadults_w2_20_60.dta", replace
	keep if female==1
	
	drop *_1 *_2 *_3 *_NPS_GROUP
	drop if `v'==.

	drop if std_`g'==.
	
	drop std_`g'
	qui su `g'
	gen  std_`g'=(`g'-r(mean))/r(sd)
	
	if inlist("`v'", "redistribution", "hypothetical_risk", "incentivized_risk", "competitiveness") {
		qui su `v'
		replace `v'=(`v'-r(mean))/r(sd) // standardization of these variables
	}	
	
	qui reg `v' female std_`g' if female == 1, vce(hc3)

	local rsquf_`i': di %6.3f `e(r2)'
	local rsquf_`i' = trim("$`rsquf_`i''$")
	
	if inlist("`g'", "cgi_main", "cgi_other", "cgi_own", "tmf_score", "magliozzi_fem", "wangnerud_fem", "osri_fem", "cfni_score", "bsri_fem") {
		if `sign_female'>0 {
			beta_coeff1_pos std_`g'
			local beta_f_cgi_`i' `r(beta)'
			local se_f_cgi_`i' `r(se)'
			
		}
		
		if `sign_female'<0 {
			beta_coeff1_neg std_`g'
			local beta_f_cgi_`i' `r(beta)'
			local se_f_cgi_`i' `r(se)'
		}
	}
	
	if inlist("`g'", "magliozzi_mas", "wangnerud_mas", "osri_mas", "cmni_score", "bsri_masc") {
	
		if `sign_female'<0 {
			beta_coeff1_pos std_`g'
			local beta_f_cgi_`i' `r(beta)'
			local se_f_cgi_`i' `r(se)'
			
		}
		
		if `sign_female'>0 {
			beta_coeff1_neg std_`g'
			local beta_f_cgi_`i' `r(beta)'
			local se_f_cgi_`i' `r(se)'
		}
	}

restore

*-----------------------------------------------------------------------------
* Panel D (male) : Sample Split by Binary Sex
*-----------------------------------------------------------------------------
preserve	
	use "$path/1_data/2_prepared/1_usadults_w2_20_60.dta", replace
	keep if female==0

	drop *_1 *_2 *_3 *_NPS_GROUP
	drop if `v'==.
	drop if std_`g'==.
	
	drop std_`g'
	qui su `g'
	gen  std_`g'=(`g'-r(mean))/r(sd)
	
	if inlist("`v'", "redistribution", "hypothetical_risk", "incentivized_risk", "competitiveness") {
		qui su `v'
		replace `v'=(`v'-r(mean))/r(sd) // standardization of these variables
	}	

	qui reg `v' female std_`g' if female == 0, vce(hc3)

	local rsqum_`i': di %6.3f `e(r2)'
	local rsqum_`i' = trim("$`rsqum_`i''$")
	
	if inlist("`g'", "cgi_main", "cgi_other", "cgi_own", "tmf_score", "magliozzi_fem", "wangnerud_fem", "osri_fem", "cfni_score", "bsri_fem") {
		if `sign_female'>0 {
			beta_coeff1_pos std_`g'
			local beta_m_cgi_`i' `r(beta)'
			local se_m_cgi_`i' `r(se)'
			
		}
		
		if `sign_female'<0 {
			beta_coeff1_neg std_`g'
			local beta_m_cgi_`i' `r(beta)'
			local se_m_cgi_`i' `r(se)'
		}
	}
	
	if inlist("`g'", "magliozzi_mas", "wangnerud_mas", "osri_mas", "cmni_score", "bsri_masc") {
	
		if `sign_female'<0 {
			beta_coeff1_pos std_`g'
			local beta_m_cgi_`i' `r(beta)'
			local se_m_cgi_`i' `r(se)'
			
		}
		
		if `sign_female'>0 {
			beta_coeff1_neg std_`g'
			local beta_m_cgi_`i' `r(beta)'
			local se_m_cgi_`i' `r(se)'
		}
	}
restore

	local i=`i'+1

}

	
foreach path in out_path{
	
file open resultsfile using "$`path'/othermeasures_vs_CGI/reg_`v'.tex", write replace

if "`v'"=="redistribution" {
	local variable_title="Redistribution"
}

if "`v'"=="competitiveness" {
	local variable_title="Competitiveness"
}

if "`v'"=="hypothetical_risk" {
	local variable_title="Unincentivized Risk"
}

if "`v'"=="incentivized_risk" {
	local variable_title="Incentivized Risk"
}

if "`v'"=="major_share" {
	local variable_title="Female Educational Track Share"
}

if "`v'"=="homemaker" {
	local variable_title="Full-time Homemaker"
}

if "`v'"=="income_cont" {
	local variable_title="Income"
}

if "`v'"=="yearly_work_hours_weeklyaverage" {
	local variable_title="Weekly Average Work Hours"
}

if "`v'"=="negot_yes" {
	local variable_title="Wage Negotiation"
}

if "`v'"=="manager" {
	local variable_title="Managerial Responsibilities"
}

if "`v'"=="negot_yes" {
	local variable_title="Wage Negotiation"
}

if "`v'"=="financial_market" {
	local variable_title="Financial Risk"
}


*-----------------------------------------------------------------------------
* Write Table header
*-----------------------------------------------------------------------------
//file write resultsfile "\begin{table}[H]"
//file write resultsfile "\centering"
//file write resultsfile "\begin{adjustbox}{max width=24cm}"
//file write resultsfile "\begin{threeparttable}"
file write resultsfile "\caption{Other Gender Identity Measures and `variable_title' }"
file write resultsfile "\begin{tabular}"
file write resultsfile "{p{1.7cm} M{2.1cm} M{2.1cm} M{2.1cm} M{2.1cm} M{2.1cm} M{2.1cm} M{2.1cm} M{2.1cm} M{2.1cm} M{2.1cm} M{2.1cm} M{2.1cm} M{2.1cm} M{2.1cm}}"
file write resultsfile "\toprule\toprule"
file write resultsfile "\addlinespace[0.2cm]"
file write resultsfile "\multicolumn{1}{l}{Gender Measure} & \thead{CGI \\ main} & TMF & \thead{Maglioz \\ fem} & \thead{Maglioz \\ mas} & \thead{SOM \\ fem} & \thead{SOM\\ mas} & \thead{OSRI \\ fem} & \thead{OSRI \\ mas} & CFNI & CMNI & \thead{BSRI \\ fem} & \thead{BSRI \\ mas} & \thead{CGI \\ other} &  \thead{CGI \\ own} \\"
file write resultsfile "& (1) & (2) & (3) & (4) & (5) & (6) & (7) & (8) & (9) & (10) & (11) & (12) & (13) & (14)\\"
file write resultsfile "\midrule"
file write resultsfile" \addlinespace[0.2cm]"

*-----------------------------------------------------------------------------
* Write Panel A
*-----------------------------------------------------------------------------

file write resultsfile "\multicolumn{5}{l}{\textbf{Panel A. Binary gender}} \\" _n
file write resultsfile " \multicolumn{1}{l}{Female} & $`beta_a_sex_1'$  &	$`beta_a_sex_2'$ &	$`beta_a_sex_3'$ &	$`beta_a_sex_4'$  &	$`beta_a_sex_5'$ &	$`beta_a_sex_6'$ &	$`beta_a_sex_7'$ &	$`beta_a_sex_8'$ &	$`beta_a_sex_9'$ &	$`beta_a_sex_10'$ &	$`beta_a_sex_11'$ &	$`beta_a_sex_12'$ &	$`beta_a_sex_13'$ &	$`beta_a_sex_14'$\\" _n
file write resultsfile " & (`se_a_sex_1')	&	(`se_a_sex_2')    &	(`se_a_sex_3') &	(`se_a_sex_4') &	(`se_a_sex_5') & (`se_a_sex_6') & (`se_a_sex_7') & (`se_a_sex_8') & (`se_a_sex_9') & (`se_a_sex_10') & (`se_a_sex_11') & (`se_a_sex_12') & (`se_a_sex_13') & (`se_a_sex_14') \\" _n
file write resultsfile "\addlinespace[0.1cm]"
file write resultsfile " \multicolumn{1}{l}{$\text{R}^2$}			& `rsqua_1'	  &	`rsqua_2' &	`rsqua_3' &	`rsqua_4' &	`rsqua_5' &	`rsqua_6'  &	`rsqua_7'  &	`rsqua_8'  &	`rsqua_9'  &	`rsqua_10'  &	`rsqua_11'  &	`rsqua_12'  &	`rsqua_13'  &	`rsqua_14' \\ \\" _n
file write resultsfile "\addlinespace[-0.3cm]"
file write resultsfile "\midrule"


*-----------------------------------------------------------------------------
* Write Panel B
*-----------------------------------------------------------------------------
file write resultsfile "\multicolumn{5}{l}{\textbf{Panel B. Gender identity}} \\" _n
file write resultsfile " \multicolumn{1}{l}{GI} & $`beta_b_cgi_1'$  &	$`beta_b_cgi_2'$ &	$`beta_b_cgi_3'$	 &	$`beta_b_cgi_4'$ &	$`beta_b_cgi_5'$ &	$`beta_b_cgi_6'$ &	$`beta_b_cgi_7'$  &	$`beta_b_cgi_8'$  &	$`beta_b_cgi_9'$  &	$`beta_b_cgi_10'$  &	$`beta_b_cgi_11'$  &	$`beta_b_cgi_12'$  &	$`beta_b_cgi_13'$  &	$`beta_b_cgi_14'$  \\" _n
file write resultsfile "  &	(`se_b_cgi_1')  &	(`se_b_cgi_2')   &(`se_b_cgi_3') &	(`se_b_cgi_4') &	(`se_b_cgi_5') & (`se_b_cgi_6') & (`se_b_cgi_7')  & (`se_b_cgi_8')  & (`se_b_cgi_9')  & (`se_b_cgi_10')  & (`se_b_cgi_11')  & (`se_b_cgi_12')  & (`se_b_cgi_13')  & (`se_b_cgi_14')  \\" _n
file write resultsfile "\addlinespace[0.1cm]"
file write resultsfile " \multicolumn{1}{l}{$\text{R}^2$}			& `rsqub_1'	   &	`rsqub_2' &	`rsqub_3' &	`rsqub_4' &	`rsqub_5' &	`rsqub_6' &	`rsqub_7'  &	`rsqub_8'  &	`rsqub_9'  &	`rsqub_10'  &	`rsqub_11'  &	`rsqub_12'  &	`rsqub_13'  &	`rsqub_14'  \\ \\" _n
file write resultsfile "\addlinespace[-0.3cm]"
file write resultsfile "\midrule"

*-----------------------------------------------------------------------------
* Write Panel C
*-----------------------------------------------------------------------------
file write resultsfile "\multicolumn{5}{l}{\textbf{Panel C. Binary gender and gender identity}} \\" _n
file write resultsfile " \multicolumn{1}{l}{Female} & $`beta_c_sex_1'$  &	$`beta_c_sex_2'$ &	$`beta_c_sex_3'$	&	$`beta_c_sex_4'$ &	$`beta_c_sex_5'$  &	$`beta_c_sex_6'$   &	$`beta_c_sex_7'$   &	$`beta_c_sex_8'$   &	$`beta_c_sex_9'$   &	$`beta_c_sex_10'$   &	$`beta_c_sex_11'$   &	$`beta_c_sex_12'$   &	$`beta_c_sex_13'$   &	$`beta_c_sex_14'$ \\" _n
file write resultsfile " & (`se_c_sex_1')	  &	(`se_c_sex_2') &	(`se_c_sex_3')	&	(`se_c_sex_4') &	(`se_c_sex_5') & (`se_c_sex_6')  & (`se_c_sex_7')  & (`se_c_sex_8')  & (`se_c_sex_9')  & (`se_c_sex_10')  & (`se_c_sex_11')  & (`se_c_sex_12')  & (`se_c_sex_13')  & (`se_c_sex_14') \\ \\" _n	
file write resultsfile "\addlinespace[-0.3cm]"
file write resultsfile " \multicolumn{1}{l}{GI} & $`beta_c_cgi_1'$  &	$`beta_c_cgi_2'$ &	$`beta_c_cgi_3'$ &	$`beta_c_cgi_4'$ &	$`beta_c_cgi_5'$ &	$`beta_c_cgi_6'$  &	$`beta_c_cgi_7'$  &	$`beta_c_cgi_8'$  &	$`beta_c_cgi_9'$  &	$`beta_c_cgi_10'$  &	$`beta_c_cgi_11'$  &	$`beta_c_cgi_12'$  &	$`beta_c_cgi_13'$  &	$`beta_c_cgi_14'$ \\" _n
file write resultsfile " & (`se_c_cgi_1')	 &	(`se_c_cgi_2')    &	(`se_c_cgi_3')	&	(`se_c_cgi_4') &	(`se_c_cgi_5') & (`se_c_cgi_6')  & (`se_c_cgi_7')  & (`se_c_cgi_8')  & (`se_c_cgi_9')  & (`se_c_cgi_10')  & (`se_c_cgi_11')  & (`se_c_cgi_12')  & (`se_c_cgi_13')  & (`se_c_cgi_14') \\" _n
file write resultsfile "\addlinespace[0.1cm]"
file write resultsfile " \multicolumn{1}{l}{$\text{R}^2$}			& `rsquc_1' & `rsquc_2' &	`rsquc_3' & `rsquc_4' &	`rsquc_5' &	`rsquc_6'  &	`rsquc_7'  &	`rsquc_8'  &	`rsquc_9'  &	`rsquc_10'  &	`rsquc_11'  &	`rsquc_12'  &	`rsquc_13'  &	`rsquc_14' \\ \\" _n		
file write resultsfile "\addlinespace[-0.3cm]"
file write resultsfile "\midrule"

*-----------------------------------------------------------------------------
* Write Panel D
*-----------------------------------------------------------------------------
file write resultsfile "\multicolumn{5}{l}{\textbf{Panel D. Sample split by binary gender}} \\" _n
file write resultsfile "  \multicolumn{1}{l}{Female: GI}  & $`beta_f_cgi_1'$  &	$`beta_f_cgi_2'$ &	$`beta_f_cgi_3'$ &	$`beta_f_cgi_4'$ &	$`beta_f_cgi_5'$ &	$`beta_f_cgi_6'$  &	$`beta_f_cgi_7'$  &	$`beta_f_cgi_8'$  &	$`beta_f_cgi_9'$  &	$`beta_f_cgi_10'$  &	$`beta_f_cgi_11'$  &	$`beta_f_cgi_12'$  &	$`beta_f_cgi_13'$  &	$`beta_f_cgi_14'$ \\" _n
file write resultsfile "  & (`se_f_cgi_1')	   &	(`se_f_cgi_2') &	(`se_f_cgi_3')	&	(`se_f_cgi_4') &	(`se_f_cgi_5') & (`se_f_cgi_6')  & (`se_f_cgi_7')  & (`se_f_cgi_8')  & (`se_f_cgi_9')  & (`se_f_cgi_10')  & (`se_f_cgi_11')  & (`se_f_cgi_12')  & (`se_f_cgi_13')  & (`se_f_cgi_14') \\" _n	
file write resultsfile "\addlinespace[0.1cm]"
file write resultsfile " \multicolumn{1}{l}{$\text{R}^2$}			& `rsquf_1'	&	`rsquf_2'   &	`rsquf_3' &	`rsquf_4' &	`rsquf_5' &	`rsquf_6'  &	`rsquf_7'  &	`rsquf_8'  &	`rsquf_9'  &	`rsquf_10'  &	`rsquf_11'  &	`rsquf_12'  &	`rsquf_13'  &	`rsquf_14' \\ \\" _n
file write resultsfile "\addlinespace[-0.3cm]"	

file write resultsfile " \multicolumn{1}{l}{Male: GI} & $`beta_m_cgi_1'$  &	$`beta_m_cgi_2'$ &	$`beta_m_cgi_3'$ &	$`beta_m_cgi_4'$ &	$`beta_m_cgi_5'$ &	$`beta_m_cgi_6'$  &	$`beta_m_cgi_7'$  &	$`beta_m_cgi_8'$  &	$`beta_m_cgi_9'$  &	$`beta_m_cgi_10'$  &	$`beta_m_cgi_11'$  &	$`beta_m_cgi_12'$  &	$`beta_m_cgi_13'$  &	$`beta_m_cgi_14'$ \\" _n
file write resultsfile " & (`se_m_cgi_1')	  &	(`se_m_cgi_2') &	(`se_m_cgi_3') &	(`se_m_cgi_4') &	(`se_m_cgi_5') & (`se_m_cgi_6')  & (`se_m_cgi_7')  & (`se_m_cgi_8')  & (`se_m_cgi_9')  & (`se_m_cgi_10')  & (`se_m_cgi_11')  & (`se_m_cgi_12')  & (`se_m_cgi_13')  & (`se_m_cgi_14') \\" _n
file write resultsfile "\addlinespace[0.1cm]"
file write resultsfile " \multicolumn{1}{l}{$\text{R}^2$} & `rsqum_1'	 & `rsqum_2'   &	`rsqum_3' &	`rsqum_4' &	`rsqum_5' &	`rsqum_6'  &	`rsqum_7'  &	`rsqum_8'  &	`rsqum_9'  &	`rsqum_10'  &	`rsqum_11'  &	`rsqum_12'  &	`rsqum_13'  &	`rsqum_14' \\ \\" _n	
file write resultsfile "\addlinespace[-0.5cm]"
file write resultsfile "\midrule"

*-----------------------------------------------------------------------------
* Write Obs number row
*-----------------------------------------------------------------------------
file write resultsfile " \multicolumn{1}{l}{Observations} & `N_1' & `N_2' & `N_3' & `N_4' & `N_5' & `N_6'  & `N_7'  & `N_8'  & `N_9'  & `N_10'  & `N_11'  & `N_12'  & `N_13'  & `N_14' \\ \\" _n
file write resultsfile "\addlinespace[-0.3cm]"
		
file write resultsfile "\multicolumn{1}{l}{Mean of Dependent Variable}  & `mean_1' & `mean_2' & `mean_3' & `mean_4' & `mean_5' & `mean_6'  & `mean_7'  & `mean_8'  & `mean_9'  & `mean_10'  & `mean_11'  & `mean_12'  & `mean_13'  & `mean_14' \\ \\" _n
file write resultsfile "\addlinespace[-0.3cm]"

*-----------------------------------------------------------------------------
* Write Table footer
*-----------------------------------------------------------------------------
file write resultsfile "\bottomrule\bottomrule"
file write resultsfile "\end{tabular}"
//file write resultsfile "\begin{tablenotes}"
//file write resultsfile "\item \textit{Notes.}  *** p$<$0.005, ** p$<$0.01, * p$<$0.05."
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
    * Create an empty dataset
    clear
    set obs `colno'
	gen beta_c_cgi=.
	gen se_c_cgi=.
	gen p_c_cgi=.
	gen p_c_cgi_1t=.
	gen col_num=. 
	gen measure=""
	
    * Save coefficients	
	forvalues i=1/`colno'{
		replace beta_c_cgi = `beta_c_cgi_`i'_meta' in `i' //beta
		replace se_c_cgi = `se_c_cgi_`i'_meta' in `i' //se
		replace p_c_cgi = `p_c_cgi_`i'_meta' in `i' //pval
		replace p_c_cgi_1t = `p_c_cgi_`i'_meta_1t' in `i' //pval 1 tail
		replace col_num = `i' in `i' //column number as shown the table
		
	}
		replace measure="CGI" in 1
		replace measure="tmf" in 2
		replace measure="magliozzi fem" in 3
		replace measure="magliozzi masc" in 4
		replace measure="wangnerud fem" in 5
		replace measure="wangnerud masc" in 6
		replace measure="osri fem" in 7
		replace measure="osri masc" in 8
		replace measure="cfni" in 9
		replace measure="cmni" in 10
		replace measure="bsri fem" in 11
		replace measure="bsri masc" in 12
		replace measure="CGI (other)" in 13
		replace measure="CGI (own)" in 14
	gen variable="`v'"
	
	tempfile ``v''
	save `v', replace
restore
}

clear 

foreach v of local variables {
	append using `v'
	erase "`v'.dta"
}


save "$path/1_data/5_meta/4_pval_other/sanitycheck_7other_GI.dta", replace





