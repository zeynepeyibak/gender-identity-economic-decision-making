clear all

global out_path "$path/3_out" 
		
local tableid "table_5"
local colno "6" 
local dropped_panelC "4"

* short code to save reg coeffs
do "$path/2_do/2_analysis/0_reg_fnc/0_regressions.do" // 2 tailed 

					

/*
Column 1: Redistribution - Swiss Uni
Column 2: Redistribution - US adults

Column 3: Donation - Swiss Uni
Column 4: Donation - US adults
Column 5: Donation - Swiss Teens
Column 6: Donation - Swedish Youth
*/

forvalues z =1/1 {

forvalues i=1/6{ 
	if `i'==1| `i'==3{
		use "$path/1_data/2_prepared/1_SwissUni.dta", clear
	}	
	if `i'==2 | `i'==4{
		use "$path/1_data/2_prepared/1_usadults_w1_w2_30_60.dta", clear
		
		* Restandardize std_cgi_main as it was standardized for age 20-60.
		drop std_cgi_main
		qui su cgi_main
		qui gen std_cgi_main=(cgi_main-r(mean))/r(sd)
		
		* Restandardize the outcome variables as they were standardized for age 20-60.
		drop std_redistribution
		qui su redistribution
		qui gen std_redistribution=(redistribution-r(mean))/r(sd)
		
		* Restandardize the outcome variables as they were standardized for age 20-60.
		drop std_donation
		qui su donation
		qui gen std_donation=(donation-r(mean))/r(sd)	
	}
	if `i'==5{
		use "$path/1_data/2_prepared/1_swissteens.dta", clear
	}
	if `i'==6{
		use "$path/1_data/2_prepared/1_Swedishyouth.dta", clear
	}
	
*-----------------------------------------------------------------------------
* Sanity checks with standardizations before we start the regression analysis
*-----------------------------------------------------------------------------
		
* Outcome variables
		if `i'==1 |`i'==2 {
		qui su std_redistribution
		assert round(r(mean),0.0001)==0
		}		
		if `i'==3 | `i'==4 |`i'==5 |`i'==6{
		qui su std_donation 
		assert round(r(mean),0.001)==0
		}
		
		
* CGI
		if `i'==1  {
		qui su std_cgi_main if std_redistribution!=.
		assert round(r(mean),0.0001)==0		
		}		
		if `i'==2 {
		qui su std_cgi_main if std_redistribution!=.
		assert round(r(mean),0.0001)==0		
		}	
		if `i'==3 {
		qui su std_cgi_main if std_donation!=.
		assert round(r(mean),0.0001)==0		
		}
		if `i'==4 {
		qui su std_cgi_main if std_donation!=.
		assert round(r(mean),0.0001)==0				
		}
		if `i'==5 {
		qui su std_cgi_main if std_donation!=.
		//assert round(r(mean),0.0001)==0		
		drop std_cgi_main
		qui su cgi_main if std_donation!=.
		gen std_cgi_main=(cgi_main-r(mean))/r(sd)
		
		qui su std_cgi_main if std_donation!=.
		assert round(r(mean),0.0001)==0	
		}
		if `i'==6 {
		qui su std_cgi_main if std_donation!=.
		assert round(r(mean),0.0001)==0		
		}


*-----------------------------------------------------------------------------
* Panel A: biological gender	 
*-----------------------------------------------------------------------------
	if `z'== 1 { //no controls
		if `i'==1 |`i'==2 {
		qui reg std_redistribution female, vce(hc3) 
		}		
		if `i'==3 | `i'==4 |`i'==5 |`i'==6{
		qui reg std_donation female, vce(hc3) 
		}
	}		
	
     	* Store the results
	    local F`i'_a : di %9.3f e(F)
		local pval_F`i'_a : di %9.3f Ftail(e(df_m), e(df_r), e(F))	

*-----------------------------------------------------------------------------				
* Panel B: cgi	 
*-----------------------------------------------------------------------------
	if `z'== 1 { //no controls
		if `i'==1 |`i'==2 {
		qui reg std_redistribution ib5.cgi_main, vce(hc3) 
		}		
		if `i'==3 | `i'==4 |`i'==5 |`i'==6{
		qui reg std_donation ib5.cgi_main, vce(hc3) 
		}
	}			

     	* Store the results
	    local F`i'_b : di %9.3f e(F)
		local pval_F`i'_b : di %9.3f Ftail(e(df_m), e(df_r), e(F))

*-----------------------------------------------------------------------------				
* Panel C: biological gender and cgi 
*-----------------------------------------------------------------------------				
	if `z'== 1 { //no controls
		if `i'==1 |`i'==2 {
		qui reg std_redistribution female ib5.cgi_main, vce(hc3) 
		}		
		if `i'==3 | `i'==4 |`i'==5 |`i'==6{
		qui reg std_donation female ib5.cgi_main, vce(hc3) 
		}
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

* Outcome variables
		if `i'==1 |`i'==2 {
		drop std_redistribution
		qui su redistribution
		qui gen std_redistribution =(redistribution-r(mean))/r(sd)		
		
		qui su std_redistribution
		assert round(r(mean),0.0001)==0
		}		
		
		if `i'==3 | `i'==4 |`i'==5 |`i'==6{
		drop std_donation
		qui su donation
		qui gen std_donation =(donation-r(mean))/r(sd)		
		
		qui su std_donation 
		assert round(r(mean),0.0001)==0
		}
		
		
* CGI
		if `i'==1  {
		drop std_cgi_main
		qui su cgi_main if std_redistribution!=.!=.
		gen std_cgi_main=(cgi_main-r(mean))/r(sd)
		
		qui su std_cgi_main if std_redistribution!=.!=.
		assert round(r(mean),0.0001)==0		

		}		
		if `i'==2 {
		drop std_cgi_main
		qui su cgi_main if std_redistribution!=.!=.
		gen std_cgi_main=(cgi_main-r(mean))/r(sd)
		
		qui su std_cgi_main if std_redistribution!=.!=.
		assert round(r(mean),0.0001)==0		
		}	
		if `i'==3 {
		drop std_cgi_main
		qui su cgi_main if std_donation!=.
		gen std_cgi_main=(cgi_main-r(mean))/r(sd)
		
		qui su std_cgi_main if std_donation!=.
		assert round(r(mean),0.0001)==0		
		}
		if `i'==4 {
		drop std_cgi_main
		qui su cgi_main if std_donation!=.
		gen std_cgi_main=(cgi_main-r(mean))/r(sd)
		
		qui su std_cgi_main if std_donation!=.
		assert round(r(mean),0.0001)==0				
		}
		if `i'==5 {
		drop std_cgi_main
		qui su cgi_main if std_donation!=.
		gen std_cgi_main=(cgi_main-r(mean))/r(sd)
		
		qui su std_cgi_main if std_donation!=.
		assert round(r(mean),0.0001)==0	
		}
		if `i'==6 {
		drop std_cgi_main
		qui su cgi_main if std_donation!=.
		gen std_cgi_main=(cgi_main-r(mean))/r(sd)
		
		qui su std_cgi_main if std_donation!=.
		assert round(r(mean),0.0001)==0		
		}

	if `z'== 1 { //no controls
		if `i'==1 |`i'==2 {
		qui reg std_redistribution female ib5.cgi_main if female==1, vce(hc3) 
		}		
		if `i'==3 | `i'==4 |`i'==5 |`i'==6{
		qui reg std_donation female ib5.cgi_main if female==1, vce(hc3) 
		}
	}	
	
		* F stat (overall)
		local F`i'_f : di %9.3f e(F)
		local pval_F`i'_f : di %9.3f Ftail(e(df_m), e(df_r), e(F))	
restore 

preserve			
* Panel D for males: 
keep if female==0
* Outcome variables
		if `i'==1 |`i'==2 {
		drop std_redistribution
		qui su redistribution
		qui gen std_redistribution =(redistribution-r(mean))/r(sd)		
		
		qui su std_redistribution
		assert round(r(mean),0.0001)==0

		}		
		if `i'==3 | `i'==4 |`i'==5 |`i'==6{
		drop std_donation
		qui su donation
		qui gen std_donation =(donation-r(mean))/r(sd)		
		
		qui su std_donation 
		assert round(r(mean),0.0001)==0
		}
		
		
* CGI
	if `i'==1  {
		drop std_cgi_main
		qui su cgi_main if std_redistribution!=.!=.
		gen std_cgi_main=(cgi_main-r(mean))/r(sd)
		
		qui su std_cgi_main if std_redistribution!=.!=.
		assert round(r(mean),0.0001)==0		

		}		
		if `i'==2 {
		drop std_cgi_main
		qui su cgi_main if std_redistribution!=.!=.
		gen std_cgi_main=(cgi_main-r(mean))/r(sd)
		
		qui su std_cgi_main if std_redistribution!=.!=.
		assert round(r(mean),0.0001)==0		
		}	
		if `i'==3 {
		drop std_cgi_main
		qui su cgi_main if std_donation!=.
		gen std_cgi_main=(cgi_main-r(mean))/r(sd)
		
		qui su std_cgi_main if std_donation!=.
		assert round(r(mean),0.0001)==0		
		}
		if `i'==4 {
		drop std_cgi_main
		qui su cgi_main if std_donation!=.
		gen std_cgi_main=(cgi_main-r(mean))/r(sd)
		
		qui su std_cgi_main if std_donation!=.
		assert round(r(mean),0.0001)==0				
		}
		if `i'==5 {
		drop std_cgi_main
		qui su cgi_main if std_donation!=.
		gen std_cgi_main=(cgi_main-r(mean))/r(sd)
		
		qui su std_cgi_main if std_donation!=.
		assert round(r(mean),0.0001)==0	
		}
		if `i'==6 {
		drop std_cgi_main
		qui su cgi_main if std_donation!=.
		gen std_cgi_main=(cgi_main-r(mean))/r(sd)
		
		qui su std_cgi_main if std_donation!=.
		assert round(r(mean),0.0001)==0		
		}
		
	if `z'== 1 { //no controls
		if `i'==1 |`i'==2 {
		qui reg std_redistribution female ib5.cgi_main if female==0, vce(hc3) 
		}		
		if `i'==3 | `i'==4 |`i'==5 |`i'==6{
		qui reg std_donation female ib5.cgi_main if female==0, vce(hc3) 
		}
	}	
	
		* F stat (overall)
		local F`i'_m : di %9.3f e(F)
		local pval_F`i'_m : di %9.3f Ftail(e(df_m), e(df_r), e(F))	
		
restore
}

*-----------------------------------------------------------------------------
*-----------------------------------------------------------------------------
* Write the Results
*-----------------------------------------------------------------------------
*-----------------------------------------------------------------------------

foreach path in out_path{
	
if `z' ==1{
        file open resultsfile using "$`path'/Tables_CGI_Dummies/table_5.tex", write replace
}	


*-----------------------------------------------------------------------------
* Write Table header
*-----------------------------------------------------------------------------
/*
file write resultsfile "\begin{table}[H]"
file write resultsfile "\centering"
file write resultsfile "\begin{adjustbox}{max width=14cm}"
file write resultsfile "\begin{threeparttable}"
*/
file write resultsfile "\caption{CGI and Unincentivized Distributional Preferences (with CGI dummies)}"
file write resultsfile "\begin{tabular}"
file write resultsfile "{p{1.7cm} M{2.5cm} M{2.5cm} M{2.5cm} M{2.5cm} M{2.5cm} M{2.9cm}}" 
file write resultsfile "\toprule\toprule"
file write resultsfile "\addlinespace[0.2cm]"
file write resultsfile "\multicolumn{1}{l}{Measure} & \multicolumn{2}{c}{Redistribution} & \multicolumn{4}{c}{Altruism} \\"
file write resultsfile "\cmidrule(lr){2-3} \cmidrule(lr){4-7} \\"
file write resultsfile "\multicolumn{1}{l}{Sample} & Swiss Uni & U.S. Adults & Swiss Uni & U.S. Adults & Swiss Teens & Swedish Youth \\"
file write resultsfile "& (1) & (2) & (3) & (4) & (5) & (6) \\"
file write resultsfile "\midrule"
file write resultsfile" \addlinespace[0.2cm]"

*-----------------------------------------------------------------------------
* Write Panel A
*-----------------------------------------------------------------------------

file write resultsfile "\multicolumn{5}{l}{\textbf{Panel A. Binary gender}} \\" _n
file write resultsfile " \multicolumn{1}{l}{F-stat (overall)} & `F1_a' & `F2_a' & `F3_a' & `F4_a' & `F5_a'  & `F6_a' \\" _n
file write resultsfile " \multicolumn{1}{l}{p-value} & `pval_F1_a' &  `pval_F2_a' & `pval_F3_a' & `pval_F4_a' & `pval_F5_a' & `pval_F6_a' \\ \\" _n
file write resultsfile "\addlinespace[-0.3cm]"
file write resultsfile "\midrule"

*-----------------------------------------------------------------------------
* Write Panel B
*-----------------------------------------------------------------------------
file write resultsfile "\multicolumn{5}{l}{\textbf{Panel B. Gender identity}} \\" _n
file write resultsfile " \multicolumn{1}{l}{F-stat (overall)} & `F1_b' & `F2_b' & `F3_b' & \phantom{`F4_b'} & `F5_b'  & `F6_b' '\\" _n
file write resultsfile " \multicolumn{1}{l}{p-value} & `pval_F1_b' &  `pval_F2_b' & `pval_F3_b' & \phantom{`pval_F4_b'} & `pval_F5_b' & `pval_F6_b' \\ \\" _n
file write resultsfile "\addlinespace[-0.3cm]"
file write resultsfile "\midrule"

*-----------------------------------------------------------------------------
* Write Panel C
*-----------------------------------------------------------------------------
file write resultsfile "\multicolumn{5}{l}{\textbf{Panel C. Binary gender and gender identity }} \\" _n
file write resultsfile "\multicolumn{1}{l}{F-stat (overall)} & `F1_c' & `F2_c' & `F3_c' & \phantom{`F4_c'} & `F5_c'  & `F6_c' \\" _n
file write resultsfile "\multicolumn{1}{l}{p-value} & `pval_F1_c' &  `pval_F2_c' & `pval_F3_c' & \phantom{`pval_F4_c'} & `pval_F5_c' & `pval_F6_c'\\" _n
file write resultsfile "\addlinespace[0.3cm]"
file write resultsfile "\multicolumn{5}{l}{Test: Binary sex=0} \\" _n
file write resultsfile "\multicolumn{1}{l}{F-test} & `F1_c_fem' &  `F2_c_fem' & `F3_c_fem' & \phantom{`F4_c_fem'} & `F5_c_fem' & `F6_c_fem'\\" _n
file write resultsfile "\multicolumn{1}{l}{p-value} & `pval_F1_c_fem' &  `pval_F2_c_fem' & `pval_F3_c_fem' & \phantom{`pval_F4_c_fem'} & `pval_F5_c_fem' & `pval_F6_c_fem' \\" _n
file write resultsfile "\addlinespace[0.3cm]"
file write resultsfile "\multicolumn{5}{l}{Test: All CGI dummies=0} \\" _n
file write resultsfile "\multicolumn{1}{l}{F-test} & `F1_c_cgi' &  `F2_c_cgi' & `F3_c_cgi' & \phantom{`F4_c_cgi'} & `F5_c_cgi' & `F6_c_cgi' \\" _n
file write resultsfile "\multicolumn{1}{l}{p-value} & `pval_F1_c_cgi' &  `pval_F2_c_cgi' & `pval_F3_c_cgi' & \phantom{`pval_F4_c_cgi'} & `pval_F5_c_cgi' & `pval_F6_c_cgi' \\ \\" _n
file write resultsfile "\addlinespace[-0.3cm]"
file write resultsfile "\midrule"


/*
*-----------------------------------------------------------------------------
* Write Panel D
*-----------------------------------------------------------------------------
file write resultsfile "\multicolumn{5}{l}{\textbf{Panel D. Sample split by binary sex }} \\" _n
file write resultsfile "\multicolumn{5}{l}{Female:} \\" _n
file write resultsfile "\multicolumn{1}{l}{F-stat (overall)} & `F1_f' & `F2_f' & `F3_f' & \phantom{`F4_f'} & `F5_f'  & `F6_f' \\" _n
file write resultsfile "\multicolumn{1}{l}{p-value} & `pval_F1_f' &  `pval_F2_f' & `pval_F3_f' & \phantom{`pval_F4_f'} & `pval_F5_f' & `pval_F6_f' \\" _n
file write resultsfile "\addlinespace[0.3cm]"
file write resultsfile "\multicolumn{5}{l}{Male:} \\" _n
file write resultsfile "\multicolumn{1}{l}{F-stat (overall)} & `F1_m' &  `F2_m' & `F3_m' & \phantom{`F4_m'} & `F5_m' & `F6_m' \\" _n
file write resultsfile "\multicolumn{1}{l}{p-value} & `pval_F1_m' &  `pval_F2_m' & `pval_F3_m' & \phantom{`pval_F4_m'} & `pval_F5_m' & `pval_F6_m' \\ \\" _n
file write resultsfile "\addlinespace[-0.3cm]"
file write resultsfile "\midrule"
*/


*-----------------------------------------------------------------------------
* Write Obs number row
*-----------------------------------------------------------------------------
file write resultsfile "\multicolumn{1}{l}{Observations} & `N_1' & `N_2' & `N_3' & `N_4' & `N_5' & `N_6' \\ \\" _n
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














