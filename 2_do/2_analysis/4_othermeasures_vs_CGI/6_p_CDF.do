clear all

global out_path "$path/3_out" 
cd "$path/1_data/4_temp"

grstyle init
grstyle set grid

*-----------------------------------------------------------------------------
* TMF
*-----------------------------------------------------------------------------
use "$path/1_data/5_meta/4_pval_other/tmf.dta", clear

preserve
use "$path/1_data/5_meta/4_pval_other/tmf_KS.dta", clear
su p_val if measure=="tmf"
local KS_tmf: di %4.3f r(mean) 
if `KS_tmf'==0 {
	local KS_tmf="<0.001"
}

su p_val if measure=="CGI"
local KS_CGI: di %4.3f r(mean)
if `KS_CGI'==0 {
	local KS_CGI="<0.001"
}
restore
* 1= cgi, 2=TMF (Stata default order) 
replace measure="TMF" if measure=="tmf"
qui distplot p_val, aspect(.6) over(measure)  lcolor(cranberry navy) xscale(r(0 1)) xlabel(0(0.2)1) lpattern(solid longdash) ///
addplot(function y = x, lcolor(gs8) ysc(r(0 1)) xsc(r(0 1)) clpat(-) lwidth(thin)  legend(region(lcolor(black)) col(2) pos(6) ring(6) order(1 2))) ///
text(1.03 0.07 "p=`KS_tmf'", color(navy)) text(0.98 0.3 "p=`KS_CGI'", color(cranberry)) ytitle("Cumulative frequency") 

graph export "$out_path/Appendix1/meta_p_tmf_1t.jpg", replace
graph close

*-----------------------------------------------------------------------------
* cfni
*-----------------------------------------------------------------------------
use "$path/1_data/5_meta/4_pval_other/cfni.dta", clear

preserve
use "$path/1_data/5_meta/4_pval_other/cfni_KS.dta", clear
su p_val if measure=="cfni"
local KS_cfni: di %4.3f r(mean)
if `KS_cfni'==0 {
	local KS_cfni="<0.001"
}

su p_val if measure=="CGI"
local KS_CGI: di %4.3f r(mean)
if `KS_CGI'==0 {
	local KS_CGI="<0.001"
}
restore

* 1=CFNI, 2=CGI (Stata default order)
replace measure="CFNI" if measure=="cfni"
qui distplot p_val, aspect(.6) over(measure)  lcolor(navy cranberry) xscale(r(0 1)) xlabel(0(0.2)1) lpattern(longdash solid) ///
addplot(function y = x, lcolor(gs8) ysc(r(0 1)) xsc(r(0 1)) clpat(-) lwidth(thin)   legend(region(lcolor(black)) col(2) pos(6) ring(6) order(2 1))) ///
text(0.7 0.87 "p=`KS_cfni'", color(navy)) text(1 0.76 "p=`KS_CGI'", color(cranberry)) ytitle("Cumulative frequency") 

graph export "$out_path/Appendix1/meta_p_cfni_1t.jpg", replace
graph close

*-----------------------------------------------------------------------------
* cmni
*-----------------------------------------------------------------------------
use "$path/1_data/5_meta/4_pval_other/cmni.dta", clear

preserve
use "$path/1_data/5_meta/4_pval_other/cmni_KS.dta", clear
su p_val if measure=="cmni"
local KS_cmni: di  %4.3f r(mean)
if `KS_cmni'==0 {
	local KS_cmni="<0.001"
}
su p_val if measure=="CGI"
local KS_CGI: di %4.3f r(mean)
if `KS_CGI'==0 {
	local KS_CGI="<0.001" 
}
restore

* 1= CGI, 2= CMNI (Stata default order)
replace measure="CMNI" if measure=="cmni"
qui distplot p_val, aspect(.6) over(measure) lcolor(cranberry navy) xscale(r(0 1)) xlabel(0(0.2)1) lpattern(solid longdash) ///
addplot(function y = x, lcolor(gs8) ysc(r(0 1)) xsc(r(0 1)) clpat(-) lwidth(thin)  legend(region(lcolor(black)) col(2) pos(6) ring(6) order(1 2))) ///
text(0.93 0.18 "p=`KS_cmni'", color(navy)) text(1.01 0.84 "p=`KS_CGI'", color(cranberry)) ytitle("Cumulative frequency")

graph export "$out_path/Appendix1/meta_p_cmni_1t.jpg", replace
graph close

*-----------------------------------------------------------------------------
* magliozzi
*-----------------------------------------------------------------------------
use "$path/1_data/5_meta/4_pval_other/magliozzi.dta", clear

preserve
use "$path/1_data/5_meta/4_pval_other/magliozzi_KS.dta", clear
su p_val if measure=="magliozzi fem"
local KS_magliozzi_fem: di  %4.3f r(mean)
if `KS_magliozzi_fem'==0 {
	local KS_magliozzi_fem="<0.001"
}
su p_val if measure=="magliozzi masc"
local KS_magliozzi_masc: di  %4.3f r(mean)
if `KS_magliozzi_masc'==0 {
	local KS_magliozzi_masc="<0.001"
}
su p_val if measure=="CGI"
local KS_CGI: di %4.3f r(mean)
if `KS_CGI'==0 {
	local KS_CGI="<0.001"
}
restore

* 1=CGI, 2=mag fem, 3=mag mas (Stata default order)
replace measure="Magliozzi fem" if measure=="magliozzi fem"
replace measure="Magliozzi mas" if measure=="magliozzi masc"
qui distplot p_val,  aspect(.6) over(measure) lcolor(cranberry navy eltblue) xscale(r(0 1)) xlabel(0(0.2)1) lpattern(solid longdash -.-) ///
addplot(function y = x, lcolor(gs8) ysc(r(0 1)) xsc(r(0 1)) clpat(-) lwidth(thin)  legend(region(lcolor(black)) col(3) pos(6) ring(6) order(1 3 2))) ///
text(1 0.15 "p=`KS_CGI'", color(cranberry)) text(1.01 0.44 "p=`KS_magliozzi_fem'", color(navy)) text(0.95 0.86 "p=`KS_magliozzi_masc'", color(eltblue)) ytitle("Cumulative frequency") 

graph export "$out_path/Appendix1/meta_p_magliozzi_1t.jpg", replace
graph close

*-----------------------------------------------------------------------------
* wangnerud (SOM)
*-----------------------------------------------------------------------------
use "$path/1_data/5_meta/4_pval_other/wangnerud.dta", clear

preserve
use "$path/1_data/5_meta/4_pval_other/wangnerud_KS.dta", clear
su p_val if measure=="wangnerud fem"
local KS_wangnerud_fem: di  %4.3f r(mean)
if `KS_wangnerud_fem'==0 {
	local KS_wangnerud_fem="<0.001"
}
su p_val if measure=="wangnerud masc"
local KS_wangnerud_masc: di  %4.3f r(mean)
if `KS_wangnerud_masc'==0 {
	local KS_wangnerud_masc="<0.001"
}
local KS_CGI: di %4.3f r(mean)
if `KS_CGI'==0 {
	local KS_CGI="<0.001"
}
restore

* 1= CGI, 2= SOM fem, 3=SOM mas (Stata default order)
replace measure="SOM fem" if measure=="wangnerud fem"
replace measure="SOM mas" if measure=="wangnerud masc"
qui distplot p_val, aspect(.6)  over(measure) lcolor(cranberry navy eltblue) xscale(r(0 1)) xlabel(0(0.2)1) lpattern(solid longdash -.-) ///
addplot(function y = x,lcolor(gs8) ysc(r(0 1)) xsc(r(0 1)) clpat(-) lwidth(thin)  legend(region(lcolor(black)) col(3) pos(6) ring(6) order(1 3 2))) ///
text(0.98 0.12 "p=`KS_CGI'", color(cranberry)) text(0.84 0.68 "p=`KS_wangnerud_fem'", color(navy)) text(0.96 0.89 "p=`KS_wangnerud_masc'", color(eltblue)) ytitle("Cumulative frequency") 

graph export "$out_path/Appendix1/meta_p_wangnerud_1t.jpg", replace
graph close

*-----------------------------------------------------------------------------
* osri
*-----------------------------------------------------------------------------
use "$path/1_data/5_meta/4_pval_other/osri.dta", clear

preserve
use "$path/1_data/5_meta/4_pval_other/osri_KS.dta", clear
su p_val if measure=="osri fem"
local KS_osri_fem: di  %4.3f r(mean)
if `KS_osri_fem'==0 {
	local KS_osri_fem="<0.001"
}
su p_val if measure=="osri masc"
local KS_osri_masc: di  %4.0f r(mean)
if `KS_osri_masc'==0 {
	local KS_osri_masc="<0.001"
}
local KS_CGI: di %4.3f r(mean)
if `KS_CGI'==0 {
	local KS_CGI="<0.001"
}
restore

* 1=CGI, 2=OSRI fem, 3=OSRI mas (Stata default order)
replace measure="OSRI fem" if measure=="osri fem"
replace measure="OSRI mas" if measure=="osri masc"
qui distplot p_val, aspect(.6) over(measure) lcolor(cranberry navy eltblue) xscale(r(0 1)) xlabel(0(0.2)1) lpattern(solid longdash -.-) ///
addplot(function y = x, lcolor(gs8) ysc(r(0 1)) xsc(r(0 1)) clpat(-) lwidth(thin)   legend(region(lcolor(black)) col(3) pos(6) ring(6) order(1 3 2))) ///
text(1.01 0.5 "p=`KS_CGI'", color(cranberry)) text(0.82 0.93 "p=`KS_osri_fem'", color(navy)) text(0.95 0.64 "p=`KS_osri_masc'", color(eltblue)) ytitle("Cumulative frequency") 

graph export "$out_path/Appendix1/meta_p_osri_1t.jpg", replace
graph close

*-----------------------------------------------------------------------------
* bsri
*-----------------------------------------------------------------------------
use "$path/1_data/5_meta/4_pval_other/bsri.dta", clear

preserve
use "$path/1_data/5_meta/4_pval_other/bsri_KS.dta", clear
su p_val if measure=="bsri fem"
local KS_bsri_fem: di  %4.3f r(mean)
if `KS_bsri_fem'==0 {
	local KS_bsri_fem="<0.001"
}
su p_val if measure=="bsri masc"
local KS_bsri_masc: di  %4.3f r(mean)
if `KS_bsri_masc'==0 {
	local KS_bsri_masc="<0.001"
}
local KS_CGI: di %4.3f r(mean)
if `KS_CGI'==0 {
	local KS_CGI="<0.001"
}
restore

* 1=BSRI fem, 2= BSRI mas, 3=CGI (Stata default order)
replace measure="BSRI fem" if measure=="bsri fem"
replace measure="BSRI mas" if measure=="bsri masc"
qui distplot p_val,  aspect(.6) over(measure) lcolor(navy eltblue cranberry) xscale(r(0 1)) xlabel(0(0.2)1) lpattern(longdash -.- solid) ///
addplot(function y = x, lcolor(gs8) ysc(r(0 1)) xsc(r(0 1)) clpat(-) lwidth(thin)   legend(region(lcolor(black)) col(3) pos(6) ring(6) order(3 2 1))) ///
text(1.01 0.52 "p=`KS_CGI'", color(cranberry)) text(0.82 0.89 "p=`KS_bsri_fem'", color(navy)) text(0.95 0.85 "p=`KS_bsri_masc'", color(eltblue)) ytitle("Cumulative frequency") 

graph export "$out_path/Appendix1/meta_p_bsri_1t.jpg", replace
graph close

*-----------------------------------------------------------------------------
* cgi
*-----------------------------------------------------------------------------
use "$path/1_data/5_meta/4_pval_other/cgi.dta", clear

preserve
use "$path/1_data/5_meta/4_pval_other/cgi_KS.dta", clear
su p_val if measure=="CGI (other)"
local KS_cgi_other: di %4.3f r(mean)
if `KS_cgi_other'==0 {
	local KS_cgi_other="<0.001"
}

su p_val if measure=="CGI (own)"
local KS_cgi_own: di  %4.3f r(mean)
if `KS_cgi_own'==0 {
	local  KS_cgi_own="<0.001"
}

local KS_CGI: di %4.3f r(mean)
if `KS_CGI'==0 {
	local KS_CGI="<0.001"
}

restore

* 1= CGI, 2=CGI(other), 3=CGI(own) (Stata default order)
qui distplot p_val,  aspect(.6) over(measure) lcolor(cranberry navy eltblue)   xscale(r(0 1)) xlabel(0(0.2)1) lpattern(solid longdash -.-) ///
addplot(function y = x, lcolor(gs8) ysc(r(0 1)) xsc(r(0 1)) clpat(-) lwidth(thin)  legend(region(lcolor(black)) col(3) pos(6) ring(6) order(1 3 2))) ///
text(0.99 0.13 "p=`KS_CGI'", color(cranberry)) text(0.94 0.41 "p=`KS_cgi_other'", color(navy)) text(1.02 0.46 "p=`KS_cgi_own'", color(eltblue)) ytitle("Cumulative frequency") 

graph export "$out_path/Appendix1/meta_p_otherCGIs_1t.jpg", replace
graph close


