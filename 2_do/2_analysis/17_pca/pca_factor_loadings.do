clear all

global out_path "$path/3_out" 
		
*-----------------------------------------------------------------------------
* 1. Create output directories
*-----------------------------------------------------------------------------
cap mkdir "$out_path/pca"

*-----------------------------------------------------------------------------
* 2. Load data
*-----------------------------------------------------------------------------
use "$path/1_data/2_prepared/1_usadults_w2_20_60.dta", clear

*-----------------------------------------------------------------------------
* 3. Identify instrument subsamples
*    Each respondent was randomly assigned exactly one instrument (BSRI/OSRI/
*    CMNI/CFNI). We identify assignment by non-missing values on the
*    instrument-specific standardized scores.
*-----------------------------------------------------------------------------
gen byte sample_bsri = (!missing(std_bsri_fem)  & !missing(std_bsri_masc))
gen byte sample_osri = (!missing(std_osri_fem)  & !missing(std_osri_masc))
gen byte sample_cmni = (!missing(std_cmni_score))
gen byte sample_cfni = (!missing(std_cfni_score))

* Sanity check: subsamples should be mutually exclusive and exhaustive
assert sample_bsri + sample_osri + sample_cmni + sample_cfni == 1

tab sample_bsri sample_osri
tab sample_cmni sample_cfni

di "BSRI N = " _N " * " %5.4f (sample_bsri[1]) // quick preview
count if sample_bsri == 1
count if sample_osri == 1
count if sample_cmni == 1
count if sample_cfni == 1

*-----------------------------------------------------------------------------
* 4. Helper program: run PCA on a subsample and write a .tex table
*
*    Syntax:
*      write_pca_table varlist , instrument(str) sample(varname)
*                               out1(path) out2(path)
*
*    Arguments:
*      varlist      : list of standardized vars to include in PCA
*                     TMF must be first (used for sign normalization)
*      instrument() : label string: BSRI | OSRI | CMNI | CFNI
*      sample()     : binary variable identifying the subsample
*      out1()       : first output folder path
*      out2()       : second output folder path
*-----------------------------------------------------------------------------
capture program drop write_pca_table
program define write_pca_table
    syntax varlist, instrument(string) sample(varname) out1(string) out2(string)

    *-------------------------------------------------------------------------
    * 4a. Run PCA on the relevant subsample
    *-------------------------------------------------------------------------
    pca `varlist' if `sample' == 1

    *-------------------------------------------------------------------------
    * 4b. Extract results from e()
    *-------------------------------------------------------------------------
    * Loading matrix: rows = variables, columns = components
    matrix L   = e(L)
    matrix EV  = e(Ev)         // eigenvalues (one per component)
    local  N   = e(N)
    local  nv  = rowsof(L)     // number of variables in this PCA

    * Eigenvalue and variance explained for PC1
    local eigenval = EV[1,1]
    local totvar   = 0
    forvalues c = 1/`=colsof(EV)' {
        local totvar = `totvar' + EV[1,`c']
    }
    local pctvar = (`eigenval' / `totvar') * 100

    *-------------------------------------------------------------------------
    * 4c. Sign normalization
    *     Flip entire PC1 column if TMF loading (row 1) is negative
    *     so that higher PC1 = more feminine throughout
    *-------------------------------------------------------------------------
    if L[1,1] < 0 {
        forvalues r = 1/`nv' {
            matrix L[`r',1] = -1 * L[`r',1]
        }
    }

    *-------------------------------------------------------------------------
    * 4d. Define display names in the same order as varlist
    *     Shared variables are always rows 1-5; instrument rows follow
    *-------------------------------------------------------------------------
    local dn1  "TMF score"
    local dn2  "Magliozzi (fem)"
    local dn3  "Magliozzi (masc)"
    local dn4  "Wangnerud (fem)"
    local dn5  "Wangnerud (masc)"

    if "`instrument'" == "BSRI" {
        local dn6  "\textbf{BSRI (fem)}"
        local dn7  "\textbf{BSRI (masc)}"
    }
    else if "`instrument'" == "OSRI" {
        local dn6  "\textbf{OSRI (fem)}"
        local dn7  "\textbf{OSRI (masc)}"
    }
    else if "`instrument'" == "CMNI" {
        local dn6  "\textbf{CMNI score}"
    }
    else if "`instrument'" == "CFNI" {
        local dn6  "\textbf{CFNI score}"
    }

    *-------------------------------------------------------------------------
    * 4e. Write .tex file to both output locations
    *-------------------------------------------------------------------------
    foreach loc in `"`out1'"' `"`out2'"' {

        local filepath `"`loc'/`instrument'_pca.tex"'
        file open fh using `"`filepath'"', write replace

        * --- Table header ---
        file write fh "\begin{table}[htbp]"                                              _n
        file write fh "\centering"                                                        _n
        file write fh "\begin{threeparttable}"                                            _n
        file write fh "\caption{PCA first component --- `instrument' subsample}"         _n
        file write fh "\label{tab:pca_`=lower("`instrument'")'}"                         _n
        file write fh "\begin{tabular}{lc}"                                               _n
        file write fh "\toprule"                                                          _n
        file write fh "Variable & PC1 loading \\"                                        _n
        file write fh "\midrule"                                                          _n

        * --- Shared variables block ---
        file write fh "\multicolumn{2}{l}{\textit{Shared variables}} \\"                 _n
        forvalues i = 1/5 {
            local loading = string(L[`i',1], "%6.3f")
            file write fh "`dn`i'' & `loading' \\"                                       _n
        }

        * --- Instrument-specific variables block (acronym bolded, no section header) ---
        file write fh "\addlinespace"                                                     _n
        forvalues i = 6/`nv' {
            local loading = string(L[`i',1], "%6.3f")
            file write fh "`dn`i'' & `loading' \\"                                       _n
        }

        * --- Bottom stats ---
        file write fh "\midrule"                                                          _n
        file write fh "Variance explained (\%) & `=string(`pctvar', "%5.1f")' \\"        _n
        file write fh "\(N\) & `=string(`N', "%6.0f")' \\"                               _n
        file write fh "\bottomrule"                                                       _n
        file write fh "\end{tabular}"                                                     _n

        * --- Table notes ---
        file write fh "\begin{tablenotes}"                                                _n
        file write fh "\small"                                                            _n
        file write fh "\item \textit{Notes:} Loadings on the first principal component."  _n
        file write fh " Signs normalized so that the TMF loading is positive"             _n
        file write fh " (higher = more feminine)."                                         _n
        file write fh " The table uses the subsample randomly assigned to the `instrument'." _n

        file write fh "\end{tablenotes}"                                                  _n
        file write fh "\end{threeparttable}"                                              _n
        file write fh "\end{table}"                                                       _n

        file close fh

        di as result "--> Saved: `filepath'"
    }

end

*-----------------------------------------------------------------------------
* 5. Run the program for each instrument
*-----------------------------------------------------------------------------

* BSRI subsample
write_pca_table                                                             ///
    std_tmf_score                                                           ///
    std_magliozzi_fem std_magliozzi_masc                                    ///
    std_wangnerud_feminine std_wangnerud_masculine                          ///
    std_bsri_fem std_bsri_masc                                              ///
    , instrument(BSRI)                                                      ///
      sample(sample_bsri)                                                   ///
      out1("$out_path/pca")                                                 ///

* OSRI subsample
write_pca_table                                                             ///
    std_tmf_score                                                           ///
    std_magliozzi_fem std_magliozzi_masc                                    ///
    std_wangnerud_feminine std_wangnerud_masculine                          ///
    std_osri_fem std_osri_masc                                              ///
    , instrument(OSRI)                                                      ///
      sample(sample_osri)                                                   ///
      out1("$out_path/pca")                                                 ///

* CMNI subsample
write_pca_table                                                             ///
    std_tmf_score                                                           ///
    std_magliozzi_fem std_magliozzi_masc                                    ///
    std_wangnerud_feminine std_wangnerud_masculine                          ///
    std_cmni_score                                                          ///
    , instrument(CMNI)                                                      ///
      sample(sample_cmni)                                                   ///
      out1("$out_path/pca")                                                 ///

* CFNI subsample
write_pca_table                                                             ///
    std_tmf_score                                                           ///
    std_magliozzi_fem std_magliozzi_masc                                    ///
    std_wangnerud_feminine std_wangnerud_masculine                          ///
    std_cfni_score                                                          ///
    , instrument(CFNI)                                                      ///
      sample(sample_cfni)                                                   ///
      out1("$out_path/pca")                                                 ///

*-----------------------------------------------------------------------------
* 6. Done
*-----------------------------------------------------------------------------
di as result "============================================================"
di as result "All four PCA tables written successfully."
di as result "Dropbox:  $out_path/pca"
di as result "============================================================"
