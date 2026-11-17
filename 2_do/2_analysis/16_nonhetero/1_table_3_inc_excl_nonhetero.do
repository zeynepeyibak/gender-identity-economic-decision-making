clear all

global out_path "$path/3_out"
				
local tableid "table_3"
local colno "10"
local dropped_panelC "10"

do "$path/2_do/2_analysis/0_reg_fnc/0_regressions.do"
do "$path/2_do/2_analysis/0_reg_fnc/0_regressions_1t_+.do"
do "$path/2_do/2_analysis/0_reg_fnc/0_regressions_1t_-.do"

/*
Table 3 — column mapping
Column 1:  Risk          - Swiss Uni  - Incl. non-het
Column 2:  Risk          - Swiss Uni  - Excl. non-het
Column 3:  Risk          - US Adults  - Incl. non-het
Column 4:  Risk          - US Adults  - Excl. non-het
Column 5:  Competitiveness - Swiss Uni - Incl. non-het
Column 6:  Competitiveness - Swiss Uni - Excl. non-het
Column 7:  Efficiency    - Swiss Uni  - Incl. non-het
Column 8:  Efficiency    - Swiss Uni  - Excl. non-het
Column 9:  Overconfidence - Swiss Uni - Incl. non-het
Column 10: Overconfidence - Swiss Uni - Excl. non-het

het==1: incl. non-het (full sample)
het==2: excl. non-het (hetero only)
  Swiss Uni:  sexual_orientation_fo==1
  US Adults:  bisexual!=1 & gay!=1 & other_orientation!=1
*/

*-----------------------------------------------------------------------------
cap mkdir "$out_path/Tables_nonhetero"

*-----------------------------------------------------------------------------
forvalues z = 1/2 {

  forvalues i = 1/5 {

    forvalues het = 1/2 {

      local col = (`i'-1)*2 + `het'

      *--- Load data, set controls and hetcond ---
      if `i'==1 | `i'==3 | `i'==4 | `i'==5 {
        use "$path/1_data/2_prepared/1_SwissUni.dta", clear
        local controls "c.age##c.age educ_control"
        if `het'==1 local hetcond "1==1"
        if `het'==2 local hetcond "sexual_orientation_fo==1"
      }

      if `i'==2 {
        use "$path/1_data/2_prepared/1_usadults_w1_w2_30_60.dta", clear
        local controls "c.age##c.age black all_other_races i.division wave1"
        if `het'==1 local hetcond "1==1"
        if `het'==2 local hetcond "bisexual!=1 & gay!=1 & other_orientation!=1"
      }

      *-------------------------------------------------------------------------
      * Restandardize CGI and outcomes within het subsample
      *-------------------------------------------------------------------------

      if `i'==1 | `i'==2 {
        cap drop std_incentivized_risk
        qui su incentivized_risk if `hetcond'
        qui gen std_incentivized_risk = (incentivized_risk - r(mean)) / r(sd)
        cap drop std_cgi_main
        qui su cgi_main if std_incentivized_risk != . & (`hetcond')
        qui gen std_cgi_main = (cgi_main - r(mean)) / r(sd)
      }
      if `i'==3 {
        cap drop std_cgi_main
        qui su cgi_main if incentivized_competitiveness != . & (`hetcond')
        qui gen std_cgi_main = (cgi_main - r(mean)) / r(sd)
      }
      if `i'==4 {
        cap drop std_cgi_main
        qui su cgi_main if rho != . & (`hetcond')
        qui gen std_cgi_main = (cgi_main - r(mean)) / r(sd)
      }
      if `i'==5 {
        cap drop std_incentivized_overconfidence
        qui su incentivized_overconfidence if `hetcond'
        qui gen std_incentivized_overconfidence = (incentivized_overconfidence - r(mean)) / r(sd)
        cap drop std_cgi_main
        qui su cgi_main if std_incentivized_overconfidence != . & (`hetcond')
        qui gen std_cgi_main = (cgi_main - r(mean)) / r(sd)
      }

      *-------------------------------------------------------------------------
      * Sanity checks — mean within subsample should now be 0
      *-------------------------------------------------------------------------
      if `i'==1 | `i'==2 {
        qui su std_incentivized_risk if `hetcond'
        assert round(r(mean), 0.0001) == 0
        qui su std_cgi_main if std_incentivized_risk != . & (`hetcond')
        assert round(r(mean), 0.0001) == 0
      }
      if `i'==3 {
        qui su std_cgi_main if incentivized_competitiveness != . & (`hetcond')
        assert round(r(mean), 0.0001) == 0
      }
      if `i'==4 {
        qui su std_cgi_main if rho != . & (`hetcond')
        assert round(r(mean), 0.0001) == 0
      }
      if `i'==5 {
        qui su std_incentivized_overconfidence if `hetcond'
        assert round(r(mean), 0.0001) == 0
        qui su std_cgi_main if std_incentivized_overconfidence != . & (`hetcond')
        assert round(r(mean), 0.0001) == 0
      }

      *-------------------------------------------------------------------------
      * Panel A: biological gender
      *-------------------------------------------------------------------------
      if `z'==1 {
        if `i'==1 qui reg std_incentivized_risk female if `hetcond', vce(hc3)
        if `i'==2 qui reg std_incentivized_risk female if `hetcond', vce(hc3)
        if `i'==3 qui reg incentivized_competitiveness female if `hetcond', vce(hc3)
        if `i'==4 qui reg rho female if `hetcond', vce(hc3)
        if `i'==5 qui reg std_incentivized_overconfidence female if `hetcond', vce(hc3)
      }
      if `z'==2 {
        if `i'==1 qui reg std_incentivized_risk female `controls' if `hetcond', vce(hc3)
        if `i'==2 qui reg std_incentivized_risk female `controls' if `hetcond', vce(hc3)
        if `i'==3 qui reg incentivized_competitiveness female `controls' if `hetcond', vce(hc3)
        if `i'==4 qui reg rho female `controls' if `hetcond', vce(hc3)
        if `i'==5 qui reg std_incentivized_overconfidence female `controls' if `hetcond', vce(hc3)
      }

      local rsqua_`col': di %6.3f e(r2)
      local rsqua_`col' = trim("$`rsqua_`col''$")
      beta_coeff2 female
      local beta_a_sex_`col' `r(beta)'
      local se_a_sex_`col'   `r(se)'
      local rsqua_`col'_meta   = e(r2)
      local adjrsqua_`col'_meta = e(r2_a)
      local sign_female = sign(_b[female])

      *-------------------------------------------------------------------------
      * Panel B: CGI only
      *-------------------------------------------------------------------------
      if `z'==1 {
        if `i'==1 qui reg std_incentivized_risk std_cgi_main if `hetcond', vce(hc3)
        if `i'==2 qui reg std_incentivized_risk std_cgi_main if `hetcond', vce(hc3)
        if `i'==3 qui reg incentivized_competitiveness std_cgi_main if `hetcond', vce(hc3)
        if `i'==4 qui reg rho std_cgi_main if `hetcond', vce(hc3)
        if `i'==5 qui reg std_incentivized_overconfidence std_cgi_main if `hetcond', vce(hc3)
      }
      if `z'==2 {
        if `i'==1 qui reg std_incentivized_risk std_cgi_main `controls' if `hetcond', vce(hc3)
        if `i'==2 qui reg std_incentivized_risk std_cgi_main `controls' if `hetcond', vce(hc3)
        if `i'==3 qui reg incentivized_competitiveness std_cgi_main `controls' if `hetcond', vce(hc3)
        if `i'==4 qui reg rho std_cgi_main `controls' if `hetcond', vce(hc3)
        if `i'==5 qui reg std_incentivized_overconfidence std_cgi_main `controls' if `hetcond', vce(hc3)
      }

      local rsqub_`col': di %6.3f e(r2)
      local rsqub_`col' = trim("$`rsqub_`col''$")
      if `sign_female'>0 {
        beta_coeff1_pos std_cgi_main
        local beta_b_cgi_`col' `r(beta)'
        local se_b_cgi_`col'   `r(se)'
      }
      if `sign_female'<0 {
        beta_coeff1_neg std_cgi_main
        local beta_b_cgi_`col' `r(beta)'
        local se_b_cgi_`col'   `r(se)'
      }

      *-------------------------------------------------------------------------
      * Panel C: female + CGI
      *-------------------------------------------------------------------------
      if `z'==1 {
        if `i'==1 qui reg std_incentivized_risk female std_cgi_main if `hetcond', vce(hc3)
        if `i'==2 qui reg std_incentivized_risk female std_cgi_main if `hetcond', vce(hc3)
        if `i'==3 qui reg incentivized_competitiveness female std_cgi_main if `hetcond', vce(hc3)
        if `i'==4 qui reg rho female std_cgi_main if `hetcond', vce(hc3)
        if `i'==5 qui reg std_incentivized_overconfidence female std_cgi_main if `hetcond', vce(hc3)
      }
      if `z'==2 {
        if `i'==1 qui reg std_incentivized_risk female std_cgi_main `controls' if `hetcond', vce(hc3)
        if `i'==2 qui reg std_incentivized_risk female std_cgi_main `controls' if `hetcond', vce(hc3)
        if `i'==3 qui reg incentivized_competitiveness female std_cgi_main `controls' if `hetcond', vce(hc3)
        if `i'==4 qui reg rho female std_cgi_main `controls' if `hetcond', vce(hc3)
        if `i'==5 qui reg std_incentivized_overconfidence female std_cgi_main `controls' if `hetcond', vce(hc3)
      }

      local N_`col': di %11.0gc e(N)
      local rsquc_`col': di %6.3f e(r2)
      local rsquc_`col' = trim("$`rsquc_`col''$")
      if `sign_female'>0 {
        beta_coeff1_pos female
        local beta_c_sex_`col' `r(beta)'
        local se_c_sex_`col'   `r(se)'
        beta_coeff1_pos std_cgi_main
        local beta_c_cgi_`col' `r(beta)'
        local se_c_cgi_`col'   `r(se)'
      }
      if `sign_female'<0 {
        beta_coeff1_neg female
        local beta_c_sex_`col' `r(beta)'
        local se_c_sex_`col'   `r(se)'
        beta_coeff1_neg std_cgi_main
        local beta_c_cgi_`col' `r(beta)'
        local se_c_cgi_`col'   `r(se)'
      }

      local beta_c_cgi_`col'_meta  = _b[std_cgi_main]
      local se_c_cgi_`col'_meta    = _se[std_cgi_main]
      local p_c_cgi_`col'_meta     = 2*ttail(e(df_r),abs(_b[std_cgi_main]/_se[std_cgi_main]))
      qui test _b[std_cgi_main]=0
      local sign_cgi = sign(_b[std_cgi_main])
      if `sign_female'>0 local p_c_cgi_`col'_meta_1t = ttail(r(df_r),`sign_cgi'*sqrt(r(F)))
      if `sign_female'<0 local p_c_cgi_`col'_meta_1t = 1-ttail(r(df_r),`sign_cgi'*sqrt(r(F)))
      local rsquc_`col'_meta    = e(r2)
      local adjrsquc_`col'_meta = e(r2_a)

      *-------------------------------------------------------------------------
      * Panel D: sample split by binary gender
      * Restandardize within female/male x het subsample
      *-------------------------------------------------------------------------

      * --- Females ---
      preserve
      keep if female==1

      if `i'==1 | `i'==2 {
        cap drop std_incentivized_risk
        qui su incentivized_risk if `hetcond'
        qui gen std_incentivized_risk = (incentivized_risk - r(mean)) / r(sd)
        cap drop std_cgi_main
        qui su cgi_main if std_incentivized_risk != . & (`hetcond')
        qui gen std_cgi_main = (cgi_main - r(mean)) / r(sd)
      }
      if `i'==3 {
        cap drop std_cgi_main
        qui su cgi_main if incentivized_competitiveness != . & (`hetcond')
        qui gen std_cgi_main = (cgi_main - r(mean)) / r(sd)
      }
      if `i'==4 {
        cap drop std_cgi_main
        qui su cgi_main if rho != . & (`hetcond')
        qui gen std_cgi_main = (cgi_main - r(mean)) / r(sd)
      }
      if `i'==5 {
        cap drop std_incentivized_overconfidence
        qui su incentivized_overconfidence if `hetcond'
        qui gen std_incentivized_overconfidence = (incentivized_overconfidence - r(mean)) / r(sd)
        cap drop std_cgi_main
        qui su cgi_main if std_incentivized_overconfidence != . & (`hetcond')
        qui gen std_cgi_main = (cgi_main - r(mean)) / r(sd)
      }

      if `z'==1 {
        if `i'==1 qui reg std_incentivized_risk std_cgi_main if `hetcond', vce(hc3)
        if `i'==2 qui reg std_incentivized_risk std_cgi_main if `hetcond', vce(hc3)
        if `i'==3 qui reg incentivized_competitiveness std_cgi_main if `hetcond', vce(hc3)
        if `i'==4 qui reg rho std_cgi_main if `hetcond', vce(hc3)
        if `i'==5 qui reg std_incentivized_overconfidence std_cgi_main if `hetcond', vce(hc3)
      }
      if `z'==2 {
        if `i'==1 qui reg std_incentivized_risk std_cgi_main `controls' if `hetcond', vce(hc3)
        if `i'==2 qui reg std_incentivized_risk std_cgi_main `controls' if `hetcond', vce(hc3)
        if `i'==3 qui reg incentivized_competitiveness std_cgi_main `controls' if `hetcond', vce(hc3)
        if `i'==4 qui reg rho std_cgi_main `controls' if `hetcond', vce(hc3)
        if `i'==5 qui reg std_incentivized_overconfidence std_cgi_main `controls' if `hetcond', vce(hc3)
      }

      local rsquf_`col': di %6.3f e(r2)
      local rsquf_`col' = trim("$`rsquf_`col''$")
      if `sign_female'>0 {
        beta_coeff1_pos std_cgi_main
        local beta_f_cgi_`col' `r(beta)'
        local se_f_cgi_`col'   `r(se)'
      }
      if `sign_female'<0 {
        beta_coeff1_neg std_cgi_main
        local beta_f_cgi_`col' `r(beta)'
        local se_f_cgi_`col'   `r(se)'
      }
      local beta_f_cgi_`col'_meta  = _b[std_cgi_main]
      local se_f_cgi_`col'_meta    = _se[std_cgi_main]
      local p_f_cgi_`col'_meta     = 2*ttail(e(df_r),abs(_b[std_cgi_main]/_se[std_cgi_main]))
      qui test _b[std_cgi_main]=0
      local sign_cgi = sign(_b[std_cgi_main])
      if `sign_female'>0 local p_f_cgi_`col'_meta_1t = ttail(r(df_r),`sign_cgi'*sqrt(r(F)))
      if `sign_female'<0 local p_f_cgi_`col'_meta_1t = 1-ttail(r(df_r),`sign_cgi'*sqrt(r(F)))
      local rsquf_`col'_meta    = e(r2)
      local adjrsquf_`col'_meta = e(r2_a)
      restore

      * --- Males ---
      preserve
      keep if female==0

      if `i'==1 | `i'==2 {
        cap drop std_incentivized_risk
        qui su incentivized_risk if `hetcond'
        qui gen std_incentivized_risk = (incentivized_risk - r(mean)) / r(sd)
        cap drop std_cgi_main
        qui su cgi_main if std_incentivized_risk != . & (`hetcond')
        qui gen std_cgi_main = (cgi_main - r(mean)) / r(sd)
      }
      if `i'==3 {
        cap drop std_cgi_main
        qui su cgi_main if incentivized_competitiveness != . & (`hetcond')
        qui gen std_cgi_main = (cgi_main - r(mean)) / r(sd)
      }
      if `i'==4 {
        cap drop std_cgi_main
        qui su cgi_main if rho != . & (`hetcond')
        qui gen std_cgi_main = (cgi_main - r(mean)) / r(sd)
      }
      if `i'==5 {
        cap drop std_incentivized_overconfidence
        qui su incentivized_overconfidence if `hetcond'
        qui gen std_incentivized_overconfidence = (incentivized_overconfidence - r(mean)) / r(sd)
        cap drop std_cgi_main
        qui su cgi_main if std_incentivized_overconfidence != . & (`hetcond')
        qui gen std_cgi_main = (cgi_main - r(mean)) / r(sd)
      }

      if `z'==1 {
        if `i'==1 qui reg std_incentivized_risk std_cgi_main if `hetcond', vce(hc3)
        if `i'==2 qui reg std_incentivized_risk std_cgi_main if `hetcond', vce(hc3)
        if `i'==3 qui reg incentivized_competitiveness std_cgi_main if `hetcond', vce(hc3)
        if `i'==4 qui reg rho std_cgi_main if `hetcond', vce(hc3)
        if `i'==5 qui reg std_incentivized_overconfidence std_cgi_main if `hetcond', vce(hc3)
      }
      if `z'==2 {
        if `i'==1 qui reg std_incentivized_risk std_cgi_main `controls' if `hetcond', vce(hc3)
        if `i'==2 qui reg std_incentivized_risk std_cgi_main `controls' if `hetcond', vce(hc3)
        if `i'==3 qui reg incentivized_competitiveness std_cgi_main `controls' if `hetcond', vce(hc3)
        if `i'==4 qui reg rho std_cgi_main `controls' if `hetcond', vce(hc3)
        if `i'==5 qui reg std_incentivized_overconfidence std_cgi_main `controls' if `hetcond', vce(hc3)
      }

      local rsqum_`col': di %6.3f e(r2)
      local rsqum_`col' = trim("$`rsqum_`col''$")
      if `sign_female'>0 {
        beta_coeff1_pos std_cgi_main
        local beta_m_cgi_`col' `r(beta)'
        local se_m_cgi_`col'   `r(se)'
      }
      if `sign_female'<0 {
        beta_coeff1_neg std_cgi_main
        local beta_m_cgi_`col' `r(beta)'
        local se_m_cgi_`col'   `r(se)'
      }
      local beta_m_cgi_`col'_meta  = _b[std_cgi_main]
      local se_m_cgi_`col'_meta    = _se[std_cgi_main]
      local p_m_cgi_`col'_meta     = 2*ttail(e(df_r),abs(_b[std_cgi_main]/_se[std_cgi_main]))
      qui test _b[std_cgi_main]=0
      local sign_cgi = sign(_b[std_cgi_main])
      if `sign_female'>0 local p_m_cgi_`col'_meta_1t = ttail(r(df_r),`sign_cgi'*sqrt(r(F)))
      if `sign_female'<0 local p_m_cgi_`col'_meta_1t = 1-ttail(r(df_r),`sign_cgi'*sqrt(r(F)))
      local rsqum_`col'_meta    = e(r2)
      local adjrsqum_`col'_meta = e(r2_a)
      restore

      *--- suest: test male CGI = female CGI within subsample ---
      if `z'==1 {
        if `i'==1 qui reg std_incentivized_risk std_cgi_main if `hetcond' & female==1
        if `i'==2 qui reg std_incentivized_risk std_cgi_main if `hetcond' & female==1
        if `i'==3 qui reg incentivized_competitiveness std_cgi_main if `hetcond' & female==1
        if `i'==4 qui reg rho std_cgi_main if `hetcond' & female==1
        if `i'==5 qui reg std_incentivized_overconfidence std_cgi_main if `hetcond' & female==1
      }
      if `z'==2 {
        if `i'==1 qui reg std_incentivized_risk std_cgi_main `controls' if `hetcond' & female==1
        if `i'==2 qui reg std_incentivized_risk std_cgi_main `controls' if `hetcond' & female==1
        if `i'==3 qui reg incentivized_competitiveness std_cgi_main `controls' if `hetcond' & female==1
        if `i'==4 qui reg rho std_cgi_main `controls' if `hetcond' & female==1
        if `i'==5 qui reg std_incentivized_overconfidence std_cgi_main `controls' if `hetcond' & female==1
      }
      est store female_`col'

      if `z'==1 {
        if `i'==1 qui reg std_incentivized_risk std_cgi_main if `hetcond' & female==0
        if `i'==2 qui reg std_incentivized_risk std_cgi_main if `hetcond' & female==0
        if `i'==3 qui reg incentivized_competitiveness std_cgi_main if `hetcond' & female==0
        if `i'==4 qui reg rho std_cgi_main if `hetcond' & female==0
        if `i'==5 qui reg std_incentivized_overconfidence std_cgi_main if `hetcond' & female==0
      }
      if `z'==2 {
        if `i'==1 qui reg std_incentivized_risk std_cgi_main `controls' if `hetcond' & female==0
        if `i'==2 qui reg std_incentivized_risk std_cgi_main `controls' if `hetcond' & female==0
        if `i'==3 qui reg incentivized_competitiveness std_cgi_main `controls' if `hetcond' & female==0
        if `i'==4 qui reg rho std_cgi_main `controls' if `hetcond' & female==0
        if `i'==5 qui reg std_incentivized_overconfidence std_cgi_main `controls' if `hetcond' & female==0
      }
      est store male_`col'

      suest female_`col' male_`col', vce(robust)
      lincom _b[female_`col'_mean:std_cgi_main] - _b[male_`col'_mean:std_cgi_main]
      local panelD_test_`col': di %6.3f r(p)
      local panelD_test_`col' = trim("$`panelD_test_`col''$")

      *--- Mean of dependent variable within subsample ---
      if `i'==1 | `i'==2 {
        qui su std_incentivized_risk if `hetcond'
        local mean_`col': di %6.0f round(r(mean), 1)
      }
      if `i'==3 {
        qui su incentivized_competitiveness if `hetcond'
        local mean_`col': di %6.3f r(mean)
      }
      if `i'==4 {
        qui su rho if `hetcond'
        local mean_`col': di %6.3f r(mean)
      }
      if `i'==5 {
        qui su std_incentivized_overconfidence if `hetcond'
        local mean_`col': di %6.0f round(r(mean), 1)
      }

    } // end het loop
  } // end i loop


*-----------------------------------------------------------------------------
* Write the Results
*-----------------------------------------------------------------------------

  foreach filepath in `"$out_path/Tables_nonhetero/`tableid'.tex"' {

    if `z'==1 {
      file open resultsfile using `"`filepath'"', write replace
    }
    if `z'==2 {
      local fp_ctrl = subinstr(`"`filepath'"', ".tex", "_controls.tex", .)
      file open resultsfile using `"`fp_ctrl'"', write replace
    }

    *--- Header ---
    if `z'==1 {
      file write resultsfile "\caption{CGI and Incentivized Behavioral Measures by Sexual Orientation}"
      file write resultsfile "\label{table 3}"
    }
    if `z'==2 {
      file write resultsfile "\caption{CGI and Incentivized Behavioral Measures by Sexual Orientation (with controls)}"
    }

    file write resultsfile "\centering"
    file write resultsfile "\centering"
file write resultsfile "\begin{tabular}{p{2cm} M{1.6cm} M{1.6cm} M{1.6cm} M{1.6cm} M{1.6cm} M{1.6cm} M{1.6cm} M{1.6cm} M{1.6cm} M{1.6cm} M{1.6cm} M{1.6cm}}"
    file write resultsfile "\toprule \toprule"
    file write resultsfile "\addlinespace[0.2cm]"
    file write resultsfile "\multicolumn{1}{l}{Measure} & \multicolumn{4}{c}{Risk} & \multicolumn{2}{c}{Competitiveness} & \multicolumn{2}{c}{Efficiency} & \multicolumn{2}{c}{Overconfidence} \\"
    file write resultsfile "\cmidrule(lr){2-5} \cmidrule(lr){6-7} \cmidrule(lr){8-9} \cmidrule(lr){10-11}"
    file write resultsfile "\multicolumn{1}{l}{Sample} & \multicolumn{2}{c}{Swiss Uni} & \multicolumn{2}{c}{US Adults} & \multicolumn{2}{c}{Swiss Uni} & \multicolumn{2}{c}{Swiss Uni} & \multicolumn{2}{c}{Swiss Uni} \\"
    file write resultsfile "\cmidrule(lr){2-3} \cmidrule(lr){4-5} \cmidrule(lr){6-7} \cmidrule(lr){8-9} \cmidrule(lr){10-11}"
    file write resultsfile " & Incl. non-het & Excl. non-het & Incl. non-het & Excl. non-het & Incl. non-het & Excl. non-het & Incl. non-het & Excl. non-het & Incl. non-het & Excl. non-het \\"
    file write resultsfile " & (1) & (2) & (3) & (4) & (5) & (6) & (7) & (8) & (9) & (10) \\"
    file write resultsfile "\midrule"
    file write resultsfile "\addlinespace[0.2cm]"

    *--- Panel A ---
    file write resultsfile "\multicolumn{11}{l}{\textbf{Panel A. Binary gender}} \\" _n
    file write resultsfile "\multicolumn{1}{l}{Female}"
    forvalues col=1/10 {
      file write resultsfile " & $`beta_a_sex_`col''$"
    }
    file write resultsfile " \\" _n
    file write resultsfile " "
    forvalues col=1/10 {
      file write resultsfile " & (`se_a_sex_`col'')"
    }
    file write resultsfile " \\" _n
    file write resultsfile "\addlinespace[0.1cm]"
    file write resultsfile "\multicolumn{1}{l}{$\text{R}^2$}"
    forvalues col=1/10 {
      file write resultsfile " & `rsqua_`col''"
    }
    file write resultsfile " \\ \\" _n
    file write resultsfile "\addlinespace[-0.3cm]"
    file write resultsfile "\midrule"

    *--- Panel B ---
    file write resultsfile "\multicolumn{11}{l}{\textbf{Panel B. Gender identity}} \\" _n
    file write resultsfile "\multicolumn{1}{l}{CGI (feminine)}"
    forvalues col=1/10 {
      file write resultsfile " & $`beta_b_cgi_`col''$"
    }
    file write resultsfile " \\" _n
    file write resultsfile " "
    forvalues col=1/10 {
      file write resultsfile " & (`se_b_cgi_`col'')"
    }
    file write resultsfile " \\" _n
    file write resultsfile "\addlinespace[0.1cm]"
    file write resultsfile "\multicolumn{1}{l}{$\text{R}^2$}"
    forvalues col=1/10 {
      file write resultsfile " & `rsqub_`col''"
    }
    file write resultsfile " \\ \\" _n
    file write resultsfile "\addlinespace[-0.3cm]"
    file write resultsfile "\midrule"

    *--- Panel C ---
    file write resultsfile "\multicolumn{11}{l}{\textbf{Panel C. Binary gender and gender identity}} \\" _n
    file write resultsfile "\multicolumn{1}{l}{Female}"
    forvalues col=1/10 {
      file write resultsfile " & $`beta_c_sex_`col''$"
    }
    file write resultsfile " \\" _n
    file write resultsfile " "
    forvalues col=1/10 {
      file write resultsfile " & (`se_c_sex_`col'')"
    }
    file write resultsfile " \\ \\" _n
    file write resultsfile "\addlinespace[-0.3cm]"
    file write resultsfile "\multicolumn{1}{l}{CGI (feminine)}"
    forvalues col=1/10 {
      file write resultsfile " & $`beta_c_cgi_`col''$"
    }
    file write resultsfile " \\" _n
    file write resultsfile " "
    forvalues col=1/10 {
      file write resultsfile " & (`se_c_cgi_`col'')"
    }
    file write resultsfile " \\" _n
    file write resultsfile "\addlinespace[0.1cm]"
    file write resultsfile "\multicolumn{1}{l}{$\text{R}^2$}"
    forvalues col=1/10 {
      file write resultsfile " & `rsquc_`col''"
    }
    file write resultsfile " \\ \\" _n
    file write resultsfile "\addlinespace[-0.3cm]"
    file write resultsfile "\midrule"

    *--- Panel D ---
    file write resultsfile "\multicolumn{11}{l}{\textbf{Panel D. Sample split by binary gender}} \\" _n
    file write resultsfile "\multicolumn{1}{l}{Female: CGI (feminine)}"
    forvalues col=1/10 {
      file write resultsfile " & $`beta_f_cgi_`col''$"
    }
    file write resultsfile " \\" _n
    file write resultsfile " "
    forvalues col=1/10 {
      file write resultsfile " & (`se_f_cgi_`col'')"
    }
    file write resultsfile " \\" _n
    file write resultsfile "\addlinespace[0.1cm]"
    file write resultsfile "\multicolumn{1}{l}{$\text{R}^2$}"
    forvalues col=1/10 {
      file write resultsfile " & `rsquf_`col''"
    }
    file write resultsfile " \\ \\" _n
    file write resultsfile "\addlinespace[-0.3cm]"

    file write resultsfile "\multicolumn{1}{l}{Male: CGI (feminine)}"
    forvalues col=1/10 {
      file write resultsfile " & $`beta_m_cgi_`col''$"
    }
    file write resultsfile " \\" _n
    file write resultsfile " "
    forvalues col=1/10 {
      file write resultsfile " & (`se_m_cgi_`col'')"
    }
    file write resultsfile " \\" _n
    file write resultsfile "\addlinespace[0.1cm]"
    file write resultsfile "\multicolumn{1}{l}{$\text{R}^2$}"
    forvalues col=1/10 {
      file write resultsfile " & `rsqum_`col''"
    }
    file write resultsfile " \\ \\" _n
    file write resultsfile "\addlinespace[-0.3cm]"

    file write resultsfile "\multicolumn{11}{l}{Test: male sample split CGI = female sample split CGI} \\" _n
    file write resultsfile "\addlinespace[-0.6cm]"
    file write resultsfile "\multicolumn{1}{l}{p-value}"
    forvalues col=1/10 {
      file write resultsfile " & $`panelD_test_`col''$"
    }
    file write resultsfile " \\" _n
    file write resultsfile "\addlinespace[-0.5cm]"
    file write resultsfile "\midrule"

    *--- Observations ---
    file write resultsfile "\multicolumn{1}{l}{Observations}"
    forvalues col=1/10 {
      file write resultsfile " & `N_`col''"
    }
    file write resultsfile " \\ \\" _n
    file write resultsfile "\addlinespace[-0.3cm]"

    *--- Mean of dependent variable ---
    file write resultsfile "\multicolumn{1}{l}{Mean of Dependent Variable}"
    forvalues col=1/10 {
      file write resultsfile " & `mean_`col''"
    }
    file write resultsfile " \\ \\" _n
    file write resultsfile "\addlinespace[-0.3cm]"

    file write resultsfile "\bottomrule\bottomrule"
    file write resultsfile "\end{tabular}"
    file close resultsfile

  } // end foreach filepath

} // end z loop
