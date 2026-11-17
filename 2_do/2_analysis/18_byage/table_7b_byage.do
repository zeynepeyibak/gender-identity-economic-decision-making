clear all

global out_path "$path/3_out" 
		
local tableid "table_7b_byage"

do "$path/2_do/2_analysis/0_reg_fnc/0_regressions.do"
do "$path/2_do/2_analysis/0_reg_fnc/0_regressions_1t_+.do"
do "$path/2_do/2_analysis/0_reg_fnc/0_regressions_1t_-.do"

cap mkdir "$out_path/US_age_tables"

local age_lo "30 40 50"
local age_hi "39 49 60"

* std_work_hours is built on the fly from work_hours within each age cell
local varlist "perf_pay_yes negot_yes std_work_hours"

forvalues z = 1/2 {

  local outcome_idx = 1
  foreach var of local varlist {

    forvalues k = 1/3 {

      local col    = (`outcome_idx' - 1) * 3 + `k'
      local agemin : word `k' of `age_lo'
      local agemax : word `k' of `age_hi'
      local agecond "age >= `agemin' & age <= `agemax'"

      use "$path/1_data/2_prepared/1_usadults_w1_w2_30_60.dta", clear
      local controls "c.age##c.age black all_other_races i.division wave1"

      *--- For work flexibility: standardize outcome within age cell ---
      if "`var'" == "std_work_hours" {
        cap drop std_work_hours
        qui su work_hours if `agecond'
        qui gen std_work_hours = (work_hours - r(mean)) / r(sd)
        qui su std_work_hours if `agecond'
        if r(N) > 0 {
            assert round(r(mean), 0.0001) == 0
        }
        local regvar "std_work_hours"
      }
      else {
        local regvar "`var'"
      }

      *--- CGI standardized within age × outcome sample ---
      cap drop std_cgi_age
      qui su cgi_main if `agecond' & `regvar' != .
      qui gen std_cgi_age = (cgi_main - r(mean)) / r(sd)
      qui su std_cgi_age if `agecond' & `regvar' != .
      if r(N) > 0 {
          assert round(r(mean), 0.0001) == 0
      }

      *--- Panel A ---
      if `z'==1 qui reg `regvar' female if `agecond', vce(hc3)
      if `z'==2 qui reg `regvar' female `controls' if `agecond', vce(hc3)

      beta_coeff2 female
      local beta_a_sex_`col' `r(beta)'
      local se_a_sex_`col'   `r(se)'
      local rsqua_`col': di %6.3f e(r2)
      local rsqua_`col' = trim("$`rsqua_`col''$")
      local sign_female = sign(_b[female])

      *--- Panel B ---
      if `z'==1 qui reg `regvar' std_cgi_age if `agecond', vce(hc3)
      if `z'==2 qui reg `regvar' std_cgi_age `controls' if `agecond', vce(hc3)

      local rsqub_`col': di %6.3f e(r2)
      local rsqub_`col' = trim("$`rsqub_`col''$")
      if `sign_female' > 0 {
        beta_coeff1_pos std_cgi_age
        local beta_b_cgi_`col' `r(beta)'
        local se_b_cgi_`col'   `r(se)'
      }
      if `sign_female' < 0 {
        beta_coeff1_neg std_cgi_age
        local beta_b_cgi_`col' `r(beta)'
        local se_b_cgi_`col'   `r(se)'
      }

      *--- Panel C ---
      if `z'==1 qui reg `regvar' female std_cgi_age if `agecond', vce(hc3)
      if `z'==2 qui reg `regvar' female std_cgi_age `controls' if `agecond', vce(hc3)

      local N_`col': di %11.0gc e(N)
      local rsquc_`col': di %6.3f e(r2)
      local rsquc_`col' = trim("$`rsquc_`col''$")
      if `sign_female' > 0 {
        beta_coeff1_pos female
        local beta_c_sex_`col' `r(beta)'
        local se_c_sex_`col'   `r(se)'
        beta_coeff1_pos std_cgi_age
        local beta_c_cgi_`col' `r(beta)'
        local se_c_cgi_`col'   `r(se)'
      }
      if `sign_female' < 0 {
        beta_coeff1_neg female
        local beta_c_sex_`col' `r(beta)'
        local se_c_sex_`col'   `r(se)'
        beta_coeff1_neg std_cgi_age
        local beta_c_cgi_`col' `r(beta)'
        local se_c_cgi_`col'   `r(se)'
      }

      *--- Panel D: females ---
      preserve
      keep if female==1 & (`agecond')
      if "`var'" == "std_work_hours" {
        cap drop std_work_hours
        qui su work_hours
        qui gen std_work_hours = (work_hours - r(mean)) / r(sd)
        qui su std_work_hours
        if r(N) > 0 {
            assert round(r(mean), 0.0001) == 0
        }
        local regvar "std_work_hours"
      }
      cap drop std_cgi_age
      qui su cgi_main if `regvar' != .
      qui gen std_cgi_age = (cgi_main - r(mean)) / r(sd)
      qui su std_cgi_age if `regvar' != .
      if r(N) > 0 {
          assert round(r(mean), 0.0001) == 0
      }
      if `z'==1 qui reg `regvar' std_cgi_age, vce(hc3)
      if `z'==2 qui reg `regvar' std_cgi_age `controls', vce(hc3)
      local rsquf_`col': di %6.3f e(r2)
      local rsquf_`col' = trim("$`rsquf_`col''$")
      if `sign_female' > 0 {
        beta_coeff1_pos std_cgi_age
        local beta_f_cgi_`col' `r(beta)'
        local se_f_cgi_`col'   `r(se)'
      }
      if `sign_female' < 0 {
        beta_coeff1_neg std_cgi_age
        local beta_f_cgi_`col' `r(beta)'
        local se_f_cgi_`col'   `r(se)'
      }
      restore

      *--- Panel D: males ---
      preserve
      keep if female==0 & (`agecond')
      if "`var'" == "std_work_hours" {
        cap drop std_work_hours
        qui su work_hours
        qui gen std_work_hours = (work_hours - r(mean)) / r(sd)
        qui su std_work_hours
        if r(N) > 0 {
            assert round(r(mean), 0.0001) == 0
        }
        local regvar "std_work_hours"
      }
      cap drop std_cgi_age
      qui su cgi_main if `regvar' != .
      qui gen std_cgi_age = (cgi_main - r(mean)) / r(sd)
      qui su std_cgi_age if `regvar' != .
      if r(N) > 0 {
          assert round(r(mean), 0.0001) == 0
      }
      if `z'==1 qui reg `regvar' std_cgi_age, vce(hc3)
      if `z'==2 qui reg `regvar' std_cgi_age `controls', vce(hc3)
      local rsqum_`col': di %6.3f e(r2)
      local rsqum_`col' = trim("$`rsqum_`col''$")
      if `sign_female' > 0 {
        beta_coeff1_pos std_cgi_age
        local beta_m_cgi_`col' `r(beta)'
        local se_m_cgi_`col'   `r(se)'
      }
      if `sign_female' < 0 {
        beta_coeff1_neg std_cgi_age
        local beta_m_cgi_`col' `r(beta)'
        local se_m_cgi_`col'   `r(se)'
      }
      restore

      *--- suest equality test ---
      if `z'==1 qui reg `regvar' std_cgi_age if female==1 & (`agecond')
      if `z'==2 qui reg `regvar' std_cgi_age `controls' if female==1 & (`agecond')
      est store female_`col'
      if `z'==1 qui reg `regvar' std_cgi_age if female==0 & (`agecond')
      if `z'==2 qui reg `regvar' std_cgi_age `controls' if female==0 & (`agecond')
      est store male_`col'
      suest female_`col' male_`col', vce(robust)
      lincom _b[female_`col'_mean:std_cgi_age] - _b[male_`col'_mean:std_cgi_age]
      local panelD_test_`col': di %6.3f r(p)
      local panelD_test_`col' = trim("$`panelD_test_`col''$")

      *--- Mean of DV ---
      qui su `regvar' if `agecond'
      local mean_`col': di %6.3f r(mean)
      if round(r(mean), 0.0001) == 0 local mean_`col': di %6.0f round(r(mean))

      cap drop std_work_hours

    } // end k

    local outcome_idx = `outcome_idx' + 1
  } // end var

  *---------------------------------------------------------------------------
  * Write Results  (12 data columns)
  *---------------------------------------------------------------------------

  foreach filepath in `"$out_path/US_age_tables/`tableid'.tex"'{

    if `z'==1 file open resultsfile using `"`filepath'"', write replace
    if `z'==2 {
      local fp_ctrl = subinstr(`"`filepath'"', ".tex", "_controls.tex", .)
      file open resultsfile using `"`fp_ctrl'"', write replace
    }

    if `z'==1 {
      file write resultsfile "\caption{CGI and Labor Market Outcomes by Age Group III (US Adults Sample)}"
      file write resultsfile "\label{table 8 byage}"
    }
    if `z'==2 {
      file write resultsfile "\caption{CGI and Labor Market Outcomes by Age Group --- III (US Adults, All Sexual Orientations, with controls)}"
    }
    file write resultsfile "\centering"
    file write resultsfile "\begin{tabular}{p{2cm} M{2.4cm} M{2.4cm} M{2.4cm} M{2.4cm} M{2.4cm} M{2.4cm} M{2.4cm} M{2.4cm} M{2.4cm}}"
    file write resultsfile "\toprule \toprule"
    file write resultsfile "\addlinespace[0.2cm]"
    file write resultsfile "\multicolumn{1}{l}{Measure} & \multicolumn{3}{c}{Performance Pay} & \multicolumn{3}{c}{Wage Negotiation} & \multicolumn{3}{c}{Work Flexibility} \\"
    file write resultsfile "\cmidrule(lr){2-4} \cmidrule(lr){5-7} \cmidrule(lr){8-10}"
    file write resultsfile "\multicolumn{1}{l}{Age Group}"
    forvalues rep = 1/3 {
      file write resultsfile " & \multicolumn{1}{c}{30--39} & \multicolumn{1}{c}{40--49} & \multicolumn{1}{c}{50--60}"
    }
    file write resultsfile " \\"
    file write resultsfile " & (1) & (2) & (3) & (4) & (5) & (6) & (7) & (8) & (9) \\"
    file write resultsfile "\midrule"
    file write resultsfile "\addlinespace[0.2cm]"

    * Panel A
    file write resultsfile "\multicolumn{10}{l}{\textbf{Panel A. Binary gender}} \\" _n
    file write resultsfile "\multicolumn{1}{l}{Female}"
    forvalues col = 1/9 {
      file write resultsfile " & $`beta_a_sex_`col''$"
    }
    file write resultsfile " \\" _n
    file write resultsfile " "
    forvalues col = 1/9 {
      file write resultsfile " & (`se_a_sex_`col'')"
    }
    file write resultsfile " \\" _n
    file write resultsfile "\addlinespace[0.1cm]"
    file write resultsfile "\multicolumn{1}{l}{\$\text{R}^2\$}"
    forvalues col = 1/9 {
      file write resultsfile " & `rsqua_`col''"
    }
    file write resultsfile " \\ \\" _n
    file write resultsfile "\addlinespace[-0.3cm]"
    file write resultsfile "\midrule"

    * Panel B
    file write resultsfile "\multicolumn{10}{l}{\textbf{Panel B. Gender identity}} \\" _n
    file write resultsfile "\multicolumn{1}{l}{CGI (feminine)}"
    forvalues col = 1/9 {
      file write resultsfile " & $`beta_b_cgi_`col''$"
    }
    file write resultsfile " \\" _n
    file write resultsfile " "
    forvalues col = 1/9 {
      file write resultsfile " & (`se_b_cgi_`col'')"
    }
    file write resultsfile " \\" _n
    file write resultsfile "\addlinespace[0.1cm]"
    file write resultsfile "\multicolumn{1}{l}{\$\text{R}^2\$}"
    forvalues col = 1/9 {
      file write resultsfile " & `rsqub_`col''"
    }
    file write resultsfile " \\ \\" _n
    file write resultsfile "\addlinespace[-0.3cm]"
    file write resultsfile "\midrule"

    * Panel C
    file write resultsfile "\multicolumn{10}{l}{\textbf{Panel C. Binary gender and gender identity}} \\" _n
    file write resultsfile "\multicolumn{1}{l}{Female}"
    forvalues col = 1/9 {
      file write resultsfile " & $`beta_c_sex_`col''$"
    }
    file write resultsfile " \\" _n
    file write resultsfile " "
    forvalues col = 1/9 {
      file write resultsfile " & (`se_c_sex_`col'')"
    }
    file write resultsfile " \\ \\" _n
    file write resultsfile "\addlinespace[-0.3cm]"
    file write resultsfile "\multicolumn{1}{l}{CGI (feminine)}"
    forvalues col = 1/9 {
      file write resultsfile " & $`beta_c_cgi_`col''$"
    }
    file write resultsfile " \\" _n
    file write resultsfile " "
    forvalues col = 1/9 {
      file write resultsfile " & (`se_c_cgi_`col'')"
    }
    file write resultsfile " \\" _n
    file write resultsfile "\addlinespace[0.1cm]"
    file write resultsfile "\multicolumn{1}{l}{\$\text{R}^2\$}"
    forvalues col = 1/9 {
      file write resultsfile " & `rsquc_`col''"
    }
    file write resultsfile " \\ \\" _n
    file write resultsfile "\addlinespace[-0.3cm]"
    file write resultsfile "\midrule"

    * Panel D
    file write resultsfile "\multicolumn{10}{l}{\textbf{Panel D. Sample split by binary gender}} \\" _n
    file write resultsfile "\multicolumn{1}{l}{Female: CGI (feminine)}"
    forvalues col = 1/9 {
      file write resultsfile " & $`beta_f_cgi_`col''$"
    }
    file write resultsfile " \\" _n
    file write resultsfile " "
    forvalues col = 1/9 {
      file write resultsfile " & (`se_f_cgi_`col'')"
    }
    file write resultsfile " \\" _n
    file write resultsfile "\addlinespace[0.1cm]"
    file write resultsfile "\multicolumn{1}{l}{\$\text{R}^2\$}"
    forvalues col = 1/9 {
      file write resultsfile " & `rsquf_`col''"
    }
    file write resultsfile " \\ \\" _n
    file write resultsfile "\addlinespace[-0.3cm]"
    file write resultsfile "\multicolumn{1}{l}{Male: CGI (feminine)}"
    forvalues col = 1/9 {
      file write resultsfile " & $`beta_m_cgi_`col''$"
    }
    file write resultsfile " \\" _n
    file write resultsfile " "
    forvalues col = 1/9 {
      file write resultsfile " & (`se_m_cgi_`col'')"
    }
    file write resultsfile " \\" _n
    file write resultsfile "\addlinespace[0.1cm]"
    file write resultsfile "\multicolumn{1}{l}{\$\text{R}^2\$}"
    forvalues col = 1/9 {
      file write resultsfile " & `rsqum_`col''"
    }
    file write resultsfile " \\ \\" _n
    file write resultsfile "\addlinespace[-0.3cm]"
    file write resultsfile "\multicolumn{10}{l}{Test: male sample split CGI = female sample split CGI} \\" _n
    file write resultsfile "\addlinespace[-0.6cm]"
    file write resultsfile "\multicolumn{1}{l}{p-value}"
    forvalues col = 1/9 {
      file write resultsfile " & $`panelD_test_`col''$"
    }
    file write resultsfile " \\" _n
    file write resultsfile "\addlinespace[-0.5cm]"
    file write resultsfile "\midrule"

    * Observations
    file write resultsfile "\multicolumn{1}{l}{Observations}"
    forvalues col = 1/9 {
      file write resultsfile " & `N_`col''"
    }
    file write resultsfile " \\ \\" _n
    file write resultsfile "\addlinespace[-0.3cm]"

    * Mean of DV
    file write resultsfile "\multicolumn{1}{l}{Mean of Dependent Variable}"
    forvalues col = 1/9 {
      file write resultsfile " & `mean_`col''"
    }
    file write resultsfile " \\ \\" _n
    file write resultsfile "\addlinespace[-0.3cm]"

    file write resultsfile "\bottomrule\bottomrule"
    file write resultsfile "\end{tabular}"
    file close resultsfile

  } // end filepath

} // end z
