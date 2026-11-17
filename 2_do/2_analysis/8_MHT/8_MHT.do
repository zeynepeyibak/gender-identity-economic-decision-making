clear all

global out_path "$path/3_out" 
		
			
numlabel, add
do "$path/2_do/2_analysis/0_reg_fnc/0_regressions.do"
	
use "$path/1_data/2_prepared/1_usadults_w1_w2_20_60.dta", clear
keep if Wave==1
rename yearly_work_hours_weeklyaverage weeklyaverage_workhr

global DESCVARS no_schooling high_school ged some_college one_year_college associate bachelor master doctorate professional major_share employed self_employed relative_assisting in_education homemaker child_leave long_term_illness retired unemployed other_employment  private_sector industry_share income_cont weeklyaverage_workhr work_hours yes_work_changes pers_leave manager perf_pay_yes negot_yes 

* Label variables for use in table.
la var no_schooling "No Schooling Completed"
la var high_school "Regular High School Diploma"
la var ged "GED or Alternative Credential"
la var some_college "Some College Credit (less than 1 year)"
la var one_year_college "1 or more Years of College Credit, No Degree"
la var associate "Associate's Degree"
la var bachelor "Bachelor's Degree"
la var master "Master's Degree"
la var doctorate "Doctorate Degree"
la var professional "Professional Degree Beyond a Bachelor's Degree"
la var major_share "Female Educational Track Share"

la var employed "Employed"
la var self_employed "Self-employed"
la var relative_assisting "Relative Assisting on a Farm or Business"
la var in_education "In Full Time Education (at school, university, etc.)"
la var homemaker "Full Time Homemaker"
la var child_leave "Currently on Child-care Leave or other Leave"
la var long_term_illness "Unable to Work due to Long Term Illness or Disability"
la var retired "Retired"
la var unemployed "Unemployed"
la var other_employment "Other"

//la var gov_sector "Government Sector Employee"
la var private_sector "Private Sector Employee"
la var industry_share "Female Industry"
la var income_cont "Income (in thousand US dollars)"

la var weeklyaverage_workhr "Weekly Ave. Work Hours"
la var work_hours "Work flexibility (0 No flexibility, 1 Full flexibility)"
la var yes_work_changes "Changes to Working Arrangements (0 No, 1 Yes)"
la var pers_leave "Take off an Hour for Personal Matters (0 Very difficult, 4 Very easy)"
la var manager "Managerial Responsibilities (0 No, 1 Yes)"
la var perf_pay_yes "Perfomance Pay (0 No, 1 Yes)"
la var negot_yes "Wage Negotiation (0 No, 1 Yes)"

cap file close resultsfile	
file open resultsfile using "$out_path/MHT/US_Wave1_Diff_1.tex", write replace
file write resultsfile "\begin{table}[H]" _n
file write resultsfile "\begin{adjustbox}{max width=14cm}" _n
file write resultsfile "\hspace{-2cm}" _n
file write resultsfile "\begin{threeparttable}" _n
file write resultsfile "\caption{Descriptive Statistics: Education and Labor Market}" _n
file write resultsfile "\begin{tabular}{lllllllll}" _n
file write resultsfile "\hline" _n
file write resultsfile "\addlinespace[0.2cm]" _n
file write resultsfile "& \multicolumn{2}{c}{Mean} & Difference  \\" _n
file write resultsfile "\cmidrule(lr){2-3}" _n
file write resultsfile "& Male & Female &  \\" _n
file write resultsfile "& (1) & (2) & (3)  \\" _n
file write resultsfile "\hline" _n


local t = 1

foreach var in $DESCVARS {
		
	* Get variable label.
	local varname: var la `var'

	* Control mean and sd.
	su `var' if female == 0
	local col1_mean: di %6.2f r(mean)
	local col1_mean = trim("`col1_mean'")
	local N_col1: di %6.0f r(N) 
	local N_col1 = trim("`N_col1'")
	
	su `var' if female == 1
	local col2_mean: di %6.2f r(mean)
	local col2_mean = trim("`col2_mean'")
	local N_col2: di %6.0f r(N) 
	local N_col2 = trim("`N_col2'")

	* p-value difference
	qui reg `var' female 

	local col3_beta: di %6.2f _b[female]
	local col3_beta = subinstr("`col3_beta'","-","\llap{-}", .)
	
	** MHT Education: no_schooling high_school ged some_college one_year_college associate bachelor master doctorate professional major_share
	if `t' ==1 | `t' ==2 | `t' ==3 | `t' ==4 | `t' ==5 | `t' ==6 | `t' ==7 | `t' ==8 | `t' ==9 | `t' ==10 | `t' ==11 {
rwolf2 (reg no_schooling female, vce(hc3)) (reg high_school female, vce(hc3)) (reg ged female, vce(hc3)) (reg some_college female, vce(hc3)) (reg one_year_college female, vce(hc3)) (reg associate female, vce(hc3)) (reg bachelor female, vce(hc3)) (reg master female, vce(hc3)) (reg doctorate female, vce(hc3)) (reg professional female, vce(hc3)) (reg major_share female, vce(hc3)), indepvars(female, female, female, female, female, female, female, female, female, female, female) seed(1234) reps(250)

		
	local pval: di e(rw_`var'_female)
	
	if `pval' > .01 & `pval' <= .05 {
		local col3_diff = "`col3_beta'\rlap{*}"
	}
	else if `pval' > .005 & `pval' <= .01 {
		local col3_diff = "`col3_beta'\rlap{**}"
	}
	else if `pval' <= .005 {
		local col3_diff = "`col3_beta'\rlap{***}"
	}
	else {
		local col3_diff = "`col3_beta'"	
	}
	
	}
	
	
	** MHT Labor Market: employed self_employed relative_assisting in_education homemaker child_leave long_term_illness retired unemployed other_employment gov_sector priv_sector industry_share  income_cont yearly_work_60 work_hours yes_work_changes pers_leave manager_yes perf_pay_yes negot_yes 
	if `t'>11 {
	rwolf2 (reg employed female, vce(hc3)) (reg self_employed female, vce(hc3)) (reg relative_assisting female, vce(hc3)) (reg in_education female, vce(hc3)) (reg homemaker female, vce(hc3)) (reg child_leave female, vce(hc3)) (reg long_term_illness female, vce(hc3)) (reg retired female, vce(hc3)) (reg unemployed female, vce(hc3)) (reg other_employment female, vce(hc3)) (reg private_sector female, vce(hc3)) (reg industry_share female, vce(hc3)) (reg income_cont female, vce(hc3)) (reg  weeklyaverage_workhr female, vce(hc3)) (reg work_hours female, vce(hc3)) (reg yes_work_changes female, vce(hc3)) (reg pers_leave female, vce(hc3)) (reg manager female, vce(hc3)) (reg perf_pay_yes female, vce(hc3)) (reg negot_yes female, vce(hc3)), indepvars(female, female, female, female, female, female, female, female, female, female, female, female, female, female, female, female, female, female, female, female) usevalid seed(1234) reps(250)	
	
	
	
	local pval: di e(rw_`var'_female)
	
	if `pval' > .01 & `pval' <= .05 {
		local col3_diff = "`col3_beta'\rlap{*}"
	}
	else if `pval' > .005 & `pval' <= .01 {
		local col3_diff = "`col3_beta'\rlap{**}"
	}
	else if `pval' <= .005 {
		local col3_diff = "`col3_beta'\rlap{***}"
	}
	else {
		local col3_diff = "`col3_beta'"	
	}
	
	}

	// Write headers when necessary.
	if "`var'" == "no_schooling" {
		file write resultsfile "\addlinespace[0.2cm]" _n
		file write resultsfile "\textbf{Education} & & & \\" _n
	}
	
	if "`var'" == "employed" {
		file write resultsfile "\addlinespace[0.2cm]" _n
		file write resultsfile "\textbf{Labor Market} & & & \\" _n
		file write resultsfile "\textit{Employment Status (respondents selected one response category)} & & & \\" _n
	}
	
	if "`var'" == "private_sector" {
		file write resultsfile "\addlinespace[0.2cm]" _n
		file write resultsfile "\textit{Sector and Industry} & & & \\" _n
	}

	if "`var'" == "income_cont" {
		file write resultsfile "\addlinespace[0.2cm]" _n
		file write resultsfile "\textit{Work Conditions} & & & \\" _n
	}


	file write resultsfile "\hspace{6mm} `varname' & $`col1_mean'$ & `col2_mean' & $`col3_diff'$ \\" _n
	
	local t =`t'+1
}

file write resultsfile "\addlinespace[.2cm]" _n
file write resultsfile "\textbf{Observations} & `N_col1' & `N_col2' &  \\" _n
file write resultsfile "\hline" _n
file write resultsfile "\end{tabular}" _n
file write resultsfile "\begin{tablenotes}" _n
file write resultsfile "\footnotesize" _n
file write resultsfile "\item \textit{Notes:} Multiple hypothesis test correction was done separately for the family of variables ""Labor Market"" and  ""Education"". US Sample - Wave 1 is used. Significance levels: *** p $<$ 0.005, ** p $<$ 0.01, * p $<$ 0.05" _n
file write resultsfile "\end{tablenotes}" _n
file write resultsfile "\end{threeparttable}" _n
file write resultsfile "\end{adjustbox}" _n
file write resultsfile "\end{table}" _n
file close resultsfile
