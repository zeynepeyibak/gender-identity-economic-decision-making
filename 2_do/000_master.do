*-----------------------------------------------------------------------------
* Master do
*-----------------------------------------------------------------------------
global path "/path/to/replication_folder"   // replicator edits this line
global path_master "$path/2_do"

* Prepare
qui do "$path_master/../1_data/1_rawdata/swissuni/rho/1_prepare_rho.do"
//run in MATLAB, not Stata: "$path_master/../1_data/1_rawdata/swissuni/rho/4_mlolik_CG.m"
qui do "$path_master/1_prepare/1_prepare_swissuni.do"
qui do "$path_master/1_prepare/1_prepare_swedishyouth.do"
qui do "$path_master/3_aux/industry_female_share.do"
qui do "$path_master/3_aux/major_female_share.do"
qui do "$path_master/1_prepare/1_prepare_usadults_w1.do"
qui do "$path_master/1_prepare/1_prepare_usadults_w2.do"
qui do "$path_master/1_prepare/2_prepare_usadults_w1_and_w2.do"

* Analysis
* Main Tables
qui do "$path_master/2_analysis/1_Main_Tables_1tailed/1_table_1.do"
qui do "$path_master/2_analysis/1_Main_Tables_1tailed/1_table_3.do"
qui do "$path_master/2_analysis/1_Main_Tables_1tailed/1_table_4.do"
qui do "$path_master/2_analysis/1_Main_Tables_1tailed/1_table_5.do"
qui do "$path_master/2_analysis/1_Main_Tables_1tailed/1_table_6.do"
qui do "$path_master/2_analysis/1_Main_Tables_1tailed/1_table_7.do"

* Figure 1
qui do "$path_master/2_analysis/2_Main_Plots/2_CGI_by_sex.do"

* Figure 2
//Run on Python, not Stata qui do "$path_master/2_analysis/3_Main_Meta/2_KS_1t.ipynb"
qui do "$path_master/2_analysis/3_Main_Meta/3_Meta_p.do"

* Figure 3
qui do "$path_master/2_analysis/3_Main_Meta/3_Meta_R2.do"

* Figure 4
qui do "$path_master/2_analysis/4_othermeasures_vs_CGI/4_p_val.do"
//Run on Python, not Stata  qui do "$path_master/2_analysis/4_othermeasures_vs_CGI/5_KS_1t.ipynb"
qui do "$path_master/2_analysis/4_othermeasures_vs_CGI/6_p_CDF.do"
qui do "$path_master/2_analysis/4_othermeasures_vs_CGI/7_other_GI_reg_1t.do"
qui do "$path_master/2_analysis/4_othermeasures_vs_CGI/10_PanelB_R2_AcrossMeasures.do"

* Appendix A
* Fugure A1 & A2
qui do "$path_master/2_analysis/Rsquared across measures.do"

* Appendix B
* Scatter plot
qui do "$path_master/2_analysis/2_Main_Plots/2_scatter plots.do" 
* Oriv
qui do "$path_master/2_analysis/7_ORIV/7_oriv.do"

* Tables with Dummmies
qui do "$path_master/2_analysis/5_TableswithDummies/5_table_3.do"
qui do "$path_master/2_analysis/5_TableswithDummies/5_table_4.do"
qui do "$path_master/2_analysis/5_TableswithDummies/5_table_5.do"
qui do "$path_master/2_analysis/5_TableswithDummies/5_table_6.do"
qui do "$path_master/2_analysis/5_TableswithDummies/5_table_7.do"

* U.S. Adults by Wave
qui do "$path_master/2_analysis/6_USwave1wave2/tables_3_4_5.do"
qui do "$path_master/2_analysis/6_USwave1wave2/tables_6_7.do"

* Oriv
qui do "$path_master/2_analysis/7_oriv/7_oriv.do"

* Parent Child
qui do "$path_master/2_analysis/15_corr_parents_perception/15_parent_child.do"

* Non-binary
qui do "$path_master/2_analysis/11_nonbinary/1_prepare data set/1_prepare_swedishyouth_nonbinaryupd.do"
qui do "$path_master/2_analysis/11_nonbinary/1_prepare data set/1_prepare_swissuni_nonbinaryupd"
qui do "$path_master/2_analysis/11_nonbinary/1_prepare data set/1_prepare_usadults_w1_nonbinaryupd.do"
qui do "$path_master/2_analysis/11_nonbinary/1_prepare data set/1_prepare_usadults_w2_nonbinaryupd.do"
qui do "$path_master/2_analysis/11_nonbinary/1_prepare data set/2_prepare_usadults_w1_and_w2_nonbinaryupd.do"

qui do "$path_master/2_analysis/11_nonbinary/2_CGI_dist/CGI_dist.do"

qui do "$path_master/2_analysis/11_nonbinary/3_robustness_reg/SwissUni_tables_3"
qui do "$path_master/2_analysis/11_nonbinary/3_robustness_reg/SwissUni_tables_4_5"
qui do "$path_master/2_analysis/11_nonbinary/3_robustness_reg/US_tables_3_4_5.do"
qui do "$path_master/2_analysis/11_nonbinary/3_robustness_reg/US_tables_6_7.do"

* CGI by age - U.S Adults
qui do "$path_master/2_analysis/2_Main_Plots/2_CGI_by_age_US adults.do" 

* PCA
qui do "$path_master/2_analysis/17_pca/pca_factor_loadings.do" 

* MHT
qui do "$path_master/2_analysis/8_MHT/8_MHT.do"

* Non-binary
qui do "$path_master/2_analysis/11_nonbinary/1_prepare data set/1_prepare_swedishyouth_nonbinaryupd.do"
qui do "$path_master/2_analysis/11_nonbinary/1_prepare data set/1_prepare_swissuni_nonbinaryupd"
qui do "$path_master/2_analysis/11_nonbinary/1_prepare data set/1_prepare_usadults_w1_nonbinaryupd.do"
qui do "$path_master/2_analysis/11_nonbinary/1_prepare data set/1_prepare_usadults_w2_nonbinaryupd.do"
qui do "$path_master/2_analysis/11_nonbinary/1_prepare data set/2_prepare_usadults_w1_and_w2_nonbinaryupd.do"

qui do "$path_master/2_analysis/11_nonbinary/2_CGI_dist/CGI_dist.do"

qui do "$path_master/2_analysis/11_nonbinary/3_robustness_reg/SwissUni_tables_3"
qui do "$path_master/2_analysis/11_nonbinary/3_robustness_reg/SwissUni_tables_4_5"
qui do "$path_master/2_analysis/11_nonbinary/3_robustness_reg/US_tables_3_4_5.do"
qui do "$path_master/2_analysis/11_nonbinary/3_robustness_reg/US_tables_6_7.do"

* Interaction Term
qui do "$path_master/2_analysis/13_interaction term/1_table_3.do"
qui do "$path_master/2_analysis/13_interaction term/1_table_4.do"
qui do "$path_master/2_analysis/13_interaction term/1_table_5.do"
qui do "$path_master/2_analysis/13_interaction term/1_table_6.do"
qui do "$path_master/2_analysis/13_interaction term/1_table_7.do"

* Sexual Orientation
qui do "$path_master/2_analysis/16_nonhetero/1_table_3_inc_excl_nonhetero.do"
qui do "$path_master/2_analysis/16_nonhetero/1_table_4_inc_excl_nonhetero.do"
qui do "$path_master/2_analysis/16_nonhetero/1_table_5_inc_excl_nonhetero.do"
qui do "$path_master/2_analysis/16_nonhetero/1_table_6_inc_excl_nonhetero.do"
qui do "$path_master/2_analysis/16_nonhetero/1_table_7_inc_excl_nonhetero.do"

* U.S. Adults by Age Group (Tables B34–B39)
qui do "$path_master/2_analysis/18_byage/table_3_byage.do"
qui do "$path_master/2_analysis/18_byage/table_4_byage.do"
qui do "$path_master/2_analysis/18_byage/table_5_byage.do"
qui do "$path_master/2_analysis/18_byage/table_6_byage.do"
qui do "$path_master/2_analysis/18_byage/table_7a_byage.do"
qui do "$path_master/2_analysis/18_byage/table_7b_byage.do"





