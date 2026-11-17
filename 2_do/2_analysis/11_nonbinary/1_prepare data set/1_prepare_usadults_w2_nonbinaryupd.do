clear all

global out_path "$path/3_out" 
"$path/1_data/4_temp"			
			
numlabel, add

*-----------------------------------------------------------------------------
* Import Qualtrics
*-----------------------------------------------------------------------------
* 30-60
import excel "$path/1_data/1_rawdata/usadults_w2/cgi_validation_30-60_qualtrics_230321.xlsx", sheet("Sheet0") firstrow clear

* Label/Organize variables
foreach var of varlist * {
	replace `var' = subinstr(`var', `"""', "", .) if _n==1
	 label variable `var' "`=`var'[1]'"
} 
drop if _n==1 // Bc variable labels are in the first obsv

tempfile qualtrics_30_60
save `qualtrics_30_60', replace

* 20-29 
import excel "$path/1_data/1_rawdata/usadults_w2/cgi_validation_20-29_qualtrics_230315.xlsx", sheet("Sheet0") firstrow clear

* Label/Organize variables
foreach var of varlist * {
	replace `var' = subinstr(`var', `"""', "", .) if _n==1
	 label variable `var' "`=`var'[1]'"
} 

* Merge the study_field variable into one variable
/*
For 30-60, study_field variable is collected and for 20-29, study_field_current and past variables are collected
*/
gen study_field=study_field_current
replace study_field=study_field_past if study_field==""
gen study_field_11_TEXT=study_field_current_11_TEXT if study_field=="Other, please specify"
replace study_field_11_TEXT=study_field_past_11_TEXT if study_field_11_TEXT=="" & study_field=="Other, please specify"
drop study_field_past* study_field_current*

drop if _n==1 // Bc variable labels are in the first obsv

tempfile qualtrics_20_29
save `qualtrics_20_29', replace

* Append 
append using `qualtrics_30_60'

* Keep the ones that were finished and consented
keep if Finished=="True" //0 obsv deleted
keep if Consent == "I agree" //3 obsv deleted
drop Finished Consent


* check for duplicates
duplicates list prolific_id // no duplicates

* Rename age
rename age age_qualtrics

* save 
tempfile qualtrics_20_60
save `qualtrics_20_60', replace

*-----------------------------------------------------------------------------
* Import Prolific
*-----------------------------------------------------------------------------
** 20-29
import excel "$path/1_data/1_rawdata/usadults_w2/cgi_validation_20-29_prolific_230321.xlsx", sheet("cgi_validation_20-29_prolific_d") firstrow clear

tempfile prolific_20_29
save `prolific_20_29', replace

** 30-39 
import excel "$path/1_data/1_rawdata/usadults_w2/cgi_validation_30-39_prolific_230321.xlsx", sheet("cgi_validation_30-39_prolific_d") firstrow clear

tempfile prolific_30_39
save `prolific_30_39',replace

** 40-49 
import excel "$path/1_data/1_rawdata/usadults_w2/cgi_validation_40-49_prolific_230321.xlsx", sheet("cgi_validation_40-49_prolific_d") firstrow clear

tempfile prolific_40_49
save `prolific_40_49', replace
 
** 50-60 
import excel "$path/1_data/1_rawdata/usadults_w2/cgi_validation_50-60_prolific_230321.xlsx", sheet("cgi_validation_50-60_prolific_d") firstrow clear

tempfile prolific_50_60
save `prolific_50_60', replace

* append
clear all
local age 20_29 30_39 40_49 50_60
foreach age in `age' {
append using `prolific_`age''
}

* Rename 
rename Participantid prolific_id

* rename age
rename Age age_prolific

* Sanity checks
duplicates list prolific_id //no duplicates
count 

* save
tempfile prolific_20_60
save `prolific_20_60', replace

*-----------------------------------------------------------------------------
* Merge Qualtrics and  Prolific
*-----------------------------------------------------------------------------
merge 1:1 prolific_id using `qualtrics_20_60' // 3 left in master, 1 left in using, these left will be dropped by the sample selection below. 

count // 2,805

** Sample Selection analysis for age 30-60
preserve 
drop if STUDY_ID == "6410819079fb0bd36e5d6bf0" | STUDY_ID == "6410819079fb0bd36e5d6bf1" // age 20s
* Missing sex drop
drop if Sex=="" 
drop if assigned_sex== "" 
drop if biological_gender== "" 
drop if Sex=="CONSENT_REVOKED" 
count //(real count) 2000

* Drop nonbinary
drop if gender_own=="Non-binary" //28 observations deleted)

* Inconsistent sex
keep if (Sex == "Female" & assigned_sex == "Female" & biological_gender=="Female") | (Sex == "Male" & assigned_sex == "Male" & biological_gender=="Male") // 25  obs deleted. 

drop if attention_screening2!="Strongly agree,Strongly disagree" | attention_1!="17" //39 obs deleted.
count //1,908 (remaining count)
restore


** Sample Selection analysis for age 20-30
preserve 
keep if STUDY_ID == "6410819079fb0bd36e5d6bf0" | STUDY_ID == "6410819079fb0bd36e5d6bf1" // age 20s

* Missing sex drop
drop if Sex=="" 
drop if assigned_sex== "" 
drop if biological_gender== "" 
drop if Sex=="CONSENT_REVOKED" 
count //(real count) 800

* Drop nonbinary
drop if gender_own=="Non-binary" // 30 observations deleted)

* Inconsistent sex
keep if (Sex == "Female" & assigned_sex == "Female" & biological_gender=="Female") | (Sex == "Male" & assigned_sex == "Male" & biological_gender=="Male") // 12  obs deleted. 

drop if attention_screening2!="Strongly agree,Strongly disagree" | attention_1!="17" //7 obs deleted.
count //751 (remaining count)
restore


** Sample Selection Analysis for Age 20-60
* Missing sex drop 
drop if Sex=="" // 1 obs deleted
drop if assigned_sex== "" // 0 obs deleted
drop if biological_gender== "" // 0 obs deleted
drop if Sex=="CONSENT_REVOKED" // 1 obs deleted
count //2800

* Drop nonbinary
// drop if gender_own=="Non-binary" // for the non-binary analysis, we keep these observations

assert gender_own!=""
gen non_binary=gender_own=="Non-binary"

* Inconsistent sex
keep if (Sex == "Female" & assigned_sex == "Female" & biological_gender=="Female") | (Sex == "Male" & assigned_sex == "Male" & biological_gender=="Male") | non_binary==1 // 37 obs deleted. 

* Drop obs who failed the attention check
drop if attention_screening2!="Strongly agree,Strongly disagree" | attention_1!="17" // 47 obs deleted.
drop attention_screening2 attention_1

count // 2,659

assert _merge==3
drop _merge

*-----------------------------------------------------------------------------
* Rename and Label Variables
*-----------------------------------------------------------------------------

* Rename
rename firstorderscale_1 magliozzi_fem
rename firstorderscale_2 magliozzi_masc
rename cont_gender_1 cgi_main
rename cont_gender_other_1 cgi_other
rename cont_gender_male_1 cgi_male
rename cont_gender_female_1 cgi_female

* Organize bsri* osri*  cmni*  cfni*
foreach var of varlist bsri* osri*  cmni*  cfni* {
* suppress spaces 	
replace `var'= subinstr(`var', "`=char(10)'", " ", .)
replace `var' = "Slightly disagree" if `var' == "Slightly disagree "
* assign values to the five Agree-Disagree categories
replace `var' = "1" if `var' == "Disagree"
replace `var' = "2" if `var' == "Slightly disagree"
replace `var' = "3" if `var' == "Neutral"
replace `var' = "4" if `var' == "Slightly agree"
replace `var' = "5" if `var' == "Agree"
assert inlist(`var', "1", "2", "3", "4", "5", "") //check
}

* Drop the str after the numerical value of the tmf*  magliozzi* variables 
foreach var of varlist tmf*  magliozzi* {
replace `var'= subinstr(`var', "`=char(10)'", " ", .)
replace `var' = "0" if `var' == "0 - Very masculine"
replace `var' = "6" if `var' == "6 - Very feminine"
replace `var' = "0" if `var' == "0 - Not at all"
replace `var' = "6" if `var' == "6 - Very"	
assert inlist(`var', "0", "1", "2", "3", "4", "5", "6") //check
}


* Destring 
foreach var of varlist * {
	destring `var', replace
}

*-----------------------------------------------------------------------------
* Scoring System 
*-----------------------------------------------------------------------------

* Scoring system for BSRI
gen bsri_masc = (bsri_30_1 + bsri_30_4 + bsri_30_7 + bsri_30_10 + bsri_30_13 + bsri_30_16 + bsri_30_19 + bsri_30_22 + bsri_30_25 + bsri_30_28)/10
gen bsri_fem = (bsri_30_2 + bsri_30_5 + bsri_30_8 + bsri_30_11 + bsri_30_14 + bsri_30_17 + bsri_30_20 + bsri_30_23 + bsri_30_26 + bsri_30_29)/10

* Scoring system for OSRI
gen osri_masc = (osri_1 + osri_2 + osri_5 + osri_7 + osri_11 + osri_12 + osri_13 + osri_14 + osri_18 + osri_19 + osri_22)
gen osri_fem = (osri_3 + osri_4 + osri_6 + osri_8 + osri_9 + osri_10 + osri_15 + osri_16 + osri_17 + osri_20 + osri_21) 

* Scoring system for CFNI
gen cfni_score_normal = (cfni45_1 + cfni45_2 + cfni45_3 + cfni45_5 + cfni45_7 + cfni45_9 + cfni45_11 + cfni45_12 + cfni45_13 + cfni45_14 + cfni45_17 + cfni45_19 + cfni45_23 + cfni45_24 + cfni45_25 + cfni45_28 + cfni45_31 + cfni45_32 + cfni45_33 + cfni45_36 + cfni45_41 + cfni45_42 + cfni45_43 + cfni45_45)    
gen cfni_score_reversed = ((6 - cfni45_4) + (6 - cfni45_6) + (6 - cfni45_8) + (6 - cfni45_10) + (6 - cfni45_15) + (6 - cfni45_16) + (6 - cfni45_18) + (6 - cfni45_20) + (6 - cfni45_21) + (6 - cfni45_22) + (6 - cfni45_26) + (6 - cfni45_27) + (6 - cfni45_29) + (6 - cfni45_30) + (6 - cfni45_34) + (6 - cfni45_35) + (6 - cfni45_37) + (6 - cfni45_38) + (6 - cfni45_39) + (6 - cfni45_40) + (6 - cfni45_44)) // Reversed scores are 1 -> 5 (or 6-1),  2 -> 4 (or 6-2),  3 -> 3 (or 6-3), 4 -> 2 (or 6-4), 5 -> 1 (or 6-5)  
gen cfni_score = cfni_score_normal + cfni_score_reversed
 
* Scoring system for CMNI
gen cmni_score_normal = (cmni30_2 + cmni30_4 + cmni30_6 + cmni30_7 + cmni30_8 + cmni30_10 + cmni30_11 + cmni30_12 + cmni30_14 + cmni30_16 +  cmni30_17 + cmni30_19 + cmni30_20 + cmni30_21 + cmni30_23 + cmni30_24 + cmni30_25 + cmni30_26 + cmni30_27 + cmni30_29 + cmni30_30)
 gen cmni_score_reversed = ((6 - cmni30_1) + (6 - cmni30_3) + (6 - cmni30_5) + (6 - cmni30_9) + (6 - cmni30_13) + (6 - cmni30_15) + (6 - cmni30_18) + (6 - cmni30_22) + (6 - cmni30_28))
gen cmni_score = cmni_score_normal + cmni_score_reversed

* Scoring system for TMF scale scores 
gen tmf_score = (tmf_masculin_feminin_1 +tmf_masculin_feminin_2 + tmf_masculin_feminin_3 + tmf_masculin_feminin_4 +tmf_masculin_feminin_5 + tmf_masculin_feminin_6)/6

***The score of the TMF is calculated as the average score of its 6 items. 
*** Beware in any potential comparison that my scale is 0-6, while the scale in Johanna's thesis was 1-7. However, with standardized average these are comparable.

*-----------------------------------------------------------------------------
* Standardize the scores (in order to be able to make comparisons bw them)
*-----------------------------------------------------------------------------

* BSRI (Fem)
su bsri_fem
gen std_bsri_fem = (bsri_fem -r(mean))/r(sd)

* BSRI (Masc)
su bsri_masc
gen std_bsri_masc = (bsri_masc -r(mean))/r(sd)

* OSRI (Fem)
su osri_fem
gen std_osri_fem = (osri_fem -r(mean))/r(sd)

* OSRI (Masc)
su osri_masc
gen std_osri_masc = (osri_masc -r(mean))/r(sd)

* CMNI
su cmni_score
gen std_cmni_score = (cmni_score -r(mean))/r(sd)

* CFNI
su cfni_score
gen std_cfni_score = (cfni_score -r(mean))/r(sd)

* Two-dimensional scale - Magliozzi (Fem)
su magliozzi_fem
gen std_magliozzi_fem = (magliozzi_fem -r(mean))/r(sd)

* Two-dimensional scale - Magliozzi (Masc)
su magliozzi_masc
gen std_magliozzi_masc = (magliozzi_masc -r(mean))/r(sd)

* TMF
su tmf_score
gen std_tmf_score = (tmf_score -r(mean))/r(sd)

* Markstedt (Fem)
su wangnerud_feminine
gen std_wangnerud_feminine = (wangnerud_feminine -r(mean))/r(sd)

* Markstedt (Masc)
su wangnerud_masculine
gen std_wangnerud_masculine = (wangnerud_masculine-r(mean))/r(sd)

*-----------------------------------------------------------------------------
* Gen PCA First Component
*-----------------------------------------------------------------------------

* PCA for BSRI participants (std_bsri_fem and std_bsri_masc)
pca std_tmf_score std_magliozzi_fem std_magliozzi_masc std_wangnerud_feminine std_wangnerud_masculine std_bsri_fem std_bsri_masc
predict pc1
generate first_component_bsri = pc1
drop pc1

* PCA for OSRI participants (std_osri_fem  and std_osri_masc)
pca std_tmf_score std_magliozzi_fem std_magliozzi_masc std_wangnerud_feminine std_wangnerud_masculine std_osri_fem std_osri_masc
predict pc1 
generate first_component_osri = pc1
drop pc1

* PCA for CMNI participants (std_cmni_score)
pca std_tmf_score std_magliozzi_fem std_magliozzi_masc std_wangnerud_feminine std_wangnerud_masculine std_cmni_score
predict pc1 
generate first_component_cmni = pc1
drop pc1

* PCA for CFNI participants (std_cfni_score)
pca std_tmf_score std_magliozzi_fem std_magliozzi_masc std_wangnerud_feminine std_wangnerud_masculine std_cfni_score
predict pc1
generate first_component_cfni = pc1
drop pc1

* Standardized pca first component
su first_component_bsri
gen std_first_component_bsri = (first_component_bsri -r(mean))/r(sd)

su first_component_osri
gen std_first_component_osri = (first_component_osri -r(mean))/r(sd)

su first_component_cmni
gen std_first_component_cmni = (first_component_cmni -r(mean))/r(sd)

su first_component_cfni
gen std_first_component_cfni = (first_component_cfni -r(mean))/r(sd)


* Create a variable first_component which is a "merged" column of bsri, osri, cmni and cfni
*** I "merge" it as all values are mutually exclusive and it will result in a column that has all values of the first componets bsri, osri, cmni and cfni. 
gen first_component = max(first_component_bsri, first_component_osri, first_component_cmni, first_component_cfni) 

su first_component
gen std_first_component = (first_component -r(mean))/r(sd)


* final Sanity checks
assert Progress==100
drop Progress RecipientLastName RecipientFirstName RecipientEmail ExternalReference

* Age sanity checks
replace age_prolific="" if age_prolific=="DATA_EXPIRED"
destring age_prolific, replace
gen age_diff=age_qualtrics-age_prolific
tab age_diff
drop age_diff

* drop click variables
drop *_FirstClick *_LastClick *_PageSubmit *_ClickCount

* Rename variables s.t. they are consistent with wave1
rename Startedat started_datetime
rename Completedat completed_datetime
rename Timetaken time_taken
rename Totalapprovals num_approvals
rename Status status
drop Reviewedat Archivedat
assert Language=="English"
drop Language
drop Submissionid Completioncode
rename hypothetical_risk_1 hypothetical_risk
rename competitiveness_1 competitiveness
rename redistribution_1 redistribution
rename incentivized_risk_1 incentivized_risk
rename Employmentstatus employmentstatus
rename Studentstatus studentstatus
drop meta_question_*
rename SESSION_ID session_id
drop payment1 bonus1 bonus0 payment0

save "$path/2_do/2_analysis/11_nonbinary/0_usadults_w2_20_60.dta", replace
