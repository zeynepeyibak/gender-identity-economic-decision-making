
clear all

global out_path "$path/3_out"

use "$path/1_data/5_meta/5_R2_other/Rsquared_across_measures.dta"

replace scale = "OSRI F" if scale == "OSRI_F"
replace scale = "OSRI M" if scale == "OSRI_M"
replace scale = "BSRI F" if scale == "BSRI_F"
replace scale = "BSRI M" if scale == "BSRI_M"

egen Mean = rowmean(risk_incent risk_unincent risk_financ competitive redistribution female_educ income homemaker workhours managresp wagenegot) 
egen StDev = rowsd(risk_incent risk_unincent risk_financ competitive redistribution female_educ income homemaker workhours managresp wagenegot) 
g StdErr = StDev / sqrt(11)
g Hi95 = Mean + 2*StdErr
g Lo95 = Mean - 2*StdErr

egen Mean_NoRiskComp = rowmean(risk_incent risk_financ redistribution female_educ income homemaker workhours managresp wagenegot) 


*** Graph comparing CGI with other one-item scales
preserve

drop if scale == "CGI_own"
drop if scale == "CGI_other"
drop if items > 1

g items2 = items
replace items2 = 1 if scale == "CGI"
replace items2 = 1.2 if scale == "Mag_F"
replace items2 = 1.35 if scale == "Mag_M"
replace items2 = 1.55 if scale == "SOM_F"
replace items2 = 1.7 if scale == "SOM_M"

twoway (bar Mean items2 if scale == "CGI", fcolor(dknavy) lcolor(dknavy) barwidth(.1)) /// 
	(bar Mean items2 if scale == "Mag_F" | scale == "Mag_M", fcolor(midblue) lcolor(dknavy) barwidth(.1)) ///
	(bar Mean items2 if scale == "SOM_F" | scale == "SOM_M", fcolor(emidblue) lcolor(dknavy) barwidth(.1)) ///
	(rcap Hi95 Lo95 items2, lcolor(dknavy)), ///
	ytitle("Average R-squared") ylabel(0(.02).12) ///
	xtitle("Scale (one-item scales)") xlabel(1 "CGI" 1.2 "Magliozzi F" 1.35 "Magliozzi M" 1.55 "SOM F" 1.7 "SOM M", noticks) ///
	 legend(off)  xsize(6)
graph export "$out_path/Appendix1/R-squared_1item.jpg", replace as(jpg) name("Graph") quality(90)
restore


*** Graph comparing CGI with multi-item scales
preserve

drop if scale == "CGI_own"
drop if scale == "CGI_other"
drop if scale == "Mag_F"
drop if scale == "Mag_M"
drop if scale == "SOM_F"
drop if scale == "SOM_M"

twoway (scatter Mean items if scale == "CGI", mcolor(dknavy) msize(medlarge) mlabel(scale) mlabsize(small) mlabcolor(dknavy)) ///
	(scatter Mean items if (scale != "CGI" & scale != "BSRI F"), mcolor(midblue) msize(medlarge) msymbol(diamond) mlabel(scale) mlabcolor(dknavy) mlabposition(2) ) ///
	(scatter Mean items if (scale == "BSRI F"), mcolor(midblue) msize(medlarge) msymbol(diamond) mlabel(scale) mlabcolor(dknavy) mlabposition(8) mlabgap(tiny)) ///
	(rcap Hi95 Lo95 items, lcolor(navy%50)), ///
	ytitle("Average R-squared") ylabel(0(.02).12) ///
	xtitle("Number of items in scale") legend(off) xsize(6)
graph export "$out_path/Appendix1/R-squared_multi_item.jpg", replace as(jpg) name("Graph") quality(90)
restore




