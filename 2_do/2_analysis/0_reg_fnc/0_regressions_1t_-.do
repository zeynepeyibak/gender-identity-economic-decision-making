***********************************************************************************
******************************* Analysis ******************************************
***********************************************************************************

*** Set Working directory and import dataset

clear matrix
set more off 


********************************************************************************
**********Regressions
*****************************************************************************

cap program drop beta_coeff1_neg
			program define beta_coeff1_neg, rclass

			 	local beta: di %6.3f _b[`1']
				local se: di %6.3f _se[`1']
				
				* Compute the one tailed test p value to be used if the coeff estimate of female is in the negative direction i.e. `sign_female'<0
				qui test _b[`1']=0 
				local sign_cgi = sign(_b[`1'])
				local p_value_o = 1-ttail(r(df_r),`sign_cgi'*sqrt(r(F))) // Ho: coef >= 0

		
				if `p_value_o' > .01 & `p_value_o' <= .05 {
					local beta = "`beta'\rlap{*}"
				}
				else if `p_value_o' > .005 & `p_value_o' <= .01 {
					local beta = "`beta'\rlap{**}"
				}
				else if `p_value_o' <= .005 {
					local beta = "`beta'\rlap{***}"
				}
				else {
					local beta = "`beta'"	
				}

				local beta = subinstr("`beta'","-","\llap{-}", .)
                
				* Define rounded p value to 3 decimals
				local p_value_r = round(`p_value_o', 0.001)
				* Force rounded p value to always show in the format X.XXX
                local p_value = string(`p_value_r', "%6.3f")

				return local se = trim("$`se'$")	
				return local beta = "`beta'"
				return local p_value = "`p_value'"
				end
																
