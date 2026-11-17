clear all

global out_path "$path/3_out"
		
local tableid "table_6b"

do "$path/2_do/2_analysis/0_reg_fnc/0_regressions.do"
do "$path/2_do/2_analysis/0_reg_fnc/0_regressions_1t_+.do"
do "$path/2_do/2_analysis/0_reg_fnc/0_regressions_1t_-.do"

cap mkdir "$out_path/Tables_nonhetero"

/*
Column mapping (10 cols = 5 outcomes x 2 subsamples), all US Adults:
i=1: major_share         (not standardized)
i=2: income_cont         (not standardized)
i=3: homemaker           (binary)
i=4: yearly_work_hours_weeklyaverage (not standardized)
i=5: industry_share      (not standardized)

Col 1/2:  Female Educ Share     - Incl. non-het / Excl. non-het
Col 3/4:  Income                - Incl. non-het / Excl. non-het
Col 5/6:  Full-time Homemaker   - Incl. non-het / Excl. non-het
Col 7/8:  Weekly Work Hours     - Incl. non-het / Excl. non-het
Col 9/10: Female Industry Share - Incl. non-het / Excl. non-het

het==1: incl. non-het (full sample)
het==2: excl. non-het (hetero only)
*/

* het conditions (US Adults)
local hetcond1 "1==1"
local hetcond2 "bisexual!=1 & gay!=1 & other_orientation!=1"

* outcome variables (not standardized; CGI restandardized within hetcond)
local varlist "major_share income_cont homemaker yearly_work_hours_weeklyaverage industry_share"

forvalues z=1/2 {

local i = 1
foreach var of local varlist {

	use "$path/1_data/2_prepared/1_usadults_w1_w2_30_60.dta", clear
	local controls "c.age##c.age black all_other_races i.division wave1"

	* Restandardize CGI for 30-60 subsample
	cap drop std_cgi_main
	qui su cgi_main
	qui gen std_cgi_main=(cgi_main-r(mean))/r(sd)

	* Restandardize CGI to outcome sample
	qui su std_cgi_main if `var'!=.
	if round(r(mean),0.0001)!=0 {
		cap drop std_cgi_main
		qui su cgi_main if `var'!=.
		qui gen std_cgi_main=(cgi_main-r(mean))/r(sd)
	}

forvalues het=1/2 {

	local col = (`i'-1)*2 + `het'
	local hetcond "`hetcond`het''"

	*---------------------------------------------------------------------------
	* Restandardize CGI within het subsample
	* (outcomes not standardized, no outcome restandardization needed)
	*---------------------------------------------------------------------------
	cap drop std_cgi_het
	qui su cgi_main if `hetcond' & `var'!=.
	qui gen std_cgi_het = (cgi_main - r(mean))/r(sd)

	qui su std_cgi_het if `hetcond' & `var'!=.
	assert round(r(mean),0.0001)==0

	*---------------------------------------------------------------------------
	* Panel A
	*---------------------------------------------------------------------------
	if `z'==1 {
		qui reg `var' female if `hetcond', vce(hc3)
	}
	if `z'==2 {
		qui reg `var' female `controls' if `hetcond', vce(hc3)
	}

	beta_coeff2 female
	local beta_a_sex_`col' `r(beta)'
	local se_a_sex_`col'   `r(se)'
	local rsqua_`col': di %6.3f `e(r2)'
	local rsqua_`col' = trim("$`rsqua_`col''$")
	local sign_female = sign(_b[female])

	*---------------------------------------------------------------------------
	* Panel B
	*---------------------------------------------------------------------------
	if `z'==1 {
		qui reg `var' std_cgi_het if `hetcond', vce(hc3)
	}
	if `z'==2 {
		qui reg `var' std_cgi_het `controls' if `hetcond', vce(hc3)
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
	* Panel C
	*---------------------------------------------------------------------------
	if `z'==1 {
		qui reg `var' female std_cgi_het if `hetcond', vce(hc3)
	}
	if `z'==2 {
		qui reg `var' female std_cgi_het `controls' if `hetcond', vce(hc3)
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
	* Panel D: females
	*---------------------------------------------------------------------------
	preserve
	keep if female==1 & (`hetcond')

	cap drop std_cgi_het
	qui su cgi_main if `var'!=.
	qui gen std_cgi_het = (cgi_main - r(mean))/r(sd)
	qui su std_cgi_het if `var'!=.
	assert round(r(mean),0.0001)==0

	if `z'==1 {
		qui reg `var' std_cgi_het, vce(hc3)
	}
	if `z'==2 {
		qui reg `var' std_cgi_het `controls', vce(hc3)
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

	*---------------------------------------------------------------------------
	* Panel D: males
	*---------------------------------------------------------------------------
	preserve
	keep if female==0 & (`hetcond')

	cap drop std_cgi_het
	qui su cgi_main if `var'!=.
	qui gen std_cgi_het = (cgi_main - r(mean))/r(sd)
	qui su std_cgi_het if `var'!=.
	assert round(r(mean),0.0001)==0

	if `z'==1 {
		qui reg `var' std_cgi_het, vce(hc3)
	}
	if `z'==2 {
		qui reg `var' std_cgi_het `controls', vce(hc3)
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
	* suest equality test
	*---------------------------------------------------------------------------
	if `z'==1 {
		qui reg `var' std_cgi_het if female==1 & (`hetcond')
	}
	if `z'==2 {
		qui reg `var' std_cgi_het `controls' if female==1 & (`hetcond')
	}
	est store female_`col'

	if `z'==1 {
		qui reg `var' std_cgi_het if female==0 & (`hetcond')
	}
	if `z'==2 {
		qui reg `var' std_cgi_het `controls' if female==0 & (`hetcond')
	}
	est store male_`col'

	suest female_`col' male_`col', vce(robust)
	lincom _b[female_`col'_mean:std_cgi_het] - _b[male_`col'_mean:std_cgi_het]
	local panelD_test_`col': di %6.3f r(p)
	local panelD_test_`col' = trim("$`panelD_test_`col''$")

	*---------------------------------------------------------------------------
	* Mean of DV
	*---------------------------------------------------------------------------
	qui su `var' if `hetcond'
	local mean_`col': di %6.3f r(mean)
	if round(r(mean),0.0001)==0 {
		local mean_`col': di %6.0f round(r(mean))
	}

} // end het loop

local i = `i' + 1
} // end var loop

*-----------------------------------------------------------------------------
* Write Results
*-----------------------------------------------------------------------------

foreach filepath in `"$out_path/Tables_nonhetero/`tableid'.tex"' {

	if `z'==1  file open resultsfile using `"`filepath'"', write replace
	if `z'==2 {
		local fp_ctrl = subinstr(`"`filepath'"', ".tex", "_controls.tex", .)
		file open resultsfile using `"`fp_ctrl'"', write replace
	}

	if `z'==1 {
		file write resultsfile "\caption{CGI, Educational Choice and Labor Market Outcomes by Sexual Orientation}"
		file write resultsfile "\label{table 6b nonhetero}"
	}
	if `z'==2 {
		file write resultsfile "\caption{CGI, Educational Choice and Labor Market Outcomes by Sexual Orientation (with controls)}"
	}
	file write resultsfile "\centering"
file write resultsfile "\begin{tabular}{p{2cm} M{1.6cm} M{1.6cm} M{1.6cm} M{1.6cm} M{1.6cm} M{1.6cm} M{1.6cm} M{1.6cm} M{1.6cm} M{1.6cm}}"
file write resultsfile "\toprule \toprule"
file write resultsfile "\addlinespace[0.2cm]"
file write resultsfile "\multicolumn{1}{l}{Measure} & \multicolumn{2}{c}{Female Educ. Share} & \multicolumn{2}{c}{Income} & \multicolumn{2}{c}{Full-time Homemaker} & \multicolumn{2}{c}{Weekly Work Hours} & \multicolumn{2}{c}{Female Industry Share} \\"
file write resultsfile "\cmidrule(lr){2-3} \cmidrule(lr){4-5} \cmidrule(lr){6-7} \cmidrule(lr){8-9} \cmidrule(lr){10-11}"
file write resultsfile "& Incl. non-het & Excl. non-het & Incl. non-het & Excl. non-het & Incl. non-het & Excl. non-het & Incl. non-het & Excl. non-het & Incl. non-het & Excl. non-het \\"
file write resultsfile "& (1) & (2) & (3) & (4) & (5) & (6) & (7) & (8) & (9) & (10) \\"
file write resultsfile "\midrule"
file write resultsfile "\addlinespace[0.2cm]"

	* Panel A
	file write resultsfile "\multicolumn{11}{l}{\textbf{Panel A. Binary gender}} \\" _n
	file write resultsfile " \multicolumn{1}{l}{Female} & $`beta_a_sex_1'$ & $`beta_a_sex_2'$ & $`beta_a_sex_3'$ & $`beta_a_sex_4'$ & $`beta_a_sex_5'$ & $`beta_a_sex_6'$ & $`beta_a_sex_7'$ & $`beta_a_sex_8'$ & $`beta_a_sex_9'$ & $`beta_a_sex_10'$ \\" _n
	file write resultsfile " & (`se_a_sex_1') & (`se_a_sex_2') & (`se_a_sex_3') & (`se_a_sex_4') & (`se_a_sex_5') & (`se_a_sex_6') & (`se_a_sex_7') & (`se_a_sex_8') & (`se_a_sex_9') & (`se_a_sex_10') \\" _n
	file write resultsfile "\addlinespace[0.1cm]"
	file write resultsfile " \multicolumn{1}{l}{\$\text{R}^2\$} & `rsqua_1' & `rsqua_2' & `rsqua_3' & `rsqua_4' & `rsqua_5' & `rsqua_6' & `rsqua_7' & `rsqua_8' & `rsqua_9' & `rsqua_10' \\ \\" _n
	file write resultsfile "\addlinespace[-0.3cm]"
	file write resultsfile "\midrule"

	* Panel B
	file write resultsfile "\multicolumn{11}{l}{\textbf{Panel B. Gender identity}} \\" _n
	file write resultsfile " \multicolumn{1}{l}{CGI (feminine)} & $`beta_b_cgi_1'$ & $`beta_b_cgi_2'$ & $`beta_b_cgi_3'$ & $`beta_b_cgi_4'$ & $`beta_b_cgi_5'$ & $`beta_b_cgi_6'$ & $`beta_b_cgi_7'$ & $`beta_b_cgi_8'$ & $`beta_b_cgi_9'$ & $`beta_b_cgi_10'$ \\" _n
	file write resultsfile " & (`se_b_cgi_1') & (`se_b_cgi_2') & (`se_b_cgi_3') & (`se_b_cgi_4') & (`se_b_cgi_5') & (`se_b_cgi_6') & (`se_b_cgi_7') & (`se_b_cgi_8') & (`se_b_cgi_9') & (`se_b_cgi_10') \\" _n
	file write resultsfile "\addlinespace[0.1cm]"
	file write resultsfile " \multicolumn{1}{l}{\$\text{R}^2\$} & `rsqub_1' & `rsqub_2' & `rsqub_3' & `rsqub_4' & `rsqub_5' & `rsqub_6' & `rsqub_7' & `rsqub_8' & `rsqub_9' & `rsqub_10' \\ \\" _n
	file write resultsfile "\addlinespace[-0.3cm]"
	file write resultsfile "\midrule"

	* Panel C
	file write resultsfile "\multicolumn{11}{l}{\textbf{Panel C. Binary gender and gender identity}} \\" _n
	file write resultsfile " \multicolumn{1}{l}{Female} & $`beta_c_sex_1'$ & $`beta_c_sex_2'$ & $`beta_c_sex_3'$ & $`beta_c_sex_4'$ & $`beta_c_sex_5'$ & $`beta_c_sex_6'$ & $`beta_c_sex_7'$ & $`beta_c_sex_8'$ & $`beta_c_sex_9'$ & $`beta_c_sex_10'$ \\" _n
	file write resultsfile " & (`se_c_sex_1') & (`se_c_sex_2') & (`se_c_sex_3') & (`se_c_sex_4') & (`se_c_sex_5') & (`se_c_sex_6') & (`se_c_sex_7') & (`se_c_sex_8') & (`se_c_sex_9') & (`se_c_sex_10') \\ \\" _n
	file write resultsfile "\addlinespace[-0.3cm]"
	file write resultsfile " \multicolumn{1}{l}{CGI (feminine)} & $`beta_c_cgi_1'$ & $`beta_c_cgi_2'$ & $`beta_c_cgi_3'$ & $`beta_c_cgi_4'$ & $`beta_c_cgi_5'$ & $`beta_c_cgi_6'$ & $`beta_c_cgi_7'$ & $`beta_c_cgi_8'$ & $`beta_c_cgi_9'$ & $`beta_c_cgi_10'$ \\" _n
	file write resultsfile " & (`se_c_cgi_1') & (`se_c_cgi_2') & (`se_c_cgi_3') & (`se_c_cgi_4') & (`se_c_cgi_5') & (`se_c_cgi_6') & (`se_c_cgi_7') & (`se_c_cgi_8') & (`se_c_cgi_9') & (`se_c_cgi_10') \\" _n
	file write resultsfile "\addlinespace[0.1cm]"
	file write resultsfile " \multicolumn{1}{l}{\$\text{R}^2\$} & `rsquc_1' & `rsquc_2' & `rsquc_3' & `rsquc_4' & `rsquc_5' & `rsquc_6' & `rsquc_7' & `rsquc_8' & `rsquc_9' & `rsquc_10' \\ \\" _n
	file write resultsfile "\addlinespace[-0.3cm]"
	file write resultsfile "\midrule"

	* Panel D
	file write resultsfile "\multicolumn{11}{l}{\textbf{Panel D. Sample split by binary gender}} \\" _n
	file write resultsfile " \multicolumn{1}{l}{Female: CGI (feminine)} & $`beta_f_cgi_1'$ & $`beta_f_cgi_2'$ & $`beta_f_cgi_3'$ & $`beta_f_cgi_4'$ & $`beta_f_cgi_5'$ & $`beta_f_cgi_6'$ & $`beta_f_cgi_7'$ & $`beta_f_cgi_8'$ & $`beta_f_cgi_9'$ & $`beta_f_cgi_10'$ \\" _n
	file write resultsfile " & (`se_f_cgi_1') & (`se_f_cgi_2') & (`se_f_cgi_3') & (`se_f_cgi_4') & (`se_f_cgi_5') & (`se_f_cgi_6') & (`se_f_cgi_7') & (`se_f_cgi_8') & (`se_f_cgi_9') & (`se_f_cgi_10') \\" _n
	file write resultsfile "\addlinespace[0.1cm]"
	file write resultsfile " \multicolumn{1}{l}{\$\text{R}^2\$} & `rsquf_1' & `rsquf_2' & `rsquf_3' & `rsquf_4' & `rsquf_5' & `rsquf_6' & `rsquf_7' & `rsquf_8' & `rsquf_9' & `rsquf_10' \\ \\" _n
	file write resultsfile "\addlinespace[-0.3cm]"
	file write resultsfile " \multicolumn{1}{l}{Male: CGI (feminine)} & $`beta_m_cgi_1'$ & $`beta_m_cgi_2'$ & $`beta_m_cgi_3'$ & $`beta_m_cgi_4'$ & $`beta_m_cgi_5'$ & $`beta_m_cgi_6'$ & $`beta_m_cgi_7'$ & $`beta_m_cgi_8'$ & $`beta_m_cgi_9'$ & $`beta_m_cgi_10'$ \\" _n
	file write resultsfile " & (`se_m_cgi_1') & (`se_m_cgi_2') & (`se_m_cgi_3') & (`se_m_cgi_4') & (`se_m_cgi_5') & (`se_m_cgi_6') & (`se_m_cgi_7') & (`se_m_cgi_8') & (`se_m_cgi_9') & (`se_m_cgi_10') \\" _n
	file write resultsfile "\addlinespace[0.1cm]"
	file write resultsfile " \multicolumn{1}{l}{\$\text{R}^2\$} & `rsqum_1' & `rsqum_2' & `rsqum_3' & `rsqum_4' & `rsqum_5' & `rsqum_6' & `rsqum_7' & `rsqum_8' & `rsqum_9' & `rsqum_10' \\ \\" _n
	file write resultsfile "\addlinespace[-0.3cm]"
	file write resultsfile "\multicolumn{11}{l}{Test: male sample split CGI = female sample split CGI} \\" _n
	file write resultsfile "\addlinespace[-0.6cm]"
	file write resultsfile " \multicolumn{1}{l}{p-value} & $`panelD_test_1'$ & $`panelD_test_2'$ & $`panelD_test_3'$ & $`panelD_test_4'$ & $`panelD_test_5'$ & $`panelD_test_6'$ & $`panelD_test_7'$ & $`panelD_test_8'$ & $`panelD_test_9'$ & $`panelD_test_10'$ \\" _n
	file write resultsfile "\addlinespace[-0.5cm]"
	file write resultsfile "\midrule"

	* Observations
	file write resultsfile " \multicolumn{1}{l}{Observations} & `N_1' & `N_2' & `N_3' & `N_4' & `N_5' & `N_6' & `N_7' & `N_8' & `N_9' & `N_10' \\ \\" _n
	file write resultsfile "\addlinespace[-0.3cm]"

	* Mean of DV
	file write resultsfile "\multicolumn{1}{l}{Mean of Dependent Variable} & `mean_1' & `mean_2' & `mean_3' & `mean_4' & `mean_5' & `mean_6' & `mean_7' & `mean_8' & `mean_9' & `mean_10' \\ \\" _n
	file write resultsfile "\addlinespace[-0.3cm]"

	file write resultsfile "\bottomrule\bottomrule"
	file write resultsfile "\end{tabular}"
	file close resultsfile

} // end foreach filepath

} // end z loop
