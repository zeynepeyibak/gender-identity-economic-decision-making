clear all

global out_path "$path/3_out" 
		
grstyle init
grstyle set plain, horizontal grid

* Color selection 
local female_color="red"
local male_color="emidblue"
local nonbinary_color="black"

foreach data in SwissUni Swedishyouth usadults_w2_20_60 {
append using "$path/2_do/2_analysis/11_nonbinary/1_`data'.dta"

* Rescale CGI
gen rescaled_cgi_`data'=cgi_main/10
keep if non_binary==1
keep non_binary rescaled_cgi*
}
gen rescaled_cgi=rescaled_cgi_SwissUni
replace rescaled_cgi=rescaled_cgi_Swedishyouth if rescaled_cgi==.
replace rescaled_cgi=rescaled_cgi_usadults_w2_20_60 if rescaled_cgi==.
assert non_binary==1
su rescaled_cgi 
local nonbinary_mean: di %3.2f r(mean)


twoway (histogram rescaled_cgi, xaxis(1 2) xlabel(0 0.2 0.4 0.6 0.8 1) ylabel(0 10 20 30 40 50 60) xtitle("0 for very masculine, 1 for very feminine", axis(1) size(large)) ytitle("percent", size(large)) xtitle("", axis(2)) percent discrete fcolor(`nonbinary_color'%40) lcolor(black%30) xla( `nonbinary_mean' "`nonbinary_mean'" , axis(2) format(%9.3f) labsize(medium)) xline( `nonbinary_mean')) ///
	   , legend(off) 
	   graph export "$out_path/CGI_by_sex/CGI_dist_nonb.jpg", replace as(jpg)



