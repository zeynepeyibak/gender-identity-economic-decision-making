clear all

global out_path "$path/3_out" 
cd "$path/1_data/4_temp"

use "$path/1_data/2_prepared/1_usadults_w2_20_60.dta", replace

local colno "14"
local gender_measures cgi_main tmf_score magliozzi_fem magliozzi_mas wangnerud_fem wangnerud_mas osri_fem osri_mas cfni_score cmni_score bsri_fem bsri_masc cgi_other cgi_own
local variables redistribution competitiveness hypothetical_risk incentivized_risk major_share homemaker income_cont yearly_work_hours_weeklyaverage negot_yes manager financial_market

foreach v of local variables {
    local i = 1
    foreach g of local gender_measures {
        preserve
        drop *_1 *_2 *_3 *_NPS_GROUP
        drop if `v'==.
        drop if std_`g'==.
        drop std_`g'
        qui su `g'
        gen std_`g' = (`g' - r(mean)) / r(sd)
        if inlist("`v'", "redistribution", "hypothetical_risk", "incentivized_risk", "competitiveness") {
            qui su `v' if std_`g'!=.
            replace `v' = (`v' - r(mean)) / r(sd)
        }
        qui reg `v' std_`g', vce(hc3)
        local rsqub_`i'_meta = e(r2)
        restore
        local i = `i' + 1
    }

*-----------------------------------------------------------------------------
* Store Panel B R2 for meta analysis
*-----------------------------------------------------------------------------
    preserve
        clear
        set obs `colno'
        gen rsqub    = .
        gen variable = ""
        gen measure  = ""
        gen col_num  = .

        forvalues i = 1/`colno' {
            replace rsqub   = `rsqub_`i'_meta' in `i'
            replace col_num = `i'              in `i'
        }

        replace measure = "CGI"            in 1
        replace measure = "tmf"            in 2
        replace measure = "magliozzi fem"  in 3
        replace measure = "magliozzi masc" in 4
        replace measure = "wangnerud fem"  in 5
        replace measure = "wangnerud mas"  in 6
        replace measure = "osri fem"       in 7
        replace measure = "osri masc"      in 8
        replace measure = "cfni"           in 9
        replace measure = "cmni"           in 10
        replace measure = "bsri fem"       in 11
        replace measure = "bsri masc"      in 12
        replace measure = "CGI (other)"    in 13
        replace measure = "CGI (own)"      in 14

        local vname = "`v'"
        if "`v'" == "yearly_work_hours_weeklyaverage" local vname "workhours"
        replace variable = "`vname'"

        save "$path/1_data/5_meta/5_R2_other/panelb_`v'.dta", replace
    restore

} // end foreach v

*-----------------------------------------------------------------------------
* Append, reshape, and save wide
*-----------------------------------------------------------------------------
clear
foreach v of local variables {
    append using "$path/1_data/5_meta/5_R2_other/panelb_`v'.dta"
    erase "$path/1_data/5_meta/5_R2_other/panelb_`v'.dta"
}

reshape wide rsqub, i(measure col_num) j(variable) string

rename rsqubcompetitiveness  competitive
rename rsqubredistribution   redistribution
rename rsqubhypothetical_risk risk_unincent
rename rsqubincentivized_risk risk_incent
rename rsqubmajor_share       female_educ
rename rsqubhomemaker         homemaker
rename rsqubincome_cont       income
rename rsqubworkhours         workhours
rename rsqubnegot_yes         wagenegot
rename rsqubmanager           managresp
rename rsqubfinancial_market  risk_financ

gen scale = ""
gen items = .

replace scale = "CGI"       if measure == "CGI"
replace scale = "TMF"       if measure == "tmf"
replace scale = "Mag_F"     if measure == "magliozzi fem"
replace scale = "Mag_M"     if measure == "magliozzi masc"
replace scale = "SOM_F"     if measure == "wangnerud fem"
replace scale = "SOM_M"     if measure == "wangnerud mas"
replace scale = "OSRI_F"    if measure == "osri fem"
replace scale = "OSRI_M"    if measure == "osri masc"
replace scale = "CFNI"      if measure == "cfni"
replace scale = "CMNI"      if measure == "cmni"
replace scale = "BSRI_F"    if measure == "bsri fem"
replace scale = "BSRI_M"    if measure == "bsri masc"
replace scale = "CGI_other" if measure == "CGI (other)"
replace scale = "CGI_own"   if measure == "CGI (own)"

replace items = 1  if measure == "CGI"
replace items = 6  if measure == "tmf"
replace items = 1  if measure == "magliozzi fem"
replace items = 1  if measure == "magliozzi masc"
replace items = 1  if measure == "wangnerud fem"
replace items = 1  if measure == "wangnerud mas"
replace items = 11 if measure == "osri fem"
replace items = 11 if measure == "osri masc"
replace items = 45 if measure == "cfni"
replace items = 30 if measure == "cmni"
replace items = 10 if measure == "bsri fem"
replace items = 10 if measure == "bsri masc"
replace items = 1  if measure == "CGI (other)"
replace items = 1  if measure == "CGI (own)"

sort col_num
drop measure col_num
order scale items risk_incent risk_unincent risk_financ competitive ///
      redistribution female_educ income homemaker workhours managresp wagenegot

save "$path/1_data/5_meta/5_R2_other/Rsquared_across_measures.dta", replace
