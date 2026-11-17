clear all

global out_path "$path/3_out" 
		
grstyle init
grstyle set plain, horizontal grid

use "$path/1_data/2_prepared/1_usadults_w2_20_60.dta", clear

***********************************************************************************
****************************** Make Binned Scatter Plots **************************
***********************************************************************************

*******CGI and its own components 

// First-order CGI vs. Third-Order CGI
qui binscatter std_cgi_main std_cgi_other, line(qfit) ///
   ylabel(, nogrid) legend(off) ///		       
   ytitle("CGI", size(medsmall)) ///
   xtitle("CGI (other)", size(medsmall)) mcolor(gs6) lcolor(gs8)
	graph export "$out_path/binned_scatter/bin_cgi_cgiother.jpg", replace
   
// First-order CGI vs. Own Gender CGI
qui binscatter std_cgi_main std_cgi_own, line(qfit) ///
   ylabel(, nogrid) legend(off) ///		       
   ytitle("CGI", size(medsmall)) ///
   xtitle("CGI (own)", size(medsmall)) mcolor(gs6) lcolor(gs8)
	graph export "$out_path/binned_scatter/bin_cgi_cgiown.jpg", replace
    
*******CGI and all other gender measures: BSRI, OSRI, CMNI, CFNI, TMF, Magliozzi, Markstedt 

// CGI vs. BSRI Fem
qui binscatter std_cgi_main std_bsri_fem, line(qfit) ///
   ylabel(, nogrid) legend(off) ///		       
   ytitle("CGI", size(medsmall)) ///
   xtitle("BSRI Fem", size(medsmall)) mcolor(gs6) lcolor(gs8)
	graph export "$out_path/binned_scatter/bin_cgi_bsrifem.jpg", replace

// CGI vs. BSRI Masc
qui binscatter std_cgi_main std_bsri_masc, line(qfit) ///
   ylabel(, nogrid) legend(off) ///		       
   ytitle("CGI", size(medsmall)) ///
   xtitle("BSRI Masc", size(medsmall)) mcolor(gs6) lcolor(gs8)
	graph export "$out_path/binned_scatter/bin_cgi_bsrimas.jpg", replace

// CGI vs. OSRI Fem   
qui binscatter std_cgi_main std_osri_fem, line(qfit) ///
   ylabel(, nogrid) legend(off) ///		       
   ytitle("CGI", size(medsmall)) ///
   xtitle("OSRI Fem", size(medsmall)) mcolor(gs6) lcolor(gs8)
	graph export "$out_path/binned_scatter/bin_cgi_osrifem.jpg", replace  

// CGI vs. OSRI Masc   
qui binscatter std_cgi_main std_osri_masc, line(qfit) ///
   ylabel(, nogrid) legend(off) ///		       
   ytitle("CGI", size(medsmall)) ///
   xtitle("OSRI Masc", size(medsmall)) mcolor(gs6) lcolor(gs8)
	graph export "$out_path/binned_scatter/bin_cgi_osrimas.jpg", replace 
	
// CGI vs. CFNI
qui binscatter std_cgi_main std_cfni_score, line(qfit) ///
   ylabel(, nogrid) legend(off) ///		       
   ytitle("CGI", size(medsmall)) ///
   xtitle("CFNI", size(medsmall)) mcolor(gs6) lcolor(gs8)
	graph export "$out_path/binned_scatter/bin_cgi_cfni.jpg", replace 

// CGI vs. CMNI
qui binscatter std_cgi_main std_cmni_score, line(qfit) ///
   ylabel(, nogrid) legend(off) ///		       
   ytitle("CGI", size(medsmall)) ///
   xtitle("CMNI", size(medsmall)) mcolor(gs6) lcolor(gs8)
	graph export "$out_path/binned_scatter/bin_cgi_cmni.jpg", replace 

// CGI vs. Two-dimensional scale - Magliozzi (Fem)   
qui binscatter std_cgi_main std_magliozzi_fem, line(qfit) ///
   ylabel(, nogrid) legend(off) ///		       
   ytitle("CGI", size(medsmall)) ///
   xtitle("Magliozzi Fem", size(medsmall)) mcolor(gs6) lcolor(gs8)
	graph export "$out_path/binned_scatter/bin_cgi_magliozzifem.jpg", replace 
   
// CGI vs. Two-dimensional scale - Magliozzi (Masc)   
qui binscatter std_cgi_main std_magliozzi_masc, line(qfit) ///
   ylabel(, nogrid) legend(off) ///		       
   ytitle("CGI", size(medsmall)) ///
   xtitle("Magliozzi Masc", size(medsmall)) mcolor(gs6) lcolor(gs8)
	graph export "$out_path/binned_scatter/bin_cgi_magliozzimas.jpg", replace 

// CGI vs. Markstedt (Fem) 
qui binscatter std_cgi_main std_wangnerud_feminine, line(qfit) ///
   ylabel(, nogrid) legend(off) ///		       
   ytitle("CGI", size(medsmall)) ///
   xtitle("Markstedt Fem", size(medsmall)) mcolor(gs6) lcolor(gs8)
	graph export "$out_path/binned_scatter/bin_cgi_wangnerudfem.jpg", replace 
   
// CGI vs. Markstedt (Masc) 
qui binscatter std_cgi_main std_wangnerud_masculine, line(qfit) ///
   ylabel(, nogrid) legend(off) ///		       
   ytitle("CGI", size(medsmall)) ///
   xtitle("Markstedt Masc", size(medsmall)) mcolor(gs6) lcolor(gs8)
	graph export "$out_path/binned_scatter/bin_cgi_wangnerudmas.jpg", replace 

// CGI vs. TMF
qui binscatter std_cgi_main std_tmf_score, line(qfit) ///
   ylabel(, nogrid) legend(off) ///		       
   ytitle("CGI", size(medsmall)) ///
   xtitle("TMF", size(medsmall)) mcolor(gs6) lcolor(gs8)
	graph export "$out_path/binned_scatter/bin_cgi_tmf.jpg", replace 
   
// CGI vs. First component
qui binscatter std_cgi_main std_first_component, line(qfit) ///
   ylabel(, nogrid) legend(off) ///		       
   ytitle("CGI", size(medsmall)) ///
   xtitle("First component", size(medsmall)) mcolor(gs6) lcolor(gs8)
	graph export "$out_path/binned_scatter/bin_cgi_firstcomp.jpg", replace 

   
