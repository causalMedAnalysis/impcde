*!TITLE: IMPCDE - a module for estimating controlled direct effects using regression imputation
*!AUTHOR: Geoffrey T. Wodtke, Department of Sociology, University of Chicago
*!
*! version 0.1
*!

program define impcde, eclass

	version 15	

	syntax varname(numeric) [if][in] [pweight], ///
		dvar(varname numeric) ///
		mvar(varname numeric) ///
		d(real) ///
		dstar(real) ///
		m(real) ///
		yreg(string) ///
		[cvars(varlist numeric)] ///		
		[NOINTERaction] ///
		[cxd] ///
		[cxm] ///
		[reps(integer 200)] ///
		[strata(varname numeric)] ///
		[cluster(varname numeric)] ///
		[level(cilevel)] ///
		[seed(passthru)] ///
		[saving(string)] ///
		[detail]

	qui {
		marksample touse
		count if `touse'
		if r(N) == 0 error 2000
	}

	if ("`saving'" != "") {
		bootstrap CDE=r(cde), force ///
			reps(`reps') strata(`strata') cluster(`cluster') level(`level') `seed' ///
			saving(`saving', replace) noheader notable: ///
			impcdebs `varlist' if `touse' [`weight' `exp'], ///
			dvar(`dvar') mvar(`mvar') cvars(`cvars') ///
			d(`d') dstar(`dstar') m(`m') yreg(`yreg') `nointeraction' `cxd' `cxm'
			}

	if ("`saving'" == "") {
		bootstrap CDE=r(cde), force ///
			reps(`reps') strata(`strata') cluster(`cluster') level(`level') `seed' ///
			noheader notable: ///
			impcdebs `varlist' if `touse' [`weight' `exp'], ///
			dvar(`dvar') mvar(`mvar') cvars(`cvars') ///
			d(`d') dstar(`dstar') m(`m') yreg(`yreg') `nointeraction' `cxd' `cxm'
			}
			
	estat bootstrap, p noheader
	
	if ("`detail'" != "") {		
	
		local yvar `varlist'
	
		if ("`nointeraction'" == "") {
			tempvar inter
			gen `inter' = `dvar' * `mvar' if `touse'
			}

		if ("`cxd'"!="") {	
			foreach c in `cvars' {
				tempvar `dvar'X`c'
				gen ``dvar'X`c'' = `dvar' * `c' if `touse'
				local cxd_vars `cxd_vars'  ``dvar'X`c''
				}
			}

		if ("`cxm'"!="") {	
			foreach c in `cvars' {
				tempvar `mvar'X`c'
				gen ``mvar'X`c'' = `mvar' * `c' if `touse'
				local cxm_vars `cxm_vars'  ``mvar'X`c''
				}
			}
	
		`yreg' `yvar' `dvar' `mvar' `inter' `cvars' `cxd_vars' `cxm_vars' [`weight' `exp'] if `touse'
	
		}

end impcde
