global out_path "$path/3_out" 

grstyle init
grstyle set plain, horizontal grid

* Color selection 
local female_color="red"
local male_color="emidblue"

local i=1
* Swiss Uni
foreach data in SwissUni usadults_w1_w2_20_60 swissteens Swedishyouth {
use "$path/1_data/2_prepared/1_`data'.dta", clear


* Rescale CGI
if `i'!=3 {
gen rescaled_cgi=cgi_main/10
}

if `i'==3{ // swiss teens
gen rescaled_cgi=cgi_main/11
}

*Compute mean by gender
su rescaled_cgi if female==1
local female_mean: di %3.2f r(mean)

su rescaled_cgi if female==0
local male_mean: di %3.2f r(mean)

* Titles // Add the option title(`title') to add subtitles
if `i'==1 {
	local title="Swiss Uni" 
}
if `i'==2{ 
	local title="U.S Adults"
}
if `i'==3{
	 local title="Swiss Teens"
}
if `i'==4{ local title="Swedish Youth"
}
*-----------------------------------------------------------------------------
* CGI Histogram by gender
twoway (histogram rescaled_cgi if female==1, xaxis(1 2) xlabel(0 0.2 0.4 0.6 0.8 1) ylabel(0 10 20 30 40) xtitle("0 for very masculine, 1 for very feminine", axis(1) size(large)) ytitle("percent", size(large)) xtitle("", axis(2)) percent discrete fcolor(`female_color'%40) lcolor(black%30) xla(`female_mean' "`female_mean'" `male_mean' "`male_mean'", axis(2) format(%9.3f) labsize(medium)) xline(`female_mean' `male_mean')) ///
       (histogram rescaled_cgi if female==0, xlabel(0 0.2 0.4 0.6 0.8 1) ylabel(0 10 20 30 40) percent discrete fcolor(`male_color'%50)  lcolor(black%30)) ///
	   , legend(off)
	   graph export "$out_path/CGI_by_sex/`data'.jpg", replace as(jpg)
	   
* CGI Histogram by gender
twoway (histogram rescaled_cgi if female==1, xaxis(1 2) xlabel(0 0.2 0.4 0.6 0.8 1) ylabel(0 10 20 30 40) xtitle("0 for very masculine, 1 for very feminine", axis(1) size(medium)) xtitle("", axis(2)) percent discrete fcolor(`female_color'%40) lcolor(black%30) xla(`female_mean' "`female_mean'" `male_mean' "`male_mean'", axis(2) format(%9.3f)) xline(`female_mean' `male_mean')) ///
       (histogram rescaled_cgi if female==0, xlabel(0 0.2 0.4 0.6 0.8 1) ylabel(0 10 20 30 40) percent discrete fcolor(`male_color'%50)  lcolor(black%30)) ///
		,legend(order(1 "Female" 2 "Male") size(small)) 
	   graph export "$out_path/CGI_by_sex/`data'_legon.jpg", replace as(jpg)
	   
*-----------------------------------------------------------------------------
if `i'==2{ //to be used in the appendix
*-----------------------------------------------------------------------------
preserve
keep if age<30

*Compute mean by gender
su rescaled_cgi if female==1
local female_mean: di %3.2f r(mean)

su rescaled_cgi if female==0
local male_mean: di %3.2f r(mean)

twoway (histogram rescaled_cgi if female==1, xaxis(1 2) xlabel(0 0.2 0.4 0.6 0.8 1) ylabel(0 10 20 30 40) xtitle("0 for very masculine, 1 for very feminine", axis(1) size(medsmall)) xtitle("", axis(2)) percent discrete fcolor(`female_color'%40) lcolor(black%30) xla(`female_mean' "`female_mean'" `male_mean' "`male_mean'", axis(2) format(%9.3f)) xline(`female_mean' `male_mean')) ///
       (histogram rescaled_cgi if female==0, xlabel(0 0.2 0.4 0.6 0.8 1) ylabel(0 10 20 30 40) percent discrete fcolor(`male_color'%50)  lcolor(black%30)) ///
	   , legend(off)
	   graph export "$out_path/CGI_by_sex/US_20s.jpg", replace as(jpg)

restore
*-----------------------------------------------------------------------------
preserve
keep if age<40 & age>=30

*Compute mean by gender
su rescaled_cgi if female==1
local female_mean: di %3.2f r(mean)

su rescaled_cgi if female==0
local male_mean: di %3.2f r(mean)

twoway (histogram rescaled_cgi if female==1, xaxis(1 2) xlabel(0 0.2 0.4 0.6 0.8 1) ylabel(0 10 20 30 40) xtitle("0 for very masculine, 1 for very feminine", axis(1) size(medsmall)) xtitle("", axis(2)) percent discrete fcolor(`female_color'%40) lcolor(black%30) xla(`female_mean' "`female_mean'" `male_mean' "`male_mean'", axis(2) format(%9.3f)) xline(`female_mean' `male_mean')) ///
       (histogram rescaled_cgi if female==0, xlabel(0 0.2 0.4 0.6 0.8 1) ylabel(0 10 20 30 40) percent discrete fcolor(`male_color'%50)  lcolor(black%30)) ///
	   , legend(off)
	   graph export "$out_path/CGI_by_sex/US_30s.jpg", replace as(jpg)

restore
*-----------------------------------------------------------------------------
preserve
keep if age<50 & age>=40

*Compute mean by gender
su rescaled_cgi if female==1
local female_mean: di %3.2f r(mean)

su rescaled_cgi if female==0
local male_mean: di %3.2f r(mean)


twoway (histogram rescaled_cgi if female==1, xaxis(1 2) xlabel(0 0.2 0.4 0.6 0.8 1) ylabel(0 10 20 30 40) xtitle("0 for very masculine, 1 for very feminine", axis(1) size(medsmall)) xtitle("", axis(2)) percent discrete fcolor(`female_color'%40) lcolor(black%30) xla(`female_mean' "`female_mean'" `male_mean' "`male_mean'", axis(2) format(%9.3f)) xline(`female_mean' `male_mean')) ///
       (histogram rescaled_cgi if female==0, xlabel(0 0.2 0.4 0.6 0.8 1) ylabel(0 10 20 30 40) percent discrete fcolor(`male_color'%50)  lcolor(black%30)) ///
	   , legend(off)
	   graph export "$out_path/CGI_by_sex/US_40s.jpg", replace as(jpg)

restore
*-----------------------------------------------------------------------------
preserve
keep if age<60 & age>=50

*Compute mean by gender
su rescaled_cgi if female==1
local female_mean: di %3.2f r(mean)

su rescaled_cgi if female==0
local male_mean: di %3.2f r(mean)


twoway (histogram rescaled_cgi if female==1, xaxis(1 2) xlabel(0 0.2 0.4 0.6 0.8 1) ylabel(0 10 20 30 40) xtitle("0 for very masculine, 1 for very feminine", axis(1) size(medsmall)) xtitle("", axis(2)) percent discrete fcolor(`female_color'%40) lcolor(black%30) xla(`female_mean' "`female_mean'" `male_mean' "`male_mean'", axis(2) format(%9.3f)) xline(`female_mean' `male_mean')) ///
       (histogram rescaled_cgi if female==0, xlabel(0 0.2 0.4 0.6 0.8 1) ylabel(0 10 20 30 40) percent discrete fcolor(`male_color'%50)  lcolor(black%30)) ///
	   , legend(off)
	   graph export "$out_path/CGI_by_sex/US_50s.jpg", replace as(jpg)

restore
*-----------------------------------------------------------------------------
preserve
keep if Wave==1

*Compute mean by gender
su rescaled_cgi if female==1
local female_mean: di %3.2f r(mean)

su rescaled_cgi if female==0
local male_mean: di %3.2f r(mean)


twoway (histogram rescaled_cgi if female==1, xaxis(1 2) xlabel(0 0.2 0.4 0.6 0.8 1) ylabel(0 10 20 30 40) xtitle("0 for very masculine, 1 for very feminine", axis(1) size(medsmall)) xtitle("", axis(2)) percent discrete fcolor(`female_color'%40) lcolor(black%30) xla(`female_mean' "`female_mean'" `male_mean' "`male_mean'", axis(2) format(%9.3f)) xline(`female_mean' `male_mean')) ///
       (histogram rescaled_cgi if female==0, xlabel(0 0.2 0.4 0.6 0.8 1) ylabel(0 10 20 30 40) percent discrete fcolor(`male_color'%50)  lcolor(black%30)) ///
	   , legend(off)
	   graph export "$out_path/CGI_by_sex/US_wave1.jpg", replace as(jpg)

restore
*-----------------------------------------------------------------------------
preserve
keep if Wave==2

*Compute mean by gender
su rescaled_cgi if female==1
local female_mean: di %3.2f r(mean)

su rescaled_cgi if female==0
local male_mean: di %3.2f r(mean)


twoway (histogram rescaled_cgi if female==1, xaxis(1 2) xlabel(0 0.2 0.4 0.6 0.8 1) ylabel(0 10 20 30 40) xtitle("0 for very masculine, 1 for very feminine", axis(1) size(medsmall)) xtitle("", axis(2)) percent discrete fcolor(`female_color'%40) lcolor(black%30) xla(`female_mean' "`female_mean'" `male_mean' "`male_mean'", axis(2) format(%9.3f)) xline(`female_mean' `male_mean')) ///
       (histogram rescaled_cgi if female==0, xlabel(0 0.2 0.4 0.6 0.8 1) ylabel(0 10 20 30 40) percent discrete fcolor(`male_color'%50)  lcolor(black%30)) ///
	   , legend(off)
	   graph export "$out_path/CGI_by_sex/US_wave2.jpg", replace as(jpg)

restore	
}
*-----------------------------------------------------------------------------
local i=`i'+1 
di `i'
	   
}
