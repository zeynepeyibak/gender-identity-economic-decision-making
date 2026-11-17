*-----------------------------------------------------------------------------
* Female share in industry from the folllowing source: 
* we could try to scrape data from https://www.bls.gov/opub/reports/womens-databook/2020/home.htm, Table 14
*-----------------------------------------------------------------------------

/*1. Agriculture, Forestry and Fishing 
2. Construction 
3. Education and Health Services 
4. Financial Activities 
5. Information       
6. Leisure and Hospitality       
7. Manufacturing 
8. Mining and Quarrying, and Oil and Ga      
9. Other Services    
10. Professional and Business Services      
11. Public Administration        
12. Transportation and Utilities       
13. Wholesale and Retail Trade 
*/	

clear all 

	
set obs 13
egen industry = fill(1/10)

gen industry_share = .
replace industry_share = 0.262 if industry==1
replace industry_share = 0.103 if industry==2
replace industry_share = 0.748 if industry==3
replace industry_share = 0.526 if industry==4
replace industry_share = 0.405 if industry==5
replace industry_share = 0.512 if industry==6
replace industry_share = 0.294 if industry==7
replace industry_share = 0.158 if industry==8
replace industry_share = 0.539 if industry==9
replace industry_share = 0.413 if industry==10
replace industry_share = 0.457 if industry==11
replace industry_share = 0.241 if industry==12
replace industry_share = 0.442 if industry==13
	
la var industry_share "Female Share in the Industry"

save "$path/1_data/3_aux/industry_female_share.dta", replace
