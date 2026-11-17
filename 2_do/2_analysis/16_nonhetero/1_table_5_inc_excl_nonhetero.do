clear all

global out_path "$path/3_out" 
		
local tableid "table_5"

* short code to save reg coeffs
do "$path/2_do/2_analysis/0_reg_fnc/0_regressions.do"
do "$path/2_do/2_analysis/0_reg_fnc/0_regressions_1t_+.do"
do "$path/2_do/2_analysis/0_reg_fnc/0_regressions_1t_-.do"

* Create output folders if they don't exist
cap mkdir "$out_path/Tables_nonhetero"

/*
Column mapping (8 cols = 4 outcomes x 2 subsamples):
Col 1/2:  Redistribution - Swiss Uni   - Incl. non-het / Excl. non-het
Col 3/4:  Redistribution - US Adults   - Incl. non-het / Excl. non-het
Col 5/6:  Donation       - Swiss Uni   - Incl. non-het / Excl. non-het
Col 7/8:  Donation       - US Adults   - Incl. non-het / Excl. non-het (Panel A only; phantom in B/C/D)

het==1: incl. non-het (full sample)
het==2: excl. non-het (hetero only)

i loop:
i=1: Redistribution, Swiss Uni
i=2: Redistribution, US Adults
i=3: Donation,       Swiss Uni
i=4: Donation,       US Adults
*/

forvalues z=1/2 {

forvalues i=1/4 {

	* ---- Load data ----
	if `i'==1 | `i'==3 {
		use "$path/1_data/2_prepared/1_SwissUni.dta", clear
		local controls "c.age##c.age educ_control"
	}
	if `i'==2 | `i'==4 {
		use "$path/1_data/2_prepared/1_usadults_w1_w2_30_60.dta", clear
		local controls "c.age##c.age black all_other_races i.division wave1"

		* Restandardize for age 30-60 subsample
		cap drop std_cgi_main
		qui su cgi_main
		qui gen std_cgi_main=(cgi_main-r(mean))/r(sd)

		cap drop std_redistribution
		qui su redistribution
		qui gen std_redistribution=(redistribution-r(mean))/r(sd)

		cap drop std_donation
		qui su donation
		qui gen std_donation=(donation-r(mean))/r(sd)
	}

	* ---- Define het conditions ----
	if `i'==1 | `i'==3 {
		* Swiss Uni
		local hetcond1  "1==1"
		local hetcond2  "sexual_orientation_fo==1"
	}
	if `i'==2 | `i'==4 {
		* US Adults
		local hetcond1  "1==1"
		local hetcond2  "bisexual!=1 & gay!=1 & other_orientation!=1"
	}

	* ---- Define outcome variable ----
	if `i'==1 | `i'==2 {
		local outvar "std_redistribution"
		local rawvar "redistribution"
	}
	if `i'==3 | `i'==4 {
		local outvar "std_donation"
		local rawvar "donation"
	}

forvalues het=1/2 {

	local col = (`i'-1)*2 + `het'
	local hetcond "`hetcond`het''"

	*---------------------------------------------------------------------------
	* Restandardize outcome and CGI within het subsample
	*---------------------------------------------------------------------------
	cap drop std_outcome_het
	qui su `rawvar' if `hetcond'
	qui gen std_outcome_het = (`rawvar' - r(mean))/r(sd)

	cap drop std_cgi_het
	qui su cgi_main if `hetcond' & std_outcome_het!=.
	qui gen std_cgi_het = (cgi_main - r(mean))/r(sd)

	* Sanity checks
	qui su std_outcome_het if `hetcond'
	assert round(r(mean),0.0001)==0

	qui su std_cgi_het if `hetcond' & std_outcome_het!=.
	assert round(r(mean),0.0001)==0

	*---------------------------------------------------------------------------
	* Panel A: biological gender
	*---------------------------------------------------------------------------
	if `z'==1 {
		qui reg std_outcome_het female if `hetcond', vce(hc3)
	}
	if `z'==2 {
		qui reg std_outcome_het female `controls' if `hetcond', vce(hc3)
	}

	beta_coeff2 female
	local beta_a_sex_`col' `r(beta)'
	local se_a_sex_`col'   `r(se)'
	local rsqua_`col': di %6.3f `e(r2)'
	local rsqua_`col' = trim("$`rsqua_`col''$")
	local sign_female = sign(_b[female])

	*---------------------------------------------------------------------------
	* Panel B: CGI
	*---------------------------------------------------------------------------
	if `z'==1 {
		qui reg std_outcome_het std_cgi_het if `hetcond', vce(hc3)
	}
	if `z'==2 {
		qui reg std_outcome_het std_cgi_het `controls' if `hetcond', vce(hc3)
	}

	local rsqub_`col': di %6.3f e(r2)
	local rsqub_`col' = trim("$`rsqub_`col''$")

	if `sign_female'>0 {
		beta_coeff1_pos std_cgi_het
		local beta_b_cgi_`col' `r(beta)'
		local se_b_cgi_`col'   `r(se)'
	}
	if `sign_female'<0 {
		beta_coeff1_neg std_cgi_het
		local beta_b_cgi_`col' `r(beta)'
		local se_b_cgi_`col'   `r(se)'
	}

	*---------------------------------------------------------------------------
	* Panel C: biological gender and CGI
	*---------------------------------------------------------------------------
	if `z'==1 {
		qui reg std_outcome_het female std_cgi_het if `hetcond', vce(hc3)
	}
	if `z'==2 {
		qui reg std_outcome_het female std_cgi_het `controls' if `hetcond', vce(hc3)
	}

	local N_`col': di %11.0gc e(N)
	local rsquc_`col': di %6.3f e(r2)
	local rsquc_`col' = trim("$`rsquc_`col''$")

	if `sign_female'>0 {
		beta_coeff1_pos female
		local beta_c_sex_`col' `r(beta)'
		local se_c_sex_`col'   `r(se)'
		beta_coeff1_pos std_cgi_het
		local beta_c_cgi_`col' `r(beta)'
		local se_c_cgi_`col'   `r(se)'
	}
	if `sign_female'<0 {
		beta_coeff1_neg female
		local beta_c_sex_`col' `r(beta)'
		local se_c_sex_`col'   `r(se)'
		beta_coeff1_neg std_cgi_het
		local beta_c_cgi_`col' `r(beta)'
		local se_c_cgi_`col'   `r(se)'
	}

	*---------------------------------------------------------------------------
	* Panel D: sample split by binary gender
	*---------------------------------------------------------------------------
	* Females
	preserve
	keep if female==1 & (`hetcond')

	cap drop std_outcome_het
	qui su `rawvar'
	qui gen std_outcome_het = (`rawvar' - r(mean))/r(sd)
	qui su std_outcome_het
	assert round(r(mean),0.0001)==0

	cap drop std_cgi_het
	qui su cgi_main if std_outcome_het!=.
	qui gen std_cgi_het = (cgi_main - r(mean))/r(sd)
	qui su std_cgi_het if std_outcome_het!=.
	assert round(r(mean),0.0001)==0

	if `z'==1 {
		qui reg std_outcome_het std_cgi_het, vce(hc3)
	}
	if `z'==2 {
		qui reg std_outcome_het std_cgi_het `controls', vce(hc3)
	}

	local rsquf_`col': di %6.3f `e(r2)'
	local rsquf_`col' = trim("$`rsquf_`col''$")

	if `sign_female'>0 {
		beta_coeff1_pos std_cgi_het
		local beta_f_cgi_`col' `r(beta)'
		local se_f_cgi_`col'   `r(se)'
	}
	if `sign_female'<0 {
		beta_coeff1_neg std_cgi_het
		local beta_f_cgi_`col' `r(beta)'
		local se_f_cgi_`col'   `r(se)'
	}
	restore

	* Males
	preserve
	keep if female==0 & (`hetcond')

	cap drop std_outcome_het
	qui su `rawvar'
	qui gen std_outcome_het = (`rawvar' - r(mean))/r(sd)
	qui su std_outcome_het
	assert round(r(mean),0.0001)==0

	cap drop std_cgi_het
	qui su cgi_main if std_outcome_het!=.
	qui gen std_cgi_het = (cgi_main - r(mean))/r(sd)
	qui su std_cgi_het if std_outcome_het!=.
	assert round(r(mean),0.0001)==0

	if `z'==1 {
		qui reg std_outcome_het std_cgi_het, vce(hc3)
	}
	if `z'==2 {
		qui reg std_outcome_het std_cgi_het `controls', vce(hc3)
	}

	local rsqum_`col': di %6.3f e(r2)
	local rsqum_`col' = trim("$`rsqum_`col''$")

	if `sign_female'>0 {
		beta_coeff1_pos std_cgi_het
		local beta_m_cgi_`col' `r(beta)'
		local se_m_cgi_`col'   `r(se)'
	}
	if `sign_female'<0 {
		beta_coeff1_neg std_cgi_het
		local beta_m_cgi_`col' `r(beta)'
		local se_m_cgi_`col'   `r(se)'
	}
	restore

	*---------------------------------------------------------------------------
	* Panel D: suest coefficient equality test
	*---------------------------------------------------------------------------
	if `z'==1 {
		qui reg std_outcome_het std_cgi_het if female==1 & (`hetcond')
	}
	if `z'==2 {
		qui reg std_outcome_het std_cgi_het `controls' if female==1 & (`hetcond')
	}
	est store female_`col'

	if `z'==1 {
		qui reg std_outcome_het std_cgi_het if female==0 & (`hetcond')
	}
	if `z'==2 {
		qui reg std_outcome_het std_cgi_het `controls' if female==0 & (`hetcond')
	}
	est store male_`col'

	suest female_`col' male_`col', vce(robust)
	lincom _b[female_`col'_mean:std_cgi_het] - _b[male_`col'_mean:std_cgi_het]
	local panelD_test_`col': di %6.3f r(p)
	local panelD_test_`col' = trim("$`panelD_test_`col''$")

	*---------------------------------------------------------------------------
	* Mean of dependent variable
	*---------------------------------------------------------------------------
	qui su std_outcome_het if `hetcond'
	local mean_`col': di %6.0f round(r(mean),1)

} // end het loop
} // end i loop

*-----------------------------------------------------------------------------
* Write the Results
*-----------------------------------------------------------------------------

foreach filepath in `"$out_path/Tables_nonhetero/`tableid'.tex"'{

	if `z'==1  file open resultsfile using `"`filepath'"', write replace
	if `z'==2 {
		local fp_ctrl = subinstr(`"`filepath'"', ".tex", "_controls.tex", .)
		file open resultsfile using `"`fp_ctrl'"', write replace
	}

	* Header
	if `z'==1 {
		file write resultsfile "\caption{CGI and Unincentivized Distributional Preferences by Sexual Orientation}"
		file write resultsfile "\label{table 5 nonhetero}"
	}
	if `z'==2 {
		file write resultsfile "\caption{CGI and Unincentivized Distributional Preferences by Sexual Orientation (with controls)}"
	}
	file write resultsfile "\centering"
	file write resultsfile "\begin{tabular}{p{2cm} M{1.6cm} M{1.6cm} M{1.6cm} M{1.6cm} M{1.6cm} M{1.6cm} M{1.6cm} M{1.6cm}}"
	file write resultsfile "\toprule \toprule"
	file write resultsfile "\addlinespace[0.2cm]"
	file write resultsfile "\multicolumn{1}{l}{Measure} & \multicolumn{4}{c}{Redistribution} & \multicolumn{4}{c}{Donation} \\"
	file write resultsfile "\cmidrule(lr){2-5} \cmidrule(lr){6-9}"
	file write resultsfile "\multicolumn{1}{l}{Sample} & \multicolumn{2}{c}{Swiss Uni} & \multicolumn{2}{c}{U.S. Adults} & \multicolumn{2}{c}{Swiss Uni} & \multicolumn{2}{c}{U.S. Adults} \\"
	file write resultsfile "\cmidrule(lr){2-3} \cmidrule(lr){4-5} \cmidrule(lr){6-7} \cmidrule(lr){8-9}"
	file write resultsfile "& Incl. non-het & Excl. non-het & Incl. non-het & Excl. non-het & Incl. non-het & Excl. non-het & Incl. non-het & Excl. non-het \\"
	file write resultsfile "& (1) & (2) & (3) & (4) & (5) & (6) & (7) & (8) \\"
	file write resultsfile "\midrule"
	file write resultsfile "\addlinespace[0.2cm]"

	* Panel A
	file write resultsfile "\multicolumn{9}{l}{\textbf{Panel A. Binary gender}} \\" _n
	file write resultsfile " \multicolumn{1}{l}{Female} & $`beta_a_sex_1'$ & $`beta_a_sex_2'$ & $`beta_a_sex_3'$ & $`beta_a_sex_4'$ & $`beta_a_sex_5'$ & $`beta_a_sex_6'$ & $`beta_a_sex_7'$ & $`beta_a_sex_8'$ \\" _n
	file write resultsfile " & (`se_a_sex_1') & (`se_a_sex_2') & (`se_a_sex_3') & (`se_a_sex_4') & (`se_a_sex_5') & (`se_a_sex_6') & (`se_a_sex_7') & (`se_a_sex_8') \\" _n
	file write resultsfile "\addlinespace[0.1cm]"
	file write resultsfile " \multicolumn{1}{l}{\$\text{R}^2\$} & `rsqua_1' & `rsqua_2' & `rsqua_3' & `rsqua_4' & `rsqua_5' & `rsqua_6' & `rsqua_7' & `rsqua_8' \\ \\" _n
	file write resultsfile "\addlinespace[-0.3cm]"
	file write resultsfile "\midrule"

	* Panel B
	file write resultsfile "\multicolumn{9}{l}{\textbf{Panel B. Gender identity}} \\" _n
	file write resultsfile " \multicolumn{1}{l}{CGI (feminine)} & $`beta_b_cgi_1'$ & $`beta_b_cgi_2'$ & $`beta_b_cgi_3'$ & $`beta_b_cgi_4'$ & $`beta_b_cgi_5'$ & $`beta_b_cgi_6'$ & \phantom{$`beta_b_cgi_7'$} & \phantom{$`beta_b_cgi_8'$} \\" _n
	file write resultsfile " & (`se_b_cgi_1') & (`se_b_cgi_2') & (`se_b_cgi_3') & (`se_b_cgi_4') & (`se_b_cgi_5') & (`se_b_cgi_6') & \phantom{(`se_b_cgi_7')} & \phantom{(`se_b_cgi_8')} \\" _n
	file write resultsfile "\addlinespace[0.1cm]"
	file write resultsfile " \multicolumn{1}{l}{\$\text{R}^2\$} & `rsqub_1' & `rsqub_2' & `rsqub_3' & `rsqub_4' & `rsqub_5' & `rsqub_6' & \phantom{`rsqub_7'} & \phantom{`rsqub_8'} \\ \\" _n
	file write resultsfile "\addlinespace[-0.3cm]"
	file write resultsfile "\midrule"

	* Panel C
	file write resultsfile "\multicolumn{9}{l}{\textbf{Panel C. Binary gender and gender identity}} \\" _n
	file write resultsfile " \multicolumn{1}{l}{Female} & $`beta_c_sex_1'$ & $`beta_c_sex_2'$ & $`beta_c_sex_3'$ & $`beta_c_sex_4'$ & $`beta_c_sex_5'$ & $`beta_c_sex_6'$ & \phantom{$`beta_c_sex_7'$} & \phantom{$`beta_c_sex_8'$} \\" _n
	file write resultsfile " & (`se_c_sex_1') & (`se_c_sex_2') & (`se_c_sex_3') & (`se_c_sex_4') & (`se_c_sex_5') & (`se_c_sex_6') & \phantom{(`se_c_sex_7')} & \phantom{(`se_c_sex_8')} \\ \\" _n
	file write resultsfile "\addlinespace[-0.3cm]"
	file write resultsfile " \multicolumn{1}{l}{CGI (feminine)} & $`beta_c_cgi_1'$ & $`beta_c_cgi_2'$ & $`beta_c_cgi_3'$ & $`beta_c_cgi_4'$ & $`beta_c_cgi_5'$ & $`beta_c_cgi_6'$ & \phantom{$`beta_c_cgi_7'$} & \phantom{$`beta_c_cgi_8'$} \\" _n
	file write resultsfile " & (`se_c_cgi_1') & (`se_c_cgi_2') & (`se_c_cgi_3') & (`se_c_cgi_4') & (`se_c_cgi_5') & (`se_c_cgi_6') & \phantom{(`se_c_cgi_7')} & \phantom{(`se_c_cgi_8')} \\" _n
	file write resultsfile "\addlinespace[0.1cm]"
	file write resultsfile " \multicolumn{1}{l}{\$\text{R}^2\$} & `rsquc_1' & `rsquc_2' & `rsquc_3' & `rsquc_4' & `rsquc_5' & `rsquc_6' & \phantom{`rsquc_7'} & \phantom{`rsquc_8'} \\ \\" _n
	file write resultsfile "\addlinespace[-0.3cm]"
	file write resultsfile "\midrule"

	* Panel D
	file write resultsfile "\multicolumn{9}{l}{\textbf{Panel D. Sample split by binary gender}} \\" _n
	file write resultsfile " \multicolumn{1}{l}{Female: CGI (feminine)} & $`beta_f_cgi_1'$ & $`beta_f_cgi_2'$ & $`beta_f_cgi_3'$ & $`beta_f_cgi_4'$ & $`beta_f_cgi_5'$ & $`beta_f_cgi_6'$ & \phantom{$`beta_f_cgi_7'$} & \phantom{$`beta_f_cgi_8'$} \\" _n
	file write resultsfile " & (`se_f_cgi_1') & (`se_f_cgi_2') & (`se_f_cgi_3') & (`se_f_cgi_4') & (`se_f_cgi_5') & (`se_f_cgi_6') & \phantom{(`se_f_cgi_7')} & \phantom{(`se_f_cgi_8')} \\" _n
	file write resultsfile "\addlinespace[0.1cm]"
	file write resultsfile " \multicolumn{1}{l}{\$\text{R}^2\$} & `rsquf_1' & `rsquf_2' & `rsquf_3' & `rsquf_4' & `rsquf_5' & `rsquf_6' & \phantom{`rsquf_7'} & \phantom{`rsquf_8'} \\ \\" _n
	file write resultsfile "\addlinespace[-0.3cm]"
	file write resultsfile " \multicolumn{1}{l}{Male: CGI (feminine)} & $`beta_m_cgi_1'$ & $`beta_m_cgi_2'$ & $`beta_m_cgi_3'$ & $`beta_m_cgi_4'$ & $`beta_m_cgi_5'$ & $`beta_m_cgi_6'$ & \phantom{$`beta_m_cgi_7'$} & \phantom{$`beta_m_cgi_8'$} \\" _n
	file write resultsfile " & (`se_m_cgi_1') & (`se_m_cgi_2') & (`se_m_cgi_3') & (`se_m_cgi_4') & (`se_m_cgi_5') & (`se_m_cgi_6') & \phantom{(`se_m_cgi_7')} & \phantom{(`se_m_cgi_8')} \\" _n
	file write resultsfile "\addlinespace[0.1cm]"
	file write resultsfile " \multicolumn{1}{l}{\$\text{R}^2\$} & `rsqum_1' & `rsqum_2' & `rsqum_3' & `rsqum_4' & `rsqum_5' & `rsqum_6' & \phantom{`rsqum_7'} & \phantom{`rsqum_8'} \\ \\" _n
	file write resultsfile "\addlinespace[-0.3cm]"
	file write resultsfile "\multicolumn{9}{l}{Test: male sample split CGI = female sample split CGI} \\" _n
	file write resultsfile "\addlinespace[-0.6cm]"
	file write resultsfile " \multicolumn{1}{l}{p-value} & $`panelD_test_1'$ & $`panelD_test_2'$ & $`panelD_test_3'$ & $`panelD_test_4'$ & $`panelD_test_5'$ & $`panelD_test_6'$ & \phantom{$`panelD_test_7'$} & \phantom{$`panelD_test_8'$} \\" _n
	file write resultsfile "\addlinespace[-0.5cm]"
	file write resultsfile "\midrule"

	* Observations
	file write resultsfile " \multicolumn{1}{l}{Observations} & `N_1' & `N_2' & `N_3' & `N_4' & `N_5' & `N_6' & `N_7' & `N_8' \\ \\" _n
	file write resultsfile "\addlinespace[-0.3cm]"

	* Mean of DV
	file write resultsfile "\multicolumn{1}{l}{Mean of Dependent Variable} & `mean_1' & `mean_2' & `mean_3' & `mean_4' & `mean_5' & `mean_6' & `mean_7' & `mean_8' \\ \\" _n
	file write resultsfile "\addlinespace[-0.3cm]"

	* Footer
	file write resultsfile "\bottomrule\bottomrule"
	file write resultsfile "\end{tabular}"
	file close resultsfile

} // end foreach filepath

} // end z loop
