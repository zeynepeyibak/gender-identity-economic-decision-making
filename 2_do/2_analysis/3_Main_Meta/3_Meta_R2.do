clear all

global out_path "$path/3_out"
		
grstyle init
grstyle set plain, horizontal grid

* append
clear all
forvalues i=3/7{
	append using "$path/1_data/5_meta/2_R2/table_`i'"
}
drop if dropped_panelC==1

* Create the scatter plot: scatter y x
twoway (scatter panelC panelA, msymbol(Oh) mcolor(cranberry) leg(off) msize(medsmall) xscale(r(0(0.1)0.5)) xlabel(0 0.1 0.2 0.3 0.4 0.5) ylabel(0 0.1 0.2 0.3 0.4 0.5) yscale(r(0(0.1)0.5)) xtitle("Panel A R2") ytitle("Panel C R2")) ///
(function y = x, clpat(.-.) range(0 0.5) lcolor(eltblue))
graph export "$out_path/Meta/meta_R2.jpg", replace

* Create a plot of change in R2
gen increase_R2=panelC-panelA
assert increase_R2>0
scatter increase_R2 panelA, msymbol(Oh) msize(medsmall) mcolor(cranberry) leg(off) xscale(r(0 0.5)) yscale(r(0 0.015)) ylabel(0(0.005)0.015) ytitle("Increase in R2") xtitle("Panel A R2")
graph export "$out_path/Meta/meta_R2_increaseinR2.jpg", replace

* Create scatter plot if R2<0.1
keep if panelA<0.1 // 4 obs deleted
twoway (scatter panelC panelA, msymbol(Oh) mcolor(cranberry) leg(off) msize(medsmall) xscale(r(0 0.1))  yscale(r(0 0.1)) xtitle("Panel A R2") ytitle("Panel C R2")) ///
(function y = x, clpat(.-.) range(0 0.1) lcolor(eltblue))
graph export "$out_path/Meta/meta_R2_cropped.jpg", replace

* Scatter Plot of Panel D: Females vs Males
twoway (scatter panelD_m panelD_f, msymbol(Oh) mcolor(cranberry) leg(off) msize(medsmall) xscale(r(0 0.06))  yscale(r(0 0.06)) ylabel(0(0.01)0.06) xlabel(0(0.01)0.06) xtitle("Female R2") ytitle("Male R2")) ///
(function y = x, clpat(.-.) range(0 0.06) lcolor(eltblue))

graph export "$out_path/Meta/meta_R2_panelD.jpg", replace

