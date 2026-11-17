clear all

global out_path "$path/3_out" 
		
local tableid "table_5_byage"

do "$path/2_do/2_analysis/0_reg_fnc/0_regressions.do"
do "$path/2_do/2_analysis/0_reg_fnc/0_regressions_1t_+.do"
do "$path/2_do/2_analysis/0_reg_fnc/0_regressions_1t_-.do"

cap mkdir "$out_path/US_age_tables"

local age_lo "30 40 50"
local age_hi "39 49 60"

* outcome_idx: 1 = Redistribution (cols 1-4), 2 = Donation (cols 5-8)

forvalues z = 1/2 {

  forvalues outcome_idx = 1/2 {

    if `outcome_idx' == 1 {
      local rawvar "redistribution"
    }
    if `outcome_idx' == 2 {
      local rawvar "donation"
    }

    forvalues k = 1/3 {

      local col = (`outcome_idx' - 1) * 3 + `k'
      local agemin : word `k' of `age_lo'
      local agemax : word `k' of `age_hi'
      local agecond "age >= `agemin' & age <= `agemax'"

      use "$path/1_data/2_prepared/1_usadults_w1_w2_30_60.dta", clear
      local controls "c.age##c.age black all_other_races i.division wave1"

      *--- Standardize outcome + CGI within age-group subsample ---
      cap drop std_outcome_age
      qui su `rawvar' if `agecond'
      qui gen std_outcome_age = (`rawvar' - r(mean)) / r(sd)

      cap drop std_cgi_age
      qui su cgi_main if `agecond' & std_outcome_age != .
      qui gen std_cgi_age = (cgi_main - r(mean)) / r(sd)

      * sanity
      qui su std_outcome_age if `agecond'
      if r(N) > 0 {
          assert round(r(mean), 0.0001) == 0
      }
      qui su std_cgi_age if `agecond' & std_outcome_age != .
      if r(N) > 0 {
          assert round(r(mean), 0.0001) == 0
      }

      *--- Panel A ---
      if `z'==1 qui reg std_outcome_age female if `agecond', vce(hc3)
      if `z'==2 qui reg std_outcome_age female `controls' if `agecond', vce(hc3)

      beta_coeff2 female
      local beta_a_sex_`col' `r(beta)'
      local se_a_sex_`col'   `r(se)'
      local rsqua_`col': di %6.3f e(r2)
      local rsqua_`col' = trim("$`rsqua_`col''$")
      local sign_female = sign(_b[female])

      *--- Panel B (Redistribution only; Donation cols are phantom) ---
      if `outcome_idx' == 1 {
        if `z'==1 qui reg std_outcome_age std_cgi_age if `agecond', vce(hc3)
        if `z'==2 qui reg std_outcome_age std_cgi_age `controls' if `agecond', vce(hc3)

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
      }

      *--- Panel C (Redistribution only) ---
      if `outcome_idx' == 1 {
        if `z'==1 qui reg std_outcome_age female std_cgi_age if `agecond', vce(hc3)
        if `z'==2 qui reg std_outcome_age female std_cgi_age `controls' if `agecond', vce(hc3)

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
      }

      *--- N (from Panel A regression for Donation, C for Redistribution) ---
      if `outcome_idx' == 2 {
        * Panel A is the only real panel for Donation; grab N from it
        if `z'==1 qui reg std_outcome_age female if `agecond', vce(hc3)
        local N_`col': di %11.0gc e(N)
      }
      else {
        * Redistribution: N from Panel C regression already in memory
        local N_`col': di %11.0gc e(N)
      }

      *--- Panel D: females (Redistribution only) ---
      if `outcome_idx' == 1 {
        preserve
        keep if female==1 & (`agecond')

        cap drop std_outcome_age
        qui su `rawvar'
        qui gen std_outcome_age = (`rawvar' - r(mean)) / r(sd)
        cap drop std_cgi_age
        qui su cgi_main if std_outcome_age != .
        qui gen std_cgi_age = (cgi_main - r(mean)) / r(sd)

        if `z'==1 qui reg std_outcome_age std_cgi_age, vce(hc3)
        if `z'==2 qui reg std_outcome_age std_cgi_age `controls', vce(hc3)

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

        cap drop std_outcome_age
        qui su `rawvar'
        qui gen std_outcome_age = (`rawvar' - r(mean)) / r(sd)
        cap drop std_cgi_age
        qui su cgi_main if std_outcome_age != .
        qui gen std_cgi_age = (cgi_main - r(mean)) / r(sd)

        if `z'==1 qui reg std_outcome_age std_cgi_age, vce(hc3)
        if `z'==2 qui reg std_outcome_age std_cgi_age `controls', vce(hc3)

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

        *--- suest test ---
        if `z'==1 qui reg std_outcome_age std_cgi_age if female==1 & (`agecond')
        if `z'==2 qui reg std_outcome_age std_cgi_age `controls' if female==1 & (`agecond')
        est store female_`col'

        if `z'==1 qui reg std_outcome_age std_cgi_age if female==0 & (`agecond')
        if `z'==2 qui reg std_outcome_age std_cgi_age `controls' if female==0 & (`agecond')
        est store male_`col'

        suest female_`col' male_`col', vce(robust)
        lincom _b[female_`col'_mean:std_cgi_age] - _b[male_`col'_mean:std_cgi_age]
        local panelD_test_`col': di %6.3f r(p)
        local panelD_test_`col' = trim("$`panelD_test_`col''$")
      } // end if Redistribution Panel D

      *--- Mean of DV ---
      qui su std_outcome_age if `agecond'
      local mean_`col': di %6.0f round(r(mean), 1)

    } // end k loop
  } // end outcome_idx loop

  *---------------------------------------------------------------------------
  * Write Results
  * 8 data columns; total cols including label = 9
  * Redistribution cols 1-4: all panels
  * Donation cols 5-8: Panel A only, phantom in B/C/D
  *---------------------------------------------------------------------------

  foreach filepath in `"$out_path/US_age_tables/`tableid'.tex"'  {

    if `z'==1 {
      file open resultsfile using `"`filepath'"', write replace
    }
    if `z'==2 {
      local fp_ctrl = subinstr(`"`filepath'"', ".tex", "_controls.tex", .)
      file open resultsfile using `"`fp_ctrl'"', write replace
    }

    if `z'==1 {
      file write resultsfile "\caption{CGI and Unincentivized Distributional Preferences by Age Group (US Adults)}"
      file write resultsfile "\label{table 5 byage}"
    }
    if `z'==2 {
      file write resultsfile "\caption{CGI and Unincentivized Distributional Preferences by Age Group (US Adults, All Sexual Orientations, with controls)}"
    }

    file write resultsfile "\centering"
    file write resultsfile "\begin{tabular}{p{2cm} M{1.5cm} M{1.5cm} M{1.5cm} M{1.5cm} M{1.5cm} M{1.5cm}}"
    file write resultsfile "\toprule \toprule"
    file write resultsfile "\addlinespace[0.2cm]"
    file write resultsfile "\multicolumn{1}{l}{Measure} & \multicolumn{3}{c}{Redistribution} & \multicolumn{3}{c}{Donation} \\"
    file write resultsfile "\cmidrule(lr){2-4} \cmidrule(lr){5-7}"
    file write resultsfile "\multicolumn{1}{l}{Age Group}"
    forvalues rep = 1/2 {
      file write resultsfile " & \multicolumn{1}{c}{30--39} & \multicolumn{1}{c}{40--49} & \multicolumn{1}{c}{50--60}"
    }
    file write resultsfile " \\"
    file write resultsfile " & (1) & (2) & (3) & (4) & (5) & (6) \\"
    file write resultsfile "\midrule"
    file write resultsfile "\addlinespace[0.2cm]"

    * Panel A (all 8 cols)
    file write resultsfile "\multicolumn{7}{l}{\textbf{Panel A. Binary gender}} \\" _n
    file write resultsfile "\multicolumn{1}{l}{Female}"
    forvalues col = 1/6 {
      file write resultsfile " & $`beta_a_sex_`col''$"
    }
    file write resultsfile " \\" _n
    file write resultsfile " "
    forvalues col = 1/6 {
      file write resultsfile " & (`se_a_sex_`col'')"
    }
    file write resultsfile " \\" _n
    file write resultsfile "\addlinespace[0.1cm]"
    file write resultsfile "\multicolumn{1}{l}{\$\text{R}^2\$}"
    forvalues col = 1/6 {
      file write resultsfile " & `rsqua_`col''"
    }
    file write resultsfile " \\ \\" _n
    file write resultsfile "\addlinespace[-0.3cm]"
    file write resultsfile "\midrule"

    * Panel B (Redistribution cols 1-4 real; Donation cols 5-8 phantom)
    file write resultsfile "\multicolumn{7}{l}{\textbf{Panel B. Gender identity}} \\" _n
    file write resultsfile "\multicolumn{1}{l}{CGI (feminine)}"
    forvalues col = 1/3 {
      file write resultsfile " & $`beta_b_cgi_`col''$"
    }
    forvalues col = 4/6 {
      file write resultsfile " & \phantom{$`beta_b_cgi_`col''$}"
    }
    file write resultsfile " \\" _n
    file write resultsfile " "
    forvalues col = 1/3 {
      file write resultsfile " & (`se_b_cgi_`col'')"
    }
    forvalues col = 4/6 {
      file write resultsfile " & \phantom{(`se_b_cgi_`col'')}"
    }
    file write resultsfile " \\" _n
    file write resultsfile "\addlinespace[0.1cm]"
    file write resultsfile "\multicolumn{1}{l}{\$\text{R}^2\$}"
    forvalues col = 1/3 {
      file write resultsfile " & `rsqub_`col''"
    }
    forvalues col = 4/6 {
      file write resultsfile " & \phantom{`rsqub_`col''}"
    }
    file write resultsfile " \\ \\" _n
    file write resultsfile "\addlinespace[-0.3cm]"
    file write resultsfile "\midrule"

    * Panel C (cols 1-4 real; cols 5-8 phantom)
    file write resultsfile "\multicolumn{7}{l}{\textbf{Panel C. Binary gender and gender identity}} \\" _n
    file write resultsfile "\multicolumn{1}{l}{Female}"
    forvalues col = 1/3 {
      file write resultsfile " & $`beta_c_sex_`col''$"
    }
    forvalues col = 4/6 {
      file write resultsfile " & \phantom{$`beta_c_sex_`col''$}"
    }
    file write resultsfile " \\" _n
    file write resultsfile " "
    forvalues col = 1/3 {
      file write resultsfile " & (`se_c_sex_`col'')"
    }
    forvalues col = 4/6 {
      file write resultsfile " & \phantom{(`se_c_sex_`col'')}"
    }
    file write resultsfile " \\ \\" _n
    file write resultsfile "\addlinespace[-0.3cm]"
    file write resultsfile "\multicolumn{1}{l}{CGI (feminine)}"
    forvalues col = 1/3 {
      file write resultsfile " & $`beta_c_cgi_`col''$"
    }
    forvalues col = 4/6 {
      file write resultsfile " & \phantom{$`beta_c_cgi_`col''$}"
    }
    file write resultsfile " \\" _n
    file write resultsfile " "
    forvalues col = 1/3 {
      file write resultsfile " & (`se_c_cgi_`col'')"
    }
    forvalues col = 4/6 {
      file write resultsfile " & \phantom{(`se_c_cgi_`col'')}"
    }
    file write resultsfile " \\" _n
    file write resultsfile "\addlinespace[0.1cm]"
    file write resultsfile "\multicolumn{1}{l}{\$\text{R}^2\$}"
    forvalues col = 1/3 {
      file write resultsfile " & `rsquc_`col''"
    }
    forvalues col = 4/6 {
      file write resultsfile " & \phantom{`rsquc_`col''}"
    }
    file write resultsfile " \\ \\" _n
    file write resultsfile "\addlinespace[-0.3cm]"
    file write resultsfile "\midrule"

    * Panel D (cols 1-4 real; cols 5-8 phantom)
    file write resultsfile "\multicolumn{7}{l}{\textbf{Panel D. Sample split by binary gender}} \\" _n
    file write resultsfile "\multicolumn{1}{l}{Female: CGI (feminine)}"
    forvalues col = 1/3 {
      file write resultsfile " & $`beta_f_cgi_`col''$"
    }
    forvalues col = 4/6 {
      file write resultsfile " & \phantom{$`beta_f_cgi_`col''$}"
    }
    file write resultsfile " \\" _n
    file write resultsfile " "
    forvalues col = 1/3 {
      file write resultsfile " & (`se_f_cgi_`col'')"
    }
    forvalues col = 4/6 {
      file write resultsfile " & \phantom{(`se_f_cgi_`col'')}"
    }
    file write resultsfile " \\" _n
    file write resultsfile "\addlinespace[0.1cm]"
    file write resultsfile "\multicolumn{1}{l}{\$\text{R}^2\$}"
    forvalues col = 1/3 {
      file write resultsfile " & `rsquf_`col''"
    }
    forvalues col = 4/6 {
      file write resultsfile " & \phantom{`rsquf_`col''}"
    }
    file write resultsfile " \\ \\" _n
    file write resultsfile "\addlinespace[-0.3cm]"

    file write resultsfile "\multicolumn{1}{l}{Male: CGI (feminine)}"
    forvalues col = 1/3 {
      file write resultsfile " & $`beta_m_cgi_`col''$"
    }
    forvalues col = 4/6 {
      file write resultsfile " & \phantom{$`beta_m_cgi_`col''$}"
    }
    file write resultsfile " \\" _n
    file write resultsfile " "
    forvalues col = 1/3 {
      file write resultsfile " & (`se_m_cgi_`col'')"
    }
    forvalues col = 4/6 {
      file write resultsfile " & \phantom{(`se_m_cgi_`col'')}"
    }
    file write resultsfile " \\" _n
    file write resultsfile "\addlinespace[0.1cm]"
    file write resultsfile "\multicolumn{1}{l}{\$\text{R}^2\$}"
    forvalues col = 1/3 {
      file write resultsfile " & `rsqum_`col''"
    }
    forvalues col = 4/6 {
      file write resultsfile " & \phantom{`rsqum_`col''}"
    }
    file write resultsfile " \\ \\" _n
    file write resultsfile "\addlinespace[-0.3cm]"

    file write resultsfile "\multicolumn{7}{l}{Test: male sample split CGI = female sample split CGI} \\" _n
    file write resultsfile "\addlinespace[-0.6cm]"
    file write resultsfile "\multicolumn{1}{l}{p-value}"
    forvalues col = 1/3 {
      file write resultsfile " & $`panelD_test_`col''$"
    }
    forvalues col = 4/6 {
      file write resultsfile " & \phantom{$`panelD_test_`col''$}"
    }
    file write resultsfile " \\" _n
    file write resultsfile "\addlinespace[-0.5cm]"
    file write resultsfile "\midrule"

    * Observations
    file write resultsfile "\multicolumn{1}{l}{Observations}"
    forvalues col = 1/6 {
      file write resultsfile " & `N_`col''"
    }
    file write resultsfile " \\ \\" _n
    file write resultsfile "\addlinespace[-0.3cm]"

    * Mean of DV
    file write resultsfile "\multicolumn{1}{l}{Mean of Dependent Variable}"
    forvalues col = 1/6 {
      file write resultsfile " & `mean_`col''"
    }
    file write resultsfile " \\ \\" _n
    file write resultsfile "\addlinespace[-0.3cm]"

    file write resultsfile "\bottomrule\bottomrule"
    file write resultsfile "\end{tabular}"
    file close resultsfile

  } // end foreach filepath

} // end z loop
