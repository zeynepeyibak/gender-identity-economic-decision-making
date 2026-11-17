clear all

global out_path "$path/3_out" 
		
local tableid "table_4"
local colno "10" 

* short code to save reg coeffs
do "$path/2_do/2_analysis/0_reg_fnc/0_regressions.do" // 2 tailed 
								

/*
Column 1: Staircase Risk - Swiss Uni
Column 2: Hypothetical Risk - Swiss Uni
Column 3: Hypothetical Risk - US adults
Column 4: Hypothetical Risk - Swiss Teens
Column 5: Hypothetical Risk - Swedish Youth
Column 6: Financial Risk - US Adults
Column 7: Competitiveness - Swiss Uni
Column 8: Competitiveness - US Adults
Column 9: Competitiveness - Swiss Teens
Column 10: Competitiveness - Swedish Youth
*/

forvalues z =1/1{ 

forvalues i=1/10{ 
	if `i'==1| `i'==2 | `i'==7{
		use "$path/1_data/2_prepared/1_SwissUni.dta", clear
	}	
	if `i'==3 | `i'==6 | `i'==8{
		use "$path/1_data/2_prepared/1_usadults_w1_w2_30_60.dta", clear
		
		* Restandardize std_cgi_main as it was standardized for age 20-60.
		drop std_cgi_main
		qui su cgi_main
		qui gen std_cgi_main=(cgi_main-r(mean))/r(sd)
		
		drop std_hyp_risk
		qui su hypothetical_risk
		qui gen std_hyp_risk=(hypothetical_risk-r(mean))/r(sd)
		
		drop std_competitiveness
		qui su competitiveness
		qui gen std_competitiveness=(competitiveness-r(mean))/r(sd)
	}
	if `i'==4 | `i'==9{
		use "$path/1_data/2_prepared/1_swissteens.dta", clear
	}
	if `i'==5 | `i'==10{
		use "$path/1_data/2_prepared/1_Swedishyouth.dta", clear
	}
	
*-----------------------------------------------------------------------------
* Sanity checks with standardizations before we start the regression analysis
*-----------------------------------------------------------------------------
		if `i'==1{
		qui su std_staircase_risk 
		assert round(r(mean),0.0001)==0
		}	
		if `i'==2 |`i'==3 |`i'==4 |`i'==5 {
		qui su std_hyp_risk 
		assert round(r(mean),0.0001)==0
		}			
		if `i'==7 | `i'==8 |`i'==9 |`i'==10{
		qui su std_competitiveness 
		assert round(r(mean),0.0001)==0 
		}
		
		
		if `i'==1{
		qui su std_cgi_main if std_staircase_risk!=.
		assert round(r(mean),0.0001)==0
		}	
		if `i'==2 {
		qui su std_cgi_main if  std_hyp_risk!=.
		assert round(r(mean),0.0001)==0
		}	
		if `i'==3  {
		qui su std_cgi_main if std_hyp_risk!=.
		assert round(r(mean),0.0001)==0
		}	
		if `i'==4  {
		qui su std_cgi_main if std_hyp_risk!=.
		//assert round(r(mean),0.0001)==0
		
		drop std_cgi_main
		qui su cgi_main if std_hyp_risk!=.
		gen std_cgi_main=(cgi_main-r(mean))/r(sd)
		
		qui su std_cgi_main if std_hyp_risk!=.
		assert round(r(mean),0.0001)==0
		}
		if `i'==5 {
		qui su std_cgi_main if std_hyp_risk!=.
		assert round(r(mean),0.0001)==0		
		}	
		if `i'==6 {
		qui su std_cgi_main if financial_market!=.
		assert round(r(mean),0.0001)==0
		}	
		if `i'==7 {
		qui su std_cgi_main if std_competitiveness!=.
		assert round(r(mean),0.0001)==0		
		}
		if  `i'==8 {
		qui su std_cgi_main if std_competitiveness!=.
		assert round(r(mean),0.0001)==0		
		}
		if `i'==9{
		qui su std_cgi_main if std_competitiveness!=.
		//assert round(r(mean),0.0001)==0		
		
		drop std_cgi_main
		qui su cgi_main if std_competitiveness!=.
		gen std_cgi_main=(cgi_main-r(mean))/r(sd)
		
		qui su std_cgi_main if std_competitiveness!=.
		assert round(r(mean),0.0001)==0
		}		
		if `i'==10{
		qui su std_cgi_main if std_competitiveness!=.
		assert round(r(mean),0.0001)==0
		}


*-----------------------------------------------------------------------------
* Panel A: biological gender	 
*-----------------------------------------------------------------------------
	if `z'== 1 { //no controls
		if `i'==1{
		qui reg std_staircase_risk female, vce(hc3) 
		}	
		if `i'==2 |`i'==3 |`i'==4 |`i'==5 {
		qui reg std_hyp_risk female, vce(hc3) 
		}		
		if `i'==6 {
		qui reg financial_market female, vce(hc3)
		}		
		if `i'==7 | `i'==8 |`i'==9 |`i'==10{
		qui reg std_competitiveness female, vce(hc3) 
		}
	}	
     	* Store the results
	    local F`i'_a : di %9.3f e(F)
		local pval_F`i'_a : di %9.3f Ftail(e(df_m), e(df_r), e(F))	

*-----------------------------------------------------------------------------				
* Panel B: cgi	 
*-----------------------------------------------------------------------------
	if `z'== 1 { //no controls
		if `i'==1{
		qui reg std_staircase_risk ib5.cgi_main, vce(hc3) 
		}	
		if `i'==2 |`i'==3 |`i'==4 |`i'==5 {
		qui reg std_hyp_risk ib5.cgi_main, vce(hc3) 
		}		
		if `i'==6 {
		qui reg financial_market ib5.cgi_main, vce(hc3)
		}		
		if `i'==7 | `i'==8 |`i'==9 |`i'==10{
		qui reg std_competitiveness ib5.cgi_main, vce(hc3) 
		}
	}		
	
     	* Store the results
	    local F`i'_b : di %9.3f e(F)
		local pval_F`i'_b : di %9.3f Ftail(e(df_m), e(df_r), e(F))
*-----------------------------------------------------------------------------				
* Panel C: biological gender and cgi 
*-----------------------------------------------------------------------------				
	if `z'== 1 { //no controls
		if `i'==1{
		qui reg std_staircase_risk female ib5.cgi_main, vce(hc3) 
		}	
		if `i'==2 |`i'==3 |`i'==4 |`i'==5 {
		qui reg std_hyp_risk female ib5.cgi_main, vce(hc3) 
		}		
		if `i'==6 {
		qui reg financial_market female ib5.cgi_main, vce(hc3)
		}		
		if `i'==7 | `i'==8 |`i'==9 |`i'==10{
		qui reg std_competitiveness female ib5.cgi_main, vce(hc3) 
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

		if `i'==1{
		drop std_staircase_risk 
		qui su staircase_risk 
		qui gen std_staircase_risk =(staircase_risk-r(mean))/r(sd)		
		
		qui su std_staircase_risk
		assert round(r(mean),0.0001)==0

		}	
		if `i'==2 |`i'==3 |`i'==4 |`i'==5 {
		drop std_hyp_risk 
		qui su hypothetical_risk 
		qui gen std_hyp_risk  =(hypothetical_risk -r(mean))/r(sd)	
		
		qui su std_hyp_risk 
		assert round(r(mean),0.0001)==0
		}			
		
		if `i'==7 | `i'==8 |`i'==9 |`i'==10{
		drop std_competitiveness 
		qui su competitiveness
		qui gen std_competitiveness =(competitiveness -r(mean))/r(sd)	
		
		qui su std_competitiveness 
		assert round(r(mean),0.0001)==0 
		}
		
		
		if `i'==1{
		drop std_cgi_main
		qui su cgi_main if std_staircase_risk!=.
		gen std_cgi_main=(cgi_main-r(mean))/r(sd)
		
		qui su std_cgi_main if std_staircase_risk!=.
		assert round(r(mean),0.0001)==0
		}	
		if `i'==2 {	
		drop std_cgi_main
		qui su cgi_main if std_hyp_risk!=.
		gen std_cgi_main=(cgi_main-r(mean))/r(sd)
		
		qui su std_cgi_main if  std_hyp_risk!=.
		assert round(r(mean),0.0001)==0
		}	
		if `i'==3  {
		drop std_cgi_main
		qui su cgi_main if std_hyp_risk!=.
		gen std_cgi_main=(cgi_main-r(mean))/r(sd)
		
		qui su std_cgi_main if std_hyp_risk!=.
		assert round(r(mean),0.0001)==0
		}	
		
		if `i'==4  {
		drop std_cgi_main
		qui su cgi_main if std_hyp_risk!=.
		gen std_cgi_main=(cgi_main-r(mean))/r(sd)
		
		qui su std_cgi_main if std_hyp_risk!=.
		assert round(r(mean),0.0001)==0
		}
		if `i'==5 {
		drop std_cgi_main
		qui su cgi_main if std_hyp_risk!=.
		gen std_cgi_main=(cgi_main-r(mean))/r(sd)
		
		qui su std_cgi_main if std_hyp_risk!=.
		assert round(r(mean),0.0001)==0		
		}	
		if `i'==6 {
		drop std_cgi_main
		qui su cgi_main if financial_market!=.
		gen std_cgi_main=(cgi_main-r(mean))/r(sd)
		
		qui su std_cgi_main if financial_market!=.
		assert round(r(mean),0.0001)==0
		}	
		
		if `i'==7 {
		drop std_cgi_main
		qui su cgi_main if std_competitiveness!=.
		gen std_cgi_main=(cgi_main-r(mean))/r(sd)
		
		qui su std_cgi_main if std_competitiveness!=.
		assert round(r(mean),0.0001)==0		
		}
		
		if  `i'==8 {
		drop std_cgi_main
		qui su cgi_main if std_competitiveness!=.
		gen std_cgi_main=(cgi_main-r(mean))/r(sd)
		
		qui su std_cgi_main if std_competitiveness!=.
		assert round(r(mean),0.0001)==0		
		}
		if `i'==9{
		drop std_cgi_main
		qui su cgi_main if std_competitiveness!=.
		gen std_cgi_main=(cgi_main-r(mean))/r(sd)
		
		qui su std_cgi_main if std_competitiveness!=.
		assert round(r(mean),0.0001)==0
		}		
		if `i'==10{
		drop std_cgi_main
		qui su cgi_main if std_competitiveness!=.
		gen std_cgi_main=(cgi_main-r(mean))/r(sd)
		
		qui su std_cgi_main if std_competitiveness!=.
		assert round(r(mean),0.0001)==0
		}

	if `z'== 1 { //no controls
		if `i'==1{
		qui reg std_staircase_risk ib5.cgi_main if female ==1, vce(hc3) 
		}	
		if `i'==2 |`i'==3 |`i'==4 |`i'==5 {
		qui reg std_hyp_risk ib5.cgi_main if female ==1, vce(hc3) 
		}		
		if `i'==6 {
		qui reg financial_market ib5.cgi_main if female ==1, vce(hc3)
		}		
		if `i'==7 | `i'==8 |`i'==9 |`i'==10{
		qui reg std_competitiveness ib5.cgi_main if female ==1, vce(hc3) 
		}
	}	
	
		* F stat (overall)
		local F`i'_f : di %9.3f e(F)
		local pval_F`i'_f : di %9.3f Ftail(e(df_m), e(df_r), e(F))	

restore

* Panel D for males: 
preserve
keep if female==0
		if `i'==1{
		drop std_staircase_risk 
		qui su staircase_risk 
		qui gen std_staircase_risk =(staircase_risk-r(mean))/r(sd)		
		
		qui su std_staircase_risk
		assert round(r(mean),0.0001)==0

		}	
		if `i'==2 |`i'==3 |`i'==4 |`i'==5 {
		drop std_hyp_risk 
		qui su hypothetical_risk 
		qui gen std_hyp_risk  =(hypothetical_risk -r(mean))/r(sd)	
		
		qui su std_hyp_risk 
		assert round(r(mean),0.0001)==0
		}			
		
		if `i'==7 | `i'==8 |`i'==9 |`i'==10{
		drop std_competitiveness 
		qui su competitiveness
		qui gen std_competitiveness =(competitiveness -r(mean))/r(sd)	
		
		qui su std_competitiveness 
		assert round(r(mean),0.0001)==0 
		}
		
		
		if `i'==1{
		drop std_cgi_main
		qui su cgi_main if std_staircase_risk!=.
		gen std_cgi_main=(cgi_main-r(mean))/r(sd)
		
		qui su std_cgi_main if std_staircase_risk!=.
		assert round(r(mean),0.0001)==0
		}	
		if `i'==2 {	
		drop std_cgi_main
		qui su cgi_main if std_hyp_risk!=.
		gen std_cgi_main=(cgi_main-r(mean))/r(sd)
		
		qui su std_cgi_main if  std_hyp_risk!=.
		assert round(r(mean),0.0001)==0
		}	
		if `i'==3  {
		drop std_cgi_main
		qui su cgi_main if std_hyp_risk!=.
		gen std_cgi_main=(cgi_main-r(mean))/r(sd)
		
		qui su std_cgi_main if std_hyp_risk!=.
		assert round(r(mean),0.0001)==0
		}	
		
		if `i'==4  {
		drop std_cgi_main
		qui su cgi_main if std_hyp_risk!=.
		gen std_cgi_main=(cgi_main-r(mean))/r(sd)
		
		qui su std_cgi_main if std_hyp_risk!=.
		assert round(r(mean),0.0001)==0
		}
		if `i'==5 {
		drop std_cgi_main
		qui su cgi_main if std_hyp_risk!=.
		gen std_cgi_main=(cgi_main-r(mean))/r(sd)
		
		qui su std_cgi_main if std_hyp_risk!=.
		assert round(r(mean),0.0001)==0		
		}	
		if `i'==6 {
		drop std_cgi_main
		qui su cgi_main if financial_market!=.
		gen std_cgi_main=(cgi_main-r(mean))/r(sd)
		
		qui su std_cgi_main if financial_market!=.
		assert round(r(mean),0.0001)==0
		}	
		
		if `i'==7 {
		drop std_cgi_main
		qui su cgi_main if std_competitiveness!=.
		gen std_cgi_main=(cgi_main-r(mean))/r(sd)
		
		qui su std_cgi_main if std_competitiveness!=.
		assert round(r(mean),0.0001)==0		
		}
		
		if  `i'==8 {
		drop std_cgi_main
		qui su cgi_main if std_competitiveness!=.
		gen std_cgi_main=(cgi_main-r(mean))/r(sd)
		
		qui su std_cgi_main if std_competitiveness!=.
		assert round(r(mean),0.0001)==0		
		}
		if `i'==9{
		drop std_cgi_main
		qui su cgi_main if std_competitiveness!=.
		gen std_cgi_main=(cgi_main-r(mean))/r(sd)
		
		qui su std_cgi_main if std_competitiveness!=.
		assert round(r(mean),0.0001)==0
		}		
		if `i'==10{
		drop std_cgi_main
		qui su cgi_main if std_competitiveness!=.
		gen std_cgi_main=(cgi_main-r(mean))/r(sd)
		
		qui su std_cgi_main if std_competitiveness!=.
		assert round(r(mean),0.0001)==0
		}

	if `z'== 1 { //no controls
		if `i'==1{
		qui reg std_staircase_risk ib5.cgi_main if female ==0, vce(hc3) 
		}	
		if `i'==2 |`i'==3 |`i'==4 |`i'==5 {
		qui reg std_hyp_risk  ib5.cgi_main if female ==0, vce(hc3) 
		}		
		if `i'==6 {
		qui reg financial_market  ib5.cgi_main if female ==0, vce(hc3)
		}		
		if `i'==7 | `i'==8 |`i'==9 |`i'==10{
		qui reg std_competitiveness  ib5.cgi_main if female ==0, vce(hc3) 
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
        file open resultsfile using "$`path'/Tables_CGI_Dummies/table_4.tex", write replace
}		

*-----------------------------------------------------------------------------
* Write Table header
*-----------------------------------------------------------------------------
/*
file write resultsfile "\begin{table}[H]"
file write resultsfile "\centering"
file write resultsfile "\begin{adjustbox}{max width=15cm}"
file write resultsfile "\begin{threeparttable}"
*/
file write resultsfile "\caption{CGI and Unincentivized Risk and Competitiveness Measures (with CGI dummies)}"
file write resultsfile "\begin{tabular}"
file write resultsfile "{p{1.7cm} M{1.7cm} M{1.7cm} M{1.7cm} M{1.7cm} M{1.7cm} M{1.7cm} M{1.7cm} M{1.7cm} M{1.7cm} M{1.7cm}}" 
file write resultsfile "\toprule\toprule"
file write resultsfile "\addlinespace[0.2cm]"
file write resultsfile "\multicolumn{1}{l}{Measure} & \multicolumn{1}{c}{\thead{Staircase \\ Risk}} & \multicolumn{4}{c}{Risk} & \multicolumn{1}{c}{\thead{Financial \\ Risk}} & \multicolumn{4}{c}{Competitiveness} \\ "
file write resultsfile "\cmidrule(lr){2-2} \cmidrule(lr){3-6}\cmidrule(lr){7-7}\cmidrule(lr){8-11} \\"
file write resultsfile "\multicolumn{1}{l}{Sample} & \thead{Swiss \\ Uni} & \thead{Swiss \\ Uni}  & \thead{US \\ Adults} & \thead{Swiss \\ Teens} & \thead{Swedish \\ Youth} & \thead{US \\ Adults} & \thead{Swiss \\ Uni} & \thead{US \\ Adults} & \thead{Swiss \\ Teens}  & \thead{Swedish \\ Youth}  \\"
file write resultsfile "& (1) & (2) & (3) & (4) & (5) & (6) & (7) & (8) & (9) & (10) \\"
file write resultsfile "\midrule"
file write resultsfile" \addlinespace[0.2cm]"

*-----------------------------------------------------------------------------
* Write Panel A
*-----------------------------------------------------------------------------

file write resultsfile "\multicolumn{5}{l}{\textbf{Panel A. Binary gender}} \\" _n
file write resultsfile " \multicolumn{1}{l}{F-stat (overall)} & `F1_a' & `F2_a' & `F3_a' & `F4_a' & `F5_a'  & `F6_a'  & `F7_a'  & `F8_a' & `F9_a'  & `F10_a'\\" _n
file write resultsfile " \multicolumn{1}{l}{p-value} & `pval_F1_a' &  `pval_F2_a' & `pval_F3_a' & `pval_F4_a' & `pval_F5_a' & `pval_F6_a' & `pval_F7_a' & `pval_F8_a' & `pval_F9_a' & `pval_F10_a'\\ \\" _n
file write resultsfile "\addlinespace[-0.3cm]"
file write resultsfile "\midrule"

*-----------------------------------------------------------------------------
* Write Panel B
*-----------------------------------------------------------------------------
file write resultsfile "\multicolumn{5}{l}{\textbf{Panel B. Gender identity}} \\" _n
file write resultsfile " \multicolumn{1}{l}{F-stat (overall)} & `F1_b' & `F2_b' & `F3_b' & `F4_b' & `F5_b'  & `F6_b'  & `F7_b'  & `F8_b'  & `F9_b'  & `F10_b'\\" _n
file write resultsfile " \multicolumn{1}{l}{p-value} & `pval_F1_b' &  `pval_F2_b' & `pval_F3_b' & `pval_F4_b' & `pval_F5_b' & `pval_F6_b' & `pval_F7_b' & `pval_F8_b' & `pval_F9_b' & `pval_F10_b'\\ \\" _n
file write resultsfile "\addlinespace[-0.3cm]"
file write resultsfile "\midrule"

*-----------------------------------------------------------------------------
* Write Panel C
*-----------------------------------------------------------------------------
file write resultsfile "\multicolumn{5}{l}{\textbf{Panel C. Binary gender and gender identity }} \\" _n
file write resultsfile "\multicolumn{1}{l}{F-stat (overall)} & `F1_c' & `F2_c' & `F3_c' & `F4_c' & `F5_c'  & `F6_c'  & `F7_c'  & `F8_c'  & `F9_c'  & `F10_c'\\" _n
file write resultsfile "\multicolumn{1}{l}{p-value} & `pval_F1_c' &  `pval_F2_c' & `pval_F3_c' & `pval_F4_c' & `pval_F5_c' & `pval_F6_c' & `pval_F7_c' & `pval_F8_c' & `pval_F9_c' & `pval_F10_c'\\" _n
file write resultsfile "\addlinespace[0.3cm]"
file write resultsfile "\multicolumn{5}{l}{Test: Binary sex=0} \\" _n
file write resultsfile "\multicolumn{1}{l}{F-test} & `F1_c_fem' &  `F2_c_fem' & `F3_c_fem' & `F4_c_fem' & `F5_c_fem' & `F6_c_fem' & `F7_c_fem' & `F8_c_fem' & `F9_c_fem' & `F10_c_fem'\\" _n
file write resultsfile "\multicolumn{1}{l}{p-value} & `pval_F1_c_fem' &  `pval_F2_c_fem' & `pval_F3_c_fem' & `pval_F4_c_fem' & `pval_F5_c_fem' & `pval_F6_c_fem' & `pval_F7_c_fem' & `pval_F8_c_fem' & `pval_F9_c_fem' & `pval_F10_c_fem'\\" _n
file write resultsfile "\addlinespace[0.3cm]"
file write resultsfile "\multicolumn{5}{l}{Test: All CGI dummies=0} \\" _n
file write resultsfile "\multicolumn{1}{l}{F-test} & `F1_c_cgi' &  `F2_c_cgi' & `F3_c_cgi' & `F4_c_cgi' & `F5_c_cgi' & `F6_c_cgi' & `F7_c_cgi' & `F8_c_cgi' & `F9_c_cgi' & `F10_c_cgi'\\" _n
file write resultsfile "\multicolumn{1}{l}{p-value} & `pval_F1_c_cgi' &  `pval_F2_c_cgi' & `pval_F3_c_cgi' & `pval_F4_c_cgi' & `pval_F5_c_cgi' & `pval_F6_c_cgi' & `pval_F7_c_cgi' & `pval_F8_c_cgi' & `pval_F9_c_cgi' & `pval_F10_c_cgi'\\ \\" _n
file write resultsfile "\addlinespace[-0.3cm]"
file write resultsfile "\midrule"

/*
*-----------------------------------------------------------------------------
* Write Panel D
*-----------------------------------------------------------------------------
file write resultsfile "\multicolumn{5}{l}{\textbf{Panel D. Sample split by binary sex }} \\" _n
file write resultsfile "\multicolumn{5}{l}{Female:} \\" _n
file write resultsfile "\multicolumn{1}{l}{F-stat (overall)} & `F1_f' & `F2_f' & `F3_f' & `F4_f' & `F5_f'  & `F6_f'  & `F7_f'  & `F8_f'  & `F9_f'  & `F10_f' \\" _n
file write resultsfile "\multicolumn{1}{l}{p-value} & `pval_F1_f' &  `pval_F2_f' & `pval_F3_f' & `pval_F4_f' & `pval_F5_f' & `pval_F6_f' & `pval_F7_f' & `pval_F8_f' & `pval_F9_f' & `pval_F10_f' \\" _n
file write resultsfile "\addlinespace[0.3cm]"
file write resultsfile "\multicolumn{5}{l}{Male:} \\" _n
file write resultsfile "\multicolumn{1}{l}{F-stat (overall)} & `F1_m' &  `F2_m' & `F3_m' & `F4_m' & `F5_m' & `F6_m' & `F7_m' & `F8_m' & `F9_m' & `F10_m' \\" _n
file write resultsfile "\multicolumn{1}{l}{p-value} & `pval_F1_m' &  `pval_F2_m' & `pval_F3_m' & `pval_F4_m' & `pval_F5_m' & `pval_F6_m' & `pval_F7_m' & `pval_F8_m' & `pval_F9_m' & `pval_F10_m' \\ \\" _n
file write resultsfile "\addlinespace[-0.3cm]"
file write resultsfile "\midrule"
*/
*-----------------------------------------------------------------------------
* Write Obs number row
*-----------------------------------------------------------------------------
file write resultsfile "\multicolumn{1}{l}{Observations} & `N_1' & `N_2' & `N_3' & `N_4' & `N_5' & `N_6' & `N_7' & `N_8' & `N_9' & `N_10' \\ \\" _n
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




