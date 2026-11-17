clear all

global out_path "$path/3_out" // replicator edits this line

do "$path/2_do/2_analysis/0_reg_fnc/0_regressions.do"
use "$path/1_data/2_prepared/1_usadults_w2_20_60.dta", replace


/*
In order to be able to retrieve the standard errors out of a pairwise correlation, I am running separate regressions for each cell
For regression coeff to be the same as pwcorr coeff, all the variables need to be standardized. 
However, as standardization is done both for wave 1 and wave2 together, we need to re-standardize them after deleting observations where 
either one of the variables have missing observations. (i.e. pairwise deletion)
As a sanity check, it is possible to see by running pwcorr that we get the exact same results.
*/


* Observation counts used in table notes
count if std_cgi_main!=. //2,659
count if std_tmf_score!=. //2,659
count if std_magliozzi_fem!=. //2,659
count if std_magliozzi_mas !=. //2,659
count if std_wangnerud_fem!=. //2,659
count if std_wangnerud_mas!=. //2,659
count if std_osri_fem!=. //662
count if std_osri_mas!=. //662
count if std_cfni_score!=. //659
count if std_cmni_score!=. //662
count if std_bsri_fem!=. //676
count if std_bsri_masc!=. //676
count if std_first_component!=. //2,659

pwcorr std_cgi_main std_tmf_score std_magliozzi_fem std_magliozzi_mas std_wangnerud_fem std_wangnerud_mas std_osri_fem std_osri_mas std_cfni_score std_cmni_score std_bsri_fem std_bsri_masc std_first_component
drop std_*

* cgi_main
local i=1
foreach x of varlist tmf_score magliozzi_fem magliozzi_mas wangnerud_feminine wangnerud_masculine osri_fem osri_mas cfni_score cmni_score bsri_fem bsri_masc first_component {
preserve
keep if cgi_main!=. & `x'!=. //bc pairwise

//standardize
su `x'
gen std_`x'=(`x'-r(mean))/r(sd)

su cgi_main
gen std_cgi_main=(cgi_main-r(mean))/r(sd)

reg std_cgi_main std_`x'
beta_coeff2 std_`x'
local corr_`i'_1 `r(beta)'
local se_`i'_1 `r(se)'
local i=`i'+1
restore
}


*tmf_score
local i=2
foreach x of varlist magliozzi_fem magliozzi_mas wangnerud_feminine wangnerud_masculine osri_fem osri_mas cfni_score cmni_score bsri_fem bsri_masc first_component {
preserve
keep if tmf_score!=. & `x'!=. //bc pairwise

//standardize
su `x'
gen std_`x'=(`x'-r(mean))/r(sd)

su tmf_score 
gen std_tmf_score=(tmf_score -r(mean))/r(sd)

reg std_tmf_score std_`x'
beta_coeff2 std_`x'
local corr_`i'_2 `r(beta)'
local se_`i'_2 `r(se)'
local i=`i'+1
restore
}

* magliozzi_fem
local i=3
foreach x of varlist magliozzi_mas wangnerud_feminine wangnerud_masculine osri_fem osri_mas cfni_score cmni_score bsri_fem bsri_masc first_component {
preserve
keep if magliozzi_fem!=. & `x'!=. //bc pairwise

//standardize
su `x'
gen std_`x'=(`x'-r(mean))/r(sd)

su magliozzi_fem
gen std_magliozzi_fem=( magliozzi_fem-r(mean))/r(sd)

reg std_magliozzi_fem std_`x', noconstant
beta_coeff2 std_`x'
local corr_`i'_3 `r(beta)'
local se_`i'_3 `r(se)'
local i=`i'+1
restore
}


* magliozzi_mas
local i=4
foreach x of varlist wangnerud_feminine wangnerud_masculine osri_fem osri_mas cfni_score cmni_score bsri_fem bsri_masc first_component {
preserve
keep if magliozzi_mas!=. & `x'!=. //bc pairwise

//standardize
su `x'
gen std_`x'=(`x'-r(mean))/r(sd)

su magliozzi_mas
gen std_magliozzi_mas=(magliozzi_mas-r(mean))/r(sd)

reg std_magliozzi_mas std_`x', noconstant
beta_coeff2 std_`x'
local corr_`i'_4 `r(beta)'
local se_`i'_4 `r(se)'
local i=`i'+1
restore
}

* wangnerud_feminine
local i=5
foreach x of varlist wangnerud_masculine osri_fem osri_mas cfni_score cmni_score bsri_fem bsri_masc first_component {
preserve
keep if wangnerud_feminine!=. & `x'!=. //bc pairwise

//standardize
su `x'
gen std_`x'=(`x'-r(mean))/r(sd)

su wangnerud_feminine
gen std_wangnerud_feminine=(wangnerud_feminine-r(mean))/r(sd)


reg std_wangnerud_feminine std_`x', noconstant
beta_coeff2 std_`x'
local corr_`i'_5 `r(beta)'
local se_`i'_5 `r(se)'
local i=`i'+1
restore
}

* std_wangnerud_masculine
local i=6
foreach x of varlist osri_fem osri_mas cfni_score cmni_score bsri_fem bsri_masc first_component {
preserve
keep if wangnerud_masculine!=. & `x'!=. //bc pairwise

//standardize
su `x'
gen std_`x'=(`x'-r(mean))/r(sd)

su wangnerud_masculine
gen std_wangnerud_masculine=(wangnerud_masculine-r(mean))/r(sd)

reg std_wangnerud_masculine std_`x', noconstant
beta_coeff2 std_`x'
local corr_`i'_6 `r(beta)'
local se_`i'_6 `r(se)'
local i=`i'+1
restore
}


foreach path in out_path {
	
file open resultsfile using  "$`path'/Tables_Main_Paper/table_1.tex", write replace

//file write resultsfile " \begin{table}[H]"
//file write resultsfile "\begin{adjustbox}{max width=16cm}"
//file write resultsfile "\begin{threeparttable}" 
file write resultsfile "\caption{Correlation Matrix of all Gender Scales} \centering \begin{tabular} {p{2.5cm} M{2.5cm} M{2.5cm} M{2.5cm} M{2.5cm} M{2.5cm} M{2.5cm}} \toprule \toprule Variables & \textbf{CGI}  & TMF  &   Magliozzi (f) &   Magliozzi (m)  &  SOM (f) &   SOM (m) \\ \addlinespace[0.2cm] \hline \\" _n

file write resultsfile " TMF   & $`corr_1_1'$  &  \phantom{$`corr_1_2'$} &  \phantom{$`corr_1_3'$} &	\phantom{$`corr_1_4'$} &	\phantom{$`corr_1_5'$}  &	 \phantom{$`corr_1_6'$}  \\" _n
file write resultsfile "\addlinespace[0.05cm]"
file write resultsfile "\phantom{TMF} &  (`se_1_1')  &  \phantom{(`se_1_2')} &  \phantom{(`se_1_3')} &	\phantom{(`se_1_4')} &	\phantom{(`se_1_5')}  &	 \phantom{(`se_1_6')}  \\ \\" _n 
file write resultsfile "\addlinespace[-0.3cm]"

file write resultsfile "Magliozzi (f)  &  $`corr_2_1'$  &  $`corr_2_2'$ &  \phantom{$`corr_2_3'$} &	\phantom{$`corr_2_4'$} &	\phantom{$`corr_2_5'$}  &	 \phantom{$`corr_2_6'$}  \\ " _n 
file write resultsfile "\addlinespace[0.05cm]"
file write resultsfile "& \phantom{} (`se_2_1')  &  (`se_2_2') &  \phantom{(`se_2_3')} &	\phantom{(`se_2_4')} &	\phantom{(`se_2_5')}  &	 \phantom{(`se_2_6')}  \\ \\" _n 
file write resultsfile "\addlinespace[-0.3cm]"

file write resultsfile " Magliozzi (m)   &  $`corr_3_1'$  &  $`corr_3_2'$ &  $`corr_3_3'$ &	\phantom{$`corr_3_4'$} &	\phantom{$`corr_3_5'$}  &	 \phantom{$`corr_3_6'$}  \\ "  _n
file write resultsfile "\addlinespace[0.05cm]"
file write resultsfile "   \phantom{} &  (`se_3_1')  &  (`se_3_2') &  (`se_3_3') &	\phantom{(`se_3_4')} &	\phantom{(`se_3_5')}  &	 \phantom{(`se_3_6')}  \\ \\" _n 
file write resultsfile "\addlinespace[-0.3cm]"

file write resultsfile " SOM (f)   &  $`corr_4_1'$  &  $`corr_4_2'$ &  $`corr_4_3'$ &	$`corr_4_4'$ &	\phantom{$`corr_4_5'$}  &	 \phantom{$`corr_4_6'$}  \\ " _n 
file write resultsfile "\addlinespace[0.05cm]"
file write resultsfile "   \phantom{} &  (`se_4_1')  &  (`se_4_2') &  (`se_4_3') &	(`se_4_4') &	\phantom{(`se_4_5')}  &	 \phantom{(`se_4_6')}  \\ \\"  _n
file write resultsfile "\addlinespace[-0.3cm]"

file write resultsfile "  SOM (m)   &  $`corr_5_1'$  &  $`corr_5_2'$ &  $`corr_5_3'$ &	$`corr_5_4'$ &	$`corr_5_5'$  &	 \phantom{$`corr_5_6'$}  \\ " _n 
file write resultsfile "\addlinespace[0.05cm]"
file write resultsfile "  \phantom{} &  (`se_5_1')  &  (`se_5_2') &  (`se_5_3') &	(`se_5_4') &	(`se_5_5')  &	 \phantom{(`se_5_6')}  \\ \\"  _n
file write resultsfile "\addlinespace[-0.3cm]"

file write resultsfile "  OSRI (f)   &  $`corr_6_1'$  &  $`corr_6_2'$ &  $`corr_6_3'$ &	$`corr_6_4'$ &	$`corr_6_5'$  &	 $`corr_6_6'$  \\ " _n 
file write resultsfile "\addlinespace[0.05cm]"
file write resultsfile "  \phantom{}  &  (`se_6_1')  &  (`se_6_2') &  (`se_6_3') &	(`se_6_4') &	(`se_6_5')  &	 (`se_6_6') \\ \\"  _n
file write resultsfile "\addlinespace[-0.3cm]"

file write resultsfile "   OSRI (m) &  $`corr_7_1'$  &  $`corr_7_2'$ &  $`corr_7_3'$ &	$`corr_7_4'$ &	$`corr_7_5'$  &	 $`corr_7_6'$  \\ " _n 
file write resultsfile "\addlinespace[0.05cm]"
file write resultsfile "  \phantom{}  &  (`se_7_1')  &  (`se_7_2') &  (`se_7_3') &	(`se_7_4') &	(`se_7_5')  &	 (`se_7_6') \\ \\" _n 
file write resultsfile "\addlinespace[-0.3cm]"

file write resultsfile "  CFNI  &  $`corr_8_1'$  &  $`corr_8_2'$ &  $`corr_8_3'$ &	$`corr_8_4'$ &	$`corr_8_5'$  &	 $`corr_8_6'$  \\ " _n 
file write resultsfile "\addlinespace[0.05cm]"
file write resultsfile "  \phantom{}  &  (`se_8_1')  &  (`se_8_2') &  (`se_8_3') &	(`se_8_4') &	(`se_8_5')  &	 (`se_8_6') \\ \\" _n 
file write resultsfile "\addlinespace[-0.3cm]"

file write resultsfile "  CMNI  &  $`corr_9_1'$  &  $`corr_9_2'$ &  $`corr_9_3'$ &	$`corr_9_4'$ &	$`corr_9_5'$  &	 $`corr_9_6'$  \\ " _n 
file write resultsfile "\addlinespace[0.05cm]"
file write resultsfile "  \phantom{}  &  (`se_9_1')  &  (`se_9_2') &  (`se_9_3') &	(`se_9_4') &	(`se_9_5')  &	 (`se_9_6') \\ \\" _n 
file write resultsfile "\addlinespace[-0.3cm]"

file write resultsfile "  BSRI (f)   &  $`corr_10_1'$  &  $`corr_10_2'$ &  $`corr_10_3'$ &	$`corr_10_4'$ &	$`corr_10_5'$  &	 $`corr_10_6'$  \\ " _n 
file write resultsfile "\addlinespace[0.05cm]"
file write resultsfile "  \phantom{}  &  (`se_10_1')  &  (`se_10_2') &  (`se_10_3') &	(`se_10_4') &	(`se_10_5')  &	 (`se_10_6') \\ \\" _n 
file write resultsfile "\addlinespace[-0.3cm]"

file write resultsfile "  BSRI (m) &  $`corr_11_1'$  &  $`corr_11_2'$ &  $`corr_11_3'$ &	$`corr_11_4'$ &	$`corr_11_5'$  &	 $`corr_11_6'$  \\ " _n 
file write resultsfile "\addlinespace[0.05cm]"
file write resultsfile "  \phantom{}  &  (`se_11_1')  &  (`se_11_2') &  (`se_11_3') &	(`se_11_4') &	(`se_11_5')  &	 (`se_11_6') \\ \\" _n 
file write resultsfile "\addlinespace[-0.3cm]"

file write resultsfile "  First comp  &  $`corr_12_1'$  &  $`corr_12_2'$ &  $`corr_12_3'$ &	$`corr_12_4'$ &	$`corr_12_5'$  &	 $`corr_12_6'$  \\" _n 
file write resultsfile "\addlinespace[0.05cm]"
file write resultsfile "  \phantom{}  &  (`se_12_1')  &  (`se_12_2') &  (`se_12_3') &	(`se_12_4') &	(`se_12_5')  &	 (`se_12_6') \\ \\" _n 
file write resultsfile "\addlinespace[-0.3cm]"

file write resultsfile "\bottomrule \bottomrule \end{tabular}"
//file write resultsfile "\begin{tablenotes}[para,flushleft] \small"_n

//file write resultsfile "\item \textit{Note}: The table represents the correlations between the continuous gender measures.  U.S. Adults wave 2 (age 20-59) sample is used. 'f' refers to femininity  and 'm'  refers to masculinity score of the two-dimensional scales BSRI, OSRI, Magliozzi and SOM. CGI and TMF are unidimensional scales on which higher values mean higher femininity. CFNI and CMNI are the conformity to feminine and masculine norm inventories. First comp is a variable that is a combination of the first components of the principal component analyses. Standard errors are reported in the brackets below the coefficients. The significance levels in this table are *** p$<$0.005, ** p$<$0.01, * p$<$0.05. " _n

//file write resultsfile "\end{tablenotes} \end{threeparttable} \end{adjustbox} \end{table}"


file close resultsfile
}


