*-----------------------------------------------------------------------------
* CGI Histograms by Age Group - US Adults
*-----------------------------------------------------------------------------		
grstyle init
grstyle set plain, horizontal grid
global out_path "$path/3_out" 


local female_color = "red"
local male_color   = "emidblue"

use "$path/1_data/2_prepared/1_usadults_w1_w2_20_60.dta", clear
gen rescaled_cgi = cgi_main / 10

*-----------------------------------------------------------------------------
* Ages 20-29
*-----------------------------------------------------------------------------
preserve
keep if age >= 20 & age < 30

su rescaled_cgi if female == 1
local female_mean: di %3.2f r(mean)

su rescaled_cgi if female == 0
local male_mean: di %3.2f r(mean)

twoway ///
    (histogram rescaled_cgi if female == 1, ///
        xaxis(1 2) xlabel(0 0.2 0.4 0.6 0.8 1) ylabel(0 10 20 30 40) ///
        xtitle("0 for very masculine, 1 for very feminine", axis(1) size(medsmall)) ///
        xtitle("", axis(2)) percent discrete ///
        fcolor(`female_color'%40) lcolor(black%30) ///
        xla(`female_mean' "`female_mean'" `male_mean' "`male_mean'", axis(2) format(%9.3f)) ///
        xline(`female_mean' `male_mean')) ///
    (histogram rescaled_cgi if female == 0, ///
        xlabel(0 0.2 0.4 0.6 0.8 1) ylabel(0 10 20 30 40) ///
        percent discrete fcolor(`male_color'%50) lcolor(black%30)) ///
    , legend(off)

graph export "$out_path/CGI_by_sex/US_20s.jpg",      replace as(jpg)
restore

*-----------------------------------------------------------------------------
* Ages 30-39
*-----------------------------------------------------------------------------
preserve
keep if age >= 30 & age < 40

su rescaled_cgi if female == 1
local female_mean: di %3.2f r(mean)

su rescaled_cgi if female == 0
local male_mean: di %3.2f r(mean)

twoway ///
    (histogram rescaled_cgi if female == 1, ///
        xaxis(1 2) xlabel(0 0.2 0.4 0.6 0.8 1) ylabel(0 10 20 30 40) ///
        xtitle("0 for very masculine, 1 for very feminine", axis(1) size(medsmall)) ///
        xtitle("", axis(2)) percent discrete ///
        fcolor(`female_color'%40) lcolor(black%30) ///
        xla(`female_mean' "`female_mean'" `male_mean' "`male_mean'", axis(2) format(%9.3f)) ///
        xline(`female_mean' `male_mean')) ///
    (histogram rescaled_cgi if female == 0, ///
        xlabel(0 0.2 0.4 0.6 0.8 1) ylabel(0 10 20 30 40) ///
        percent discrete fcolor(`male_color'%50) lcolor(black%30)) ///
    , legend(off)

graph export "$out_path/CGI_by_sex/US_30s.jpg",      replace as(jpg)
restore

*-----------------------------------------------------------------------------
* Ages 40-49
*-----------------------------------------------------------------------------
preserve
keep if age >= 40 & age < 50

su rescaled_cgi if female == 1
local female_mean: di %3.2f r(mean)

su rescaled_cgi if female == 0
local male_mean: di %3.2f r(mean)

twoway ///
    (histogram rescaled_cgi if female == 1, ///
        xaxis(1 2) xlabel(0 0.2 0.4 0.6 0.8 1) ylabel(0 10 20 30 40) ///
        xtitle("0 for very masculine, 1 for very feminine", axis(1) size(medsmall)) ///
        xtitle("", axis(2)) percent discrete ///
        fcolor(`female_color'%40) lcolor(black%30) ///
        xla(`female_mean' "`female_mean'" `male_mean' "`male_mean'", axis(2) format(%9.3f)) ///
        xline(`female_mean' `male_mean')) ///
    (histogram rescaled_cgi if female == 0, ///
        xlabel(0 0.2 0.4 0.6 0.8 1) ylabel(0 10 20 30 40) ///
        percent discrete fcolor(`male_color'%50) lcolor(black%30)) ///
    , legend(off)

graph export "$out_path/CGI_by_sex/US_40s.jpg",      replace as(jpg)
restore

*-----------------------------------------------------------------------------
* Ages 50-60 (inclusive)
*-----------------------------------------------------------------------------
preserve
keep if age >= 50 & age <= 60

su rescaled_cgi if female == 1
local female_mean: di %3.2f r(mean)

su rescaled_cgi if female == 0
local male_mean: di %3.2f r(mean)

twoway ///
    (histogram rescaled_cgi if female == 1, ///
        xaxis(1 2) xlabel(0 0.2 0.4 0.6 0.8 1) ylabel(0 10 20 30 40) ///
        xtitle("0 for very masculine, 1 for very feminine", axis(1) size(medsmall)) ///
        xtitle("", axis(2)) percent discrete ///
        fcolor(`female_color'%40) lcolor(black%30) ///
        xla(`female_mean' "`female_mean'" `male_mean' "`male_mean'", axis(2) format(%9.3f)) ///
        xline(`female_mean' `male_mean')) ///
    (histogram rescaled_cgi if female == 0, ///
        xlabel(0 0.2 0.4 0.6 0.8 1) ylabel(0 10 20 30 40) ///
        percent discrete fcolor(`male_color'%50) lcolor(black%30)) ///
    , legend(off)

graph export "$out_path/CGI_by_sex/US_50s.jpg",      replace as(jpg)
restore
