* Descriptives
count // 1,063
tab Female
drop if Female==. //10 obs deleted
count //1,053
keep if Female==0 | Female==1 //12 obs deleted 
count // 1,041

** Rename and standardize variables
	* CGI
	rename CGI cgi_main
	qui su cgi_main
	gen std_cgi_main=(cgi_main-r(mean))/r(sd)
	la var cgi_main "CGI (self, 0 Masculine, 10 Feminine)" 
	la var std_cgi_main "Std. CGI (self)" 

	* female
	rename Female female
	la var female female

	* Incentivized Efficiency/Equality
	gen rho = p_rho_dict/10 

	* Hyp_Altruism (old name playerpref_1) = willingness to give to charity, i.e donation 
	* Question: How willing are you to give to charity without expecting something in return?  (Answer scale 0-10 with higher numbers indicating higher willingness)
	rename Hyp_Altruism donation 
	qui su donation
	gen std_donation=(donation-r(mean))/r(sd)
	label variable std_donation "Std. Donation"

	* Hyp_Risk (old name playerpref_3) = willingness to take risks, i.e hypothetical risk
	* Dohmen measure on hyp risk. General willingness to take risks. (Answer scale 0-10 with higher numbers indicating higher willingness)
	rename Hyp_Risk hypothetical_risk
	qui su hypothetical_risk
	gen std_hyp_risk=(hypothetical_risk-r(mean))/r(sd)
	label variable std_hyp_risk "Std. Hypothetical Risk"

	* Hyp_Competition (old name playerpref_4) = Willingness to compete, i.e competitiveness
	* General willingness to compete. (Answer scale 0-10 with higher numbers indicating higher willingness)
	rename Hyp_Competition competitiveness
	qui su competitiveness
	gen std_competitiveness=(competitiveness-r(mean))/r(sd)
	label variable std_competitiveness "Std. Competitiveness"
	
	* Playerwill_study
	label variable playerwill_study "Whether respondent plans to study at university. (Dummy with 1 = yes)
	
	* Playerstudyfield_”field”
	label variable playerstudyfield_humanities "interest in studying humanities from 0-10 (0= no interest)"
	label variable playerstudyfield_education "interest in studying education from 0-10 (0= no interest)"
	label variable playerstudyfield_socialsciences "interest in studying social sciences from 0-10 (0= no interest)"
	label variable playerstudyfield_economics "interest in studying economics from 0-10 (0= no interest)"
	label variable playerstudyfield_medicine "interest in studying medicine from 0-10 (0= no interest)"
	label variable playerstudyfield_care "interest in studying care from 0-10 (0= no interest)"
	label variable playerstudyfield_naturalsciences "interest in studying natural sciences from 0-10 (0= no interest)"
	rename playerstudyfield_engeneering playerstudyfield_engineering
	label variable playerstudyfield_engineering "interest in studying engineering from 0-10 (0= no interest)"
	label variable playerstudyfield_choice "Participants chosen field if could choose only one field. "

** Save
drop _merge
save "$path/1_data/2_prepared/1_Swedishyouth.dta", replace

