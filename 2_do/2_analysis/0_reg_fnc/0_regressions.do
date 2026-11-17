***********************************************************************************
******************************* Analysis ******************************************
***********************************************************************************

*** Set Working directory and import dataset

clear all
clear matrix
set more off 
***

********************************************************************************
**********Regressions
*****************************************************************************

cap program drop beta_coeff2
			program define beta_coeff2, rclass

			 	local beta: di %6.3f _b[`1']
				local se: di %6.3f _se[`1']
				
			    // Define original p value without any rounding
			    local p_value_o = 2 * (1 - normal(abs(_b[`1'] / _se[`1'])))
		
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
         
				// Define rounded p value to 3 decimals
				local p_value_r = round(2 * (1 - normal(abs(_b[`1'] / _se[`1']))), 0.001)
				// Force rounded p value to always show in the format X.XXX
                local p_value = string(`p_value_r', "%6.3f")

				return local se = trim("$`se'$")	
				return local beta = "`beta'"
				return local p_value = "`p_value'"
				end
																
