# Replication Package for "Gender Identity and Economic Decision Making"

Anne Ardila Brenøe, Zeynep Eyibak, Lea Heursen, Eva Ranehill, and Roberto A. Weber

*Forthcoming Journal of Human Resources* 

Zenodo: https://doi.org/10.5281/zenodo.24335296
---

## Overview

This package contains the data and code that produce the tables and figures in the paper and its Online Appendix. The code is written in Stata. Two steps use other software: a MATLAB script that estimates the equality–efficiency parameter ρ for the Swiss Uni sample and two Python notebooks that compute the Kolmogorov–Smirnov tests reported in Figures 2 and 4. 

The master file `2_do/000_master.do` lists all Stata programs in the order in which they should be run. The package includes the data for three of the four main samples (Swiss Uni, U.S. Adults, Swiss Teens). The Swedish Youths data are not included: they were collected as part of an ongoing study led by one of the authors (Ranehill) and will be made publicly available once that study is completed

---

### Details on each data source

| Sample | Collected by | Period | Files in this package | Included |
|---|---|---|---|---|
| Swiss Uni | Authors | Sep–Oct 2021 (follow-up survey two weeks later) | `1_data/1_rawdata/swissuni/` | Yes |
| U.S. Adults, Wave 1 | Authors (Prolific) | March 2022 | `1_data/1_rawdata/usadults_w1/` | Yes |
| U.S. Adults, Wave 2 | Authors (Prolific) | March 2023 | `1_data/1_rawdata/usadults_w2/` | Yes |
| Swiss Teens | Authors | Dec 2021 and March 2022 | `1_data/2_prepared/1_swissteens.dta` | Yes |
| Swiss parent–child survey | Authors | Nov 2024–Apr 2025 | `1_data/1_rawdata/parents_swissteens/parents_swissteens.dta` | Yes |
| Swedish Youths | Ongoing study led by Eva Ranehill | — | `1_data/1_rawdata/swedishyouth/read_me.txt` | **No** |
| Female share by industry | U.S. Bureau of Labor Statistics | 2020 | values entered in `2_do/3_aux/industry_female_share.do` | Yes (public) |
| Female share of bachelor's degrees by field | National Center for Education Statistics | 2020 | `1_data/3_aux/` | Yes (public) |

**Swiss Uni.** 

| File | Content |
|---|---|
| `all_apps_wide-211011.csv`, `-211012.csv`, `-211014.csv` | oTree exports for the three session dates |
| `ContinuousGender_MainStudy_211011.csv`, `_211012.csv`, `_211014.csv` | Qualtrics end-of-experiment survey |
| `session211011_payment.csv`, `session211012_payment.csv`, `session211014_payment.csv` | Output of the payment script |
| `ContinuousGender_Keys_otree_follow-up_survey.xlsx` | Key linking oTree participant codes to follow-up survey tokens |
| `ContinuousGender_FollowUpStudy_November+1,+2021_14.50.csv` | Qualtrics follow-up survey |
| `data_notes.txt` | Notes on file contents and main outcome variables |
| `rho/` | Input and output of the ρ estimation |

**U.S. Adults.** 

| File | Content |
|---|---|
| `usadults_w1/Qualtrics_Cont_Gender_Rep_Sample_Choice_Text_220324.xlsx` | Wave 1 survey responses |
| `usadults_w1/Prolific_Cont_Gender_30_to_39_220324.csv`, `_40_to_49_`, `_50_to_59_` | Wave 1 Prolific by age group |
| `usadults_w2/cgi_validation_20-29_qualtrics_230315.xlsx`, `cgi_validation_30-60_qualtrics_230321.xlsx` | Wave 2 survey responses |
| `usadults_w2/cgi_validation_20-29_prolific_230321.xlsx`, `_30-39_`, `_40-49_`, `_50-60_` | Wave 2 Prolific by age group |

**Swiss Teens.** 
Survey data merged with user data from Yousty.ch

**Swiss parent–child survey.** 
Collected as part of Brenøe and Rutnam "Parents' Perceptions of Occupational Fit" (2025). 

**Swedish Youths (not included).**  
Conducted as part of an ongoing study led by one of the authors (Ranehill) (see Online Appendix D.4). The full dataset and instructions will be made publicly available once that primary study is completed. 

**Public auxiliary data.**

- Female share by industry: U.S. Bureau of Labor Statistics, *Women in the Labor Force: A Databook* (2020 edition), Table 14, https://www.bls.gov/opub/reports/womens-databook/2020/home.htm. The 13 industry shares are typed into `2_do/3_aux/industry_female_share.do`.
- Female share of bachelor's degrees by field of study: National Center for Education Statistics, *Digest of Education Statistics 2021*, Tables 322.40 and 322.50, https://nces.ed.gov/programs/digest/2021menu_tables.asp. The downloaded tables are `1_data/3_aux/NCES_322.40.xls` and `NCES_322.50.xls`; the mapping to the survey's study fields is in `1_data/3_aux/major_share (03.11.23).xlsx`, and the resulting shares are typed into `2_do/3_aux/major_female_share.do`.

**Intermediate files.** Produced by the preparation code and the MATLAB and Python steps, and included so that the Stata code runs without MATLAB or Python and Figures 2–4 can be reproduced without the Swedish data. Re-running any step overwrites them.

| Folder | Content |
|---|---|
| `1_data/2_prepared/` | Analysis datasets |
| `1_data/3_aux/` | `industry_female_share.dta`, `major_female_share.dta` |
| `1_data/1_rawdata/swissuni/rho/` | ρ inputs (`2_code_id_CW.dta`, `3_input_matlab.csv`) and estimates (`5_Results.csv`) |
| `1_data/5_meta/` | Saved regression results and KS tests used by Figures 2–4 |


## Computational Requirements

### Software

- **Stata** Stata/MP 18

  ```stata
  ssc install grstyle
  ssc install palettes
  ssc install colrspace
  ssc install binscatter
  ssc install distplot
  ssc install ivreg2
  ssc install ranktest
  ssc install rwolf2
  ```
  The `egen` function `weightave` (Johannes Haushofer, 2013) is included in `4_ado/_gweightave.ado`; the prepare programs add `4_ado` to the ado-path.
  
- **MATLAB 2022** with the Optimization Toolbox (`lsqnonlin`). Needed to re-estimate ρ (MATLAB step below).
- **Python 3** (the notebooks were run with Python 3.9.6) with Jupyter, `pandas`, `scipy`, `numpy`, `matplotlib`, and `seaborn`. 

### Randomness
The Romano–Wolf p-values in `8_MHT.do` use `rwolf2` with `seed(1234)` and 250 bootstrap replications. No other program uses random numbers.

---

## Description of Programs and Folders

```
Brenoe_et_al_Replication/
├── README.md
├── 1_data/
│   ├── 1_rawdata/          raw data (Swiss Uni, U.S. Adults, parent–child survey, Swedish read_me)
│   ├── 2_prepared/         analysis files
│   ├── 3_aux/              public NCES tables used for the female share of study fields
│   ├── 4_temp/             working folder for temporary files written during data preparation
│   └── 5_meta/             saved regression results used by Figures 2–4 (see above)
├── 2_do/
│   ├── 000_master.do       master file
│   ├── 1_prepare/          data preparation
│   ├── 2_analysis/         one subfolder per group of exhibits (see table below)
│   │   └── 0_reg_fnc/      helper programs that format coefficients, standard errors and stars
│   └── 3_aux/              industry and study-field female shares; variable labels
├── 3_out/                  all tables (.tex) and figures (.jpg/.png) are written here
└── 4_ado/                  _gweightave.ado
```

**Data preparation (`2_do/1_prepare/`).**

| Program | Input | Output |
|---|---|---|
| `1_data/1_rawdata/swissuni/rho/1_prepare_rho.do` | Swiss Uni raw files | `1_data/1_rawdata/swissuni/rho/2_code_id_CW.dta`, `3_input_matlab.csv` |
| `1_prepare_swissuni.do` | Swiss Uni raw files, `rho/5_Results.csv` | `1_data/2_prepared/1_SwissUni.dta` |
| `1_prepare_swedishyouth.do` | Swedish Youths data (not included) | `1_data/2_prepared/1_Swedishyouth.dta` |
| `2_do/3_aux/industry_female_share.do`, `major_female_share.do` | values from BLS and NCES | `1_data/3_aux/industry_female_share.dta`, `major_female_share.dta` |
| `1_prepare_usadults_w1.do` | Wave 1 raw files, `1_data/3_aux/industry_female_share.dta` | `1_data/2_prepared/0_usadults_w1_30_60.dta` |
| `1_prepare_usadults_w2.do` | Wave 2 raw files | `1_data/2_prepared/0_usadults_w2_20_60.dta` |
| `2_prepare_usadults_w1_and_w2.do` | the two files above, `1_data/3_aux/major_female_share.dta` | `1_data/2_prepared/1_usadults_w1_30_60.dta`, `1_usadults_w2_20_60.dta`, `1_usadults_w2_30_60.dta`, `1_usadults_w1_w2_20_60.dta`, `1_usadults_w1_w2_30_60.dta` |

The programs in `2_analysis/11_nonbinary/1_prepare data set/` repeat these steps without excluding non-binary participants and save the resulting files in `2_analysis/11_nonbinary/`.

---

## Instructions to Replicators

1. Install the Stata packages listed above.
2. Open `2_do/000_master.do` and set `global path` to the full path of this folder.
3. The Swedish Youths data are not included, so `2_do/000_master.do` cannot be run in full, and the programs that use these data (marked † in the list of tables and figures) stop with an error. Run all other programs individually, in the order listed in `2_do/000_master.do`, after running the `global path` line of `2_do/000_master.do`.
4. The MATLAB script and the two Python notebooks are not run from `2_do/000_master.do` (they appear there as commented lines) and must be run separately, as described below. The notebooks do not use the path set in the master file.

**MATLAB step: re-estimate ρ.** `1_prepare_rho.do` writes `3_input_matlab.csv` to `1_data/1_rawdata/swissuni/rho/`. In MATLAB, run `run('<path>/1_data/1_rawdata/swissuni/rho/4_mlolik_CG.m')`. The script uses `lolik.m` and `nlregf.m` in the same folder and writes `5_Results.csv` there, which `1_prepare_swissuni.do` reads. The estimation implements the maximum-likelihood approach of Fisman, Kariv, and Markovits (2007), adapted to 15 fixed budget sets.

**Python step: re-run the KS tests.** After the table programs have run:

- `2_do/2_analysis/3_Main_Meta/2_KS_1t.ipynb` reads `1_data/5_meta/1_pval/table_*_panelC.dta` and `table_*_panelD.dta` and writes `CGI_pooled_KS.dta`, `CGI_female_KS.dta`, `CGI_male_KS.dta` to the same folder (used by `3_Meta_p.do`, Figure 2).
- `2_do/2_analysis/4_othermeasures_vs_CGI/5_KS_1t .ipynb` reads the files written by `4_p_val.do` in `1_data/5_meta/4_pval_other/` and writes the `*_KS.dta` files there (used by `6_p_CDF.do`, Figure 4).

In each notebook (or just once in the master file), replace `/path/to/replication_folder` in the first cell with the full path of this folder, run all cells, and then re-run `3_Meta_p.do` or `6_p_CDF.do`.

---

## List of Tables and Figures

All programs are in `2_do/2_analysis/`; all outputs are in `3_out/`. Exhibits marked † use the Swedish Youths data and cannot be reproduced until the data becomes available.

### Main text

| Exhibit | Program | Output |
|---|---|---|
| Table 1 | `1_Main_Tables_1tailed/1_table_1.do` | `Tables_Main_Paper/table_1.tex` |
| Table 2 | none (overview of outcome variables, no data) | — |
| Tables 3–6 † | `1_Main_Tables_1tailed/1_table_3.do` … `1_table_6.do` | `Tables_Main_Paper/table_3.tex` … `table_6.tex` |
| Table 7 | `1_Main_Tables_1tailed/1_table_7.do` | `Tables_Main_Paper/table_7.tex` |
| Figure 1 † | `2_Main_Plots/2_CGI_by_sex.do` | `CGI_by_sex/SwissUni.jpg`, `usadults_w1_w2_20_60.jpg`, `swissteens.jpg`, `Swedishyouth.jpg` |
| Figure 2 | `3_Main_Meta/3_Meta_p.do` (KS tests: `2_KS_1t.ipynb`) | `meta_p_1t.jpg`, `Meta/meta_p_bysex_1t.jpg` |
| Figure 3 | `3_Main_Meta/3_Meta_R2.do` | `Meta/meta_R2_increaseinR2.jpg` |
| Figure 4 | `4_othermeasures_vs_CGI/4_p_val.do`, then `5_KS_1t .ipynb`, then `6_p_CDF.do` | `Appendix1/meta_p_*_1t.jpg` |

Figures 2 and 3 read the saved results in `1_data/5_meta/`, which are written by the programs for Tables 3–7.

### Appendix A

| Exhibit | Program | Output |
|---|---|---|
| Table A1 | none (overview of outcome variables, no data) | — |
| Figures A1–A2 | `4_othermeasures_vs_CGI/10_PanelB_R2_AcrossMeasures.do`, then `Rsquared across measures.do` | `Appendix1/R-squared_1item.jpg`, `R-squared_multi_item.jpg` |

### Online Appendix

| Exhibit | Program | Output |
|---|---|---|
| Figure B1 | `2_Main_Plots/2_scatter plots.do` | `binned_scatter/bin_cgi_*.jpg` |
| Figure B2 | `7_ORIV/7_oriv.do` | `oriv/binscatter_SwissUni.jpg` |
| Figure B3 | `15_corr_parents_perception/15_parent_child.do` | `parent-child/parent_child_validation_binscatter.png`, `parent_child_validation_difference_hist.png` |
| Figure B4 † | `11_nonbinary/2_CGI_dist/CGI_dist.do` | `CGI_by_sex/CGI_dist_nonb.jpg` |
| Figure B5 | `2_Main_Plots/2_CGI_by_age_US adults.do` | `CGI_by_sex/US_20s.jpg`, `US_30s.jpg`, `US_40s.jpg`, `US_50s.jpg` |
| Tables B1–B4 | `17_pca/pca_factor_loadings.do` | `pca/BSRI_pca.tex`, `CFNI_pca.tex`, `CMNI_pca.tex`, `OSRI_pca.tex` |
| Table B5 | none (sample selection; counts are documented in the prepare programs) | — |
| Table B6 | `8_MHT/8_MHT.do` | `MHT/US_Wave1_Diff_1.tex` |
| Tables B7–B10 † | `1_Main_Tables_1tailed/1_table_3.do` … `1_table_6.do` (with controls) | `Tables_Controls/table_3.tex` … `table_6.tex` |
| Table B11 | `1_Main_Tables_1tailed/1_table_7.do` (with controls) | `Tables_Controls/table_7.tex` |
| Table B12 | `11_nonbinary/3_robustness_reg/US_tables_3_4_5.do` | `NonBinary/US_tables_3_4_5_nb_b.tex` |
| Table B13 | `11_nonbinary/3_robustness_reg/US_tables_6_7.do` | `NonBinary/US_tables_6_7_nb_b.tex` |
| Table B14 | `11_nonbinary/3_robustness_reg/SwissUni_tables_3.do` | `NonBinary/table_3_Swiss_nb_b.tex` |
| Table B15 | `11_nonbinary/3_robustness_reg/SwissUni_tables_4_5.do` | `NonBinary/table_4_5_Swiss_nb_b.tex` |
| Tables B16–B19 † | `13_interaction term/1_table_3.do` … `1_table_6.do` | `Tables_Main_Interaction/table_3.tex` … `table_6.tex` |
| Table B20 | `13_interaction term/1_table_7.do` | `Tables_Main_Interaction/table_7.tex` |
| Tables B21–B25 | `16_nonhetero/1_table_3_inc_excl_nonhetero.do` … `1_table_7_inc_excl_nonhetero.do` | `Tables_nonhetero/table_3.tex`, `table_4.tex`, `table_5.tex`, `table_6b.tex`, `table_7b.tex` |
| Tables B26–B29 † | `5_TableswithDummies/5_table_3.do` … `5_table_6.do` | `Tables_CGI_Dummies/table_3.tex` … `table_6.tex` |
| Table B30 | `5_TableswithDummies/5_table_7.do` | `Tables_CGI_Dummies/table_7.tex` |
| Table B31 | `7_ORIV/7_oriv.do` | `oriv/ivreg_SwissUni.tex` |
| Tables B32–B33 | `6_USwave1wave2/tables_3_4_5.do`, `tables_6_7.do` | `USwave1wave2/tables_3_4_5_bywaves.tex`, `tables_6_7_bywaves.tex` |
| Tables B34–B39 | `18_byage/table_3_byage.do`, `table_4_byage.do`, `table_5_byage.do`, `table_6_byage.do`, `table_7a_byage.do`, `table_7b_byage.do` | `US_age_tables/table_*_byage.tex` |
| Tables B40–B50 | `4_othermeasures_vs_CGI/7_other_GI_reg_1t.do` | `othermeasures_vs_CGI/reg_<outcome>.tex` |

## References

Fisman, Raymond, Shachar Kariv, and Daniel Markovits. 2007. "Individual Preferences for Giving." *American Economic Review* 97(5): 1858–1876.

National Center for Education Statistics. 2021. *Digest of Education Statistics 2021*, Tables 322.40 and 322.50. https://nces.ed.gov/programs/digest/2021menu_tables.asp

U.S. Bureau of Labor Statistics. *Women in the Labor Force: A Databook*, 2020 edition, Table 14. https://www.bls.gov/opub/reports/womens-databook/2020/home.htm

---

