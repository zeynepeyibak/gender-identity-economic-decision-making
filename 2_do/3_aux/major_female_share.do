*-----------------------------------------------------------------------------
* Female Share in education major
* Source: https://nces.ed.gov/programs/digest/2021menu_tables.asp, Tables 322.40 and 322.50 (shares for year 2020) 
*-----------------------------------------------------------------------------


clear all 
set obs 12
egen study_field = fill(1/12)


gen major_share = .

*gen agriculture = (study_field==1)
*Agriculture, Forestry, Fisheries and Veterinary //0.573 (Agriculture and Natural Ressources)
replace major_share = 0.573 if study_field==1

*gen arts = (study_field==2)
*Arts and Humanities //0.613 ("Liberal arts and sciences, general studies, and humanities ")
replace major_share = 0.613 if study_field==2

*gen biological = (study_field==3)
*Biological and Related Science / Environmental Science //0.645 (Biological and biomedical sciences)
replace major_share = 0.645 if study_field==3

*gen business = (study_field==4)
*Business, Administration and Law  //0.497 weighted average    
replace major_share = 0.497 if study_field==4

*gen education = (study_field==5)
*Education //0.821 
replace major_share = 0.821 if study_field==5

*gen engineering = (study_field==6)
*Engineering, Manufacturing and Construction //0.225     
replace major_share = 0.225 if study_field==6

*gen health = (study_field==7)
*Health and Welfare //0.785 (Health professions and related programs)
replace major_share = 0.785 if study_field==7

*gen information = (study_field==8)
*Information and Communication Technologies //0.244 weighted average 
replace major_share = 0.244 if study_field==8

*gen other_field = (study_field==9)
* no replace major_share for this 

*gen physics = (study_field==10)
*Physical Sciences / Mathematics and Statistics //0.426 weighted average 
replace major_share = 0.426 if study_field==10

*gen social = (study_field==11)	
*Social Sciences, Journalism, and Information  //0.651 weighted average
replace major_share = 0.651 if study_field==11

*services //0.461 weighted average
replace major_share = 0.461 if study_field==12

la var major_share "Female Share in the major studied"

save "$path/1_data/3_aux/major_female_share.dta", replace

