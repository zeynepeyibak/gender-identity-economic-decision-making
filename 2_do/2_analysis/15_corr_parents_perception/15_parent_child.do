clear all

global out_path "$path/3_out" 
		

/********************************************************************
1. Variables used in the validation exercise
********************************************************************/

local child_id cid_student_response
local child_cgi stu_gid_child
local parent_cgi par_gid_child

use "$path/1_data/1_rawdata/parents_swissteens/parents_swissteens.dta", clear
keep if !missing(`child_id', `child_cgi', `parent_cgi')
keep if inrange(`child_cgi', 0, 10) & inrange(`parent_cgi', 0, 10)

/********************************************************************
2. Construct child-level parent assessment
********************************************************************/

bysort `child_id': egen double parent_assessment = mean(`parent_cgi')
bysort `child_id': gen int n_parent_reports = _N
bysort `child_id': keep if _n == 1

gen double parent_minus_child = parent_assessment - `child_cgi'
gen double abs_parent_minus_child = abs(parent_minus_child)

label variable `child_cgi' "Child self-reported CGI"
label variable parent_assessment "Parent assessment of child's CGI"
label variable parent_minus_child "Parent assessment minus child self-report"

/********************************************************************
3. Statistics reported in the manuscript and appendix
********************************************************************/

quietly count
local N_child = r(N)

quietly count if n_parent_reports > 1
local N_multiple_parent = r(N)

quietly correlate parent_assessment `child_cgi'
matrix R = r(C)
local pearson = R[1,2]

quietly spearman parent_assessment `child_cgi'
local spearman = r(rho)

quietly summarize parent_minus_child, detail
local mean_diff = r(mean)
local median_diff = r(p50)

quietly summarize abs_parent_minus_child
local mean_abs_diff = r(mean)

quietly count if abs_parent_minus_child <= 1
local within_one = 100 * r(N) / `N_child'

quietly count if abs_parent_minus_child <= 2
local within_two = 100 * r(N) / `N_child'

display as text "Parent-child CGI validation, child-level sample"
display as text "N children: " as result `N_child'
display as text "Children with multiple parent reports: " as result `N_multiple_parent'
display as text "Pearson correlation: " as result %6.3f `pearson'
display as text "Spearman correlation: " as result %6.3f `spearman'
display as text "Median parent-child difference: " as result %6.3f `median_diff'
display as text "Mean absolute parent-child difference: " as result %6.3f `mean_abs_diff'
display as text "Percent within one point: " as result %6.1f `within_one'
display as text "Percent within two points: " as result %6.1f `within_two'

capture file close summary
file open summary using "$out_path/parent_child_validation_summary.csv", write replace text
file write summary "statistic,value" _n
file write summary "N children,`N_child'" _n
file write summary "children with multiple parent reports,`N_multiple_parent'" _n
file write summary "Pearson correlation," %12.9f (`pearson') _n
file write summary "Spearman correlation," %12.9f (`spearman') _n
file write summary "mean parent-child difference," %12.9f (`mean_diff') _n
file write summary "median parent-child difference," %12.9f (`median_diff') _n
file write summary "mean absolute parent-child difference," %12.9f (`mean_abs_diff') _n
file write summary "percent within one point," %12.9f (`within_one') _n
file write summary "percent within two points," %12.9f (`within_two') _n
file close summary

/********************************************************************
4. Figure A, Panel A: parent assessment and child self-report
********************************************************************/

bysort `child_cgi': egen double bin_parent_assessment = mean(parent_assessment)
bysort `child_cgi': egen int bin_n = count(parent_assessment)
bysort `child_cgi': gen byte bin_tag = (_n == 1)

gen byte size_group = .
replace size_group = 1 if bin_n < 10
replace size_group = 2 if inrange(bin_n, 10, 24)
replace size_group = 3 if inrange(bin_n, 25, 49)
replace size_group = 4 if inrange(bin_n, 50, 74)
replace size_group = 5 if bin_n >= 75

twoway ///
    (scatter bin_parent_assessment `child_cgi' if bin_tag & size_group == 1, ///
        msymbol(circle) mcolor(gs6) msize(small)) ///
    (scatter bin_parent_assessment `child_cgi' if bin_tag & size_group == 2, ///
        msymbol(circle) mcolor(gs6) msize(medium)) ///
    (scatter bin_parent_assessment `child_cgi' if bin_tag & size_group == 3, ///
        msymbol(circle) mcolor(gs6) msize(large)) ///
    (scatter bin_parent_assessment `child_cgi' if bin_tag & size_group == 4, ///
        msymbol(circle) mcolor(gs6) msize(vlarge)) ///
    (scatter bin_parent_assessment `child_cgi' if bin_tag & size_group == 5, ///
        msymbol(circle) mcolor(gs6) msize(huge)) ///
    (qfit parent_assessment `child_cgi', lcolor(gs8) lwidth(medthick)), ///
    xlabel(0(2)10) ylabel(0(2)10) ///
    xscale(range(0 10)) yscale(range(0 10)) ///
    xtitle("Child self-report") ///
    ytitle("Parent assessment") legend(off) ///
    graphregion(color(white)) plotregion(color(white))

graph export "$out_path/parent-child/parent_child_validation_binscatter.png", replace 

/********************************************************************
5. Figure A, Panel B: parent assessment minus child self-report
********************************************************************/
twoway ///
    (histogram parent_minus_child, width(.5) start(-10) percent ///
        fcolor(gs8) lcolor(white)) ///
    (pci 0 0 41 0, lcolor(black) lpattern(solid) lwidth(thick)), ///
    xlabel(-10(2)10) ///
    xtitle("Parent assessment minus child self-report") ///
    ytitle("Percent") ///
    legend(off) ///
    graphregion(color(white)) plotregion(color(white))
graph export "$out_path/parent-child/parent_child_validation_difference_hist.png", replace

