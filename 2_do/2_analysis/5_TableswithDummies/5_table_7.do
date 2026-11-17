clear all

global out_path "$path/3_out" 
		
local tableid "table_7"
local colno "8" 

* short code to save reg coeffs
do "$path/2_do/2_analysis/0_reg_fnc/0_regressions.do" // 2 tailed 



/* Table 9 
Column 1: Income - US Adults
Column 2: Full-time homemaker - US Adults
Column 3: Yearly working hours - US Adults
Column 4: Female industry share - US Adults (Wave 1)
Column 5: Managerial responibility - US Adults
Column 6: Performance Pay - US Adults (Wave 1)
Column 7: Wage Negotiation - US Adults
Column 8: Work Flexibility - US Adults (Wave 1)
//Column 9: Private Sector (Wave 1)
*/

forvalues z =1/1{ 
		local variables_8 income_cont homemaker yearly_work_hours_weeklyaverage industry_share  manager perf_pay_yes negot_yes std_work_hours 
		local i=1

foreach var of local variables_8 {
	use "$path/1_data/2_prepared/1_usadults_w1_w2_30_60.dta", replace   	
	local controls "c.age##c.age black all_other_races i.division wave1"
	
	
* Restandardize std_cgi_main as it was standardized for age 20-60.
		drop std_cgi_main
		qui su cgi_main
		qui gen std_cgi_main=(cgi_main-r(mean))/r(sd)
		
*-----------------------------------------------------------------------------
* Sanity checks with standardizations before we start the regression analysis
*-----------------------------------------------------------------------------
		qui su std_work_hours
		assert round(r(mean),0.0001)==0
		
		qui su std_cgi_main
		assert round(r(mean),0.0001)==0
		
		qui su std_cgi_main if `var'!=.
		
		if round(r(mean),0.0001)!=0	{
		drop std_cgi_main
		qui su cgi_main if `var'!=.
		gen std_cgi_main=(cgi_main-r(mean))/r(sd)
		}
		
*-----------------------------------------------------------------------------
* Panel A: biological gender	 
*-----------------------------------------------------------------------------
    if `z' ==1{
	qui reg `var' female, vce(hc3)
	}
	
	* Store the results
	local F`i'_a : di %9.3f e(F)
	local pval_F`i'_a : di %9.3f Ftail(e(df_m), e(df_r), e(F))	

*-----------------------------------------------------------------------------				
* Panel B: cgi	 
*-----------------------------------------------------------------------------	
	if `z' ==1{
    qui reg `var' ib5.cgi_main, vce(hc3)	
	}
	
	* Store the results
	local F`i'_b : di %9.3f e(F)
	local pval_F`i'_b : di %9.3f Ftail(e(df_m), e(df_r), e(F))
*-----------------------------------------------------------------------------				
* Panel C: biological gender and cgi 
*-----------------------------------------------------------------------------
	if `z' ==1{
    qui reg `var' ib5.cgi_main female, vce(hc3)	
	}
	
	** Store the results
		* F stat (overall)
		local F`i'_c : di %9.3f e(F)
		local pval_F`i'_c : di %9.3f Ftail(e(df_m), e(df_r), e(F))	
		
		* test: Binary sex=0
		test (female=0)
		local F`i'_c_fem : di %9.3f r(F) 
		local pval_F`i'_c_fem : di %9.3f r(p) 
		
		* Joint test: i.cgi_main=0
		test (0.cgi_main=0) (1.cgi_main = 0) (2.cgi_main = 0) (3.cgi_main = 0) (4.cgi_main = 0) (6.cgi_main = 0) (7.cgi_main = 0) (8.cgi_main = 0) (9.cgi_main = 0) (10.cgi_main = 0)
		local F`i'_c_cgi : di %9.3f r(F) 
		local pval_F`i'_c_cgi : di %9.3f r(p) 
		
		* Obs count
		local N_`i': di %11.0gc e(N)		
		
*-----------------------------------------------------------------------------				
* Panel D: cgi for males and cgi for females
*-----------------------------------------------------------------------------			
* Panel D for females: 
preserve
keep if female==1

		drop std_work_hours
		qui su work_hours
		qui gen std_work_hours =(work_hours -r(mean))/r(sd)	
		
		qui su std_work_hours
		assert round(r(mean),0.0001)==0
		
		drop std_cgi_main
		qui su cgi_main if `var'!=.
		gen std_cgi_main=(cgi_main-r(mean))/r(sd)
		

	if `z' ==1{
    qui reg `var' ib5.cgi_main if female == 1, vce(hc3)	  
	}
	
		* F stat (overall)
		local F`i'_f : di %9.3f e(F)
		local pval_F`i'_f : di %9.3f Ftail(e(df_m), e(df_r), e(F))	
		
restore

* Panel D for males: 
preserve
keep if female==0

		drop std_work_hours
		qui su work_hours
		qui gen std_work_hours =(work_hours -r(mean))/r(sd)	
		
		qui su std_work_hours
		assert round(r(mean),0.0001)==0
		
		drop std_cgi_main
		qui su cgi_main if `var'!=.
		gen std_cgi_main=(cgi_main-r(mean))/r(sd)
		
	if `z' ==1{
    qui reg `var' ib5.cgi_main if female == 0, vce(hc3)	 
	
		* F stat (overall)
		local F`i'_m : di %9.3f e(F)
		local pval_F`i'_m : di %9.3f Ftail(e(df_m), e(df_r), e(F))	

restore
local i=`i'+1		
}

}

*-----------------------------------------------------------------------------
*-----------------------------------------------------------------------------
* Write the Results
*-----------------------------------------------------------------------------
*-----------------------------------------------------------------------------
foreach path in out_path{
	
if `z' ==1{
        file open resultsfile using "$`path'/Tables_CGI_Dummies/table_7.tex", write replace
}	

*-----------------------------------------------------------------------------
* Write Table header
*-----------------------------------------------------------------------------
/*
file write resultsfile "\begin{table}[H]"
file write resultsfile "\centering"
file write resultsfile "\begin{adjustbox}{max width=16cm}"
file write resultsfile "\begin{threeparttable}"
*/
file write resultsfile "\caption{CGI and Labor Market Outcomes (with CGI dummies)}"
file write resultsfile "\begin{tabular}"
file write resultsfile "{p{1.7cm} M{2.4cm} M{2.4cm} M{2.6cm} M{2.7cm} M{2.4cm} M{2.4cm} M{2.4cm} M{2.4cm}}" 
file write resultsfile "\toprule\toprule"
file write resultsfile "\addlinespace[0.2cm]"
file write resultsfile "\multicolumn{1}{l}{Measure} & Income & \thead{Full-time \\ Homemaker}  & \thead{Weekly Ave. \\ Work Hours} & \thead{Female Industry \\ Share}  & \thead{Managerial \\ Responsibilities} &  \thead{Performance \\ Pay} &\thead{Wage \\ Negotiation} & \thead{Work \\ Flexibility}\\"
file write resultsfile "& (1) & (2) & (3) & (4) & (5) & (6) & (7) & (8) \\"
file write resultsfile "\midrule"
file write resultsfile" \addlinespace[0.2cm]"

*-----------------------------------------------------------------------------
* Write Panel A
*-----------------------------------------------------------------------------

file write resultsfile "\multicolumn{5}{l}{\textbf{Panel A. Binary gender}} \\" _n
file write resultsfile " \multicolumn{1}{l}{F-stat (overall)} & `F1_a' & `F2_a' & `F3_a' & `F4_a' & `F5_a'  & `F6_a'  & `F7_a'  & `F8_a' \\" _n
file write resultsfile " \multicolumn{1}{l}{p-value} & `pval_F1_a' &  `pval_F2_a' & `pval_F3_a' & `pval_F4_a' & `pval_F5_a' & `pval_F6_a' & `pval_F7_a' & `pval_F8_a'  \\ \\" _n
file write resultsfile "\addlinespace[-0.3cm]"
file write resultsfile "\midrule"

*-----------------------------------------------------------------------------
* Write Panel B
*-----------------------------------------------------------------------------
file write resultsfile "\multicolumn{5}{l}{\textbf{Panel B. Gender identity}} \\" _n
file write resultsfile " \multicolumn{1}{l}{F-stat (overall)} & `F1_b' & `F2_b' & `F3_b' & `F4_b' & `F5_b'  & `F6_b'  & `F7_b'  & `F8_b'  \\" _n
file write resultsfile " \multicolumn{1}{l}{p-value} & `pval_F1_b' &  `pval_F2_b' & `pval_F3_b' & `pval_F4_b' & `pval_F5_b' & `pval_F6_b' & `pval_F7_b' & `pval_F8_b'  \\ \\" _n
file write resultsfile "\addlinespace[-0.3cm]"
file write resultsfile "\midrule"

*-----------------------------------------------------------------------------
* Write Panel C
*-----------------------------------------------------------------------------
file write resultsfile "\multicolumn{5}{l}{\textbf{Panel C. Binary gender and gender identity }} \\" _n
file write resultsfile "\multicolumn{1}{l}{F-stat (overall)} & `F1_c' & `F2_c' & `F3_c' & `F4_c' & `F5_c'  & `F6_c'  & `F7_c'  & `F8_c'   \\" _n
file write resultsfile "\multicolumn{1}{l}{p-value} & `pval_F1_c' &  `pval_F2_c' & `pval_F3_c' & `pval_F4_c' & `pval_F5_c' & `pval_F6_c' & `pval_F7_c'  & `pval_F8_c'  \\" _n
file write resultsfile "\addlinespace[0.3cm]"
file write resultsfile "\multicolumn{5}{l}{Test: Binary sex=0} \\" _n
file write resultsfile "\multicolumn{1}{l}{F-test} & `F1_c_fem' &  `F2_c_fem' & `F3_c_fem' & `F4_c_fem' & `F5_c_fem' & `F6_c_fem' & `F7_c_fem' & `F8_c_fem'  \\" _n
file write resultsfile "\multicolumn{1}{l}{p-value} & `pval_F1_c_fem' &  `pval_F2_c_fem' & `pval_F3_c_fem' & `pval_F4_c_fem' & `pval_F5_c_fem' & `pval_F6_c_fem' & `pval_F7_c_fem' & `pval_F8_c_fem' ' \\" _n
file write resultsfile "\addlinespace[0.3cm]"
file write resultsfile "\multicolumn{5}{l}{Test: All CGI dummies=0} \\" _n
file write resultsfile "\multicolumn{1}{l}{F-test} & `F1_c_cgi' &  `F2_c_cgi' & `F3_c_cgi' & `F4_c_cgi' & `F5_c_cgi' & `F6_c_cgi' & `F7_c_cgi' & `F8_c_cgi'  \\" _n
file write resultsfile "\multicolumn{1}{l}{p-value} & `pval_F1_c_cgi' &  `pval_F2_c_cgi' & `pval_F3_c_cgi' & `pval_F4_c_cgi' & `pval_F5_c_cgi' & `pval_F6_c_cgi' & `pval_F7_c_cgi' & `pval_F8_c_cgi'  \\ \\" _n
file write resultsfile "\addlinespace[-0.3cm]"
file write resultsfile "\midrule"

/*
*-----------------------------------------------------------------------------
* Write Panel D
*-----------------------------------------------------------------------------
file write resultsfile "\multicolumn{5}{l}{\textbf{Panel D. Sample split by binary sex }} \\" _n
file write resultsfile "\multicolumn{5}{l}{Female:} \\" _n
file write resultsfile "\multicolumn{1}{l}{F-stat (overall)} & `F1_f' & `F2_f' & `F3_f' & `F4_f' & `F5_f'  & `F6_f'  & `F7_f'  & `F8_f'   \\" _n
file write resultsfile "\multicolumn{1}{l}{p-value} & `pval_F1_f' &  `pval_F2_f' & `pval_F3_f' & `pval_F4_f' & `pval_F5_f' & `pval_F6_f' & `pval_F7_f' & `pval_F8_f'  \\" _n
file write resultsfile "\addlinespace[0.3cm]"
file write resultsfile "\multicolumn{5}{l}{Male:} \\" _n
file write resultsfile "\multicolumn{1}{l}{F-stat (overall)} & `F1_m' &  `F2_m' & `F3_m' & `F4_m' & `F5_m' & `F6_m' & `F7_m' & `F8_m'  \\" _n
file write resultsfile "\multicolumn{1}{l}{p-value} & `pval_F1_m' &  `pval_F2_m' & `pval_F3_m' & `pval_F4_m' & `pval_F5_m' & `pval_F6_m' & `pval_F7_m' & `pval_F8_m'  \\ \\" _n
file write resultsfile "\addlinespace[-0.3cm]"
file write resultsfile "\midrule"
*/

*-----------------------------------------------------------------------------
* Write Obs number row
*-----------------------------------------------------------------------------
file write resultsfile "\multicolumn{1}{l}{Observations} & `N_1' & `N_2' & `N_3' & `N_4' & `N_5' & `N_6' & `N_7' & `N_8' \\ \\" _n
file write resultsfile "\addlinespace[-0.3cm]"

*-----------------------------------------------------------------------------
* Write Table footer
*-----------------------------------------------------------------------------
file write resultsfile "\bottomrule\bottomrule"
file write resultsfile "\end{tabular}"
/*
file write resultsfile "\begin{tablenotes}"
file write resultsfile "\item \textit{Notes.} "
file write resultsfile "\end{tablenotes}"
file write resultsfile "\end{threeparttable}"
file write resultsfile "\end{adjustbox}"
file write resultsfile "\end{table}"
*/
file close resultsfile
}

}


*-------------------------------------------------------------------------------




