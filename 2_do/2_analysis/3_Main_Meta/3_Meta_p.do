clear all

global out_path "$path/3_out" 
		
grstyle init
grstyle set plain, horizontal grid

*-----------------------------------------------------------------------------
* CDF Pooled - 1t
*-----------------------------------------------------------------------------
clear all
forvalues i=3/7{
	append using "$path/1_data/5_meta/1_pval/table_`i'_panelC"
}
drop if dropped_panelC==1

* Gen CDF
rename p_c_cgi_1t pval
sort pval
cumul pval, gen(cumul_pval)

preserve
use "$path/1_data/5_meta/1_pval/CGI_pooled_KS.dta",clear
su ks_p_val
local KS: di %4.3f r(mean) 
if `KS'==0 {
	local KS="<0.001"
}
restore 
twoway line cumul_pval pval, lcolor(cranberry) ///
|| function y = x,  aspect(.6) lcolor(gs8) ysc(r(0 1)) xsc(r(0 1)) clpat(-) lwidth(thin) ytitle("Cumulative frequency") legend(off) ///
 text(1.03 0.88  "p=`KS'", color(cranberry)) 
graph export "$out_path/meta_p_1t.jpg", replace

*-----------------------------------------------------------------------------
* CDF by sex - 1t
*-----------------------------------------------------------------------------

clear
forvalues i=3/7{
	append using "$path/1_data/5_meta/1_pval/table_`i'_panelD"
}
drop if dropped_panelC==1

* KS - female
preserve
use "$path/1_data/5_meta/1_pval/CGI_female_KS.dta",clear
su ks_p_value_f

local ks_p_value_f: di %4.3f r(mean) 
if `ks_p_value_f'==0 {
	local ks_p_value_f="<0.001"
}
restore

* KS - male
preserve
use "$path/1_data/5_meta/1_pval/CGI_male_KS.dta",clear
su ks_p_value_m

local ks_p_value_m: di %4.3f r(mean) 
if `ks_p_value_m'==0 {
	local ks_p_value_m="<0.001"
}
restore

stack p_f_cgi_1t p_m_cgi_1t, into(p_val) wide clear
assert _stack==1 if p_f_cgi_1t!=. //1 => female

gen sex="Female" if _stack==1 //female
replace sex="Male" if _stack==2 //male

distplot p_val, aspect(.6)  over(sex) lcolor(cranberry ebblue) xscale(r(0 1)) xlabel(0(0.2)1)  legend(region(lcolor(black)) col(2)) ///
addplot(function y = x, lcolor(gs8) ysc(r(0 1)) xsc(r(0 1)) clpat(-) lwidth(thin)) legend(pos(6) ring(6) order(2 1)) ///
text(1.03 0.77 "p=`ks_p_value_m'", color(ebblue)) ytitle("Cumulative frequency") text(0.8 0.95  "p=`ks_p_value_f'", color(cranberry))

graph export "$out_path/Meta/meta_p_bysex_1t.jpg", replace

