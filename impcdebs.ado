*!TITLE: IMPCDE - a module for estimating controlled direct effects using regression imputation
*!AUTHOR: Geoffrey T. Wodtke, Department of Sociology, University of Chicago
*!
*! version 0.1
*!

program define impcdebs, rclass
	
	version 15	

	syntax varlist(min=1 max=1 numeric) [if][in] [pweight], ///
		dvar(varname numeric) ///
		mvar(varname numeric) ///
		d(real) ///
		dstar(real) ///
		m(real) ///
		yreg(string) ///
		[cvars(varlist numeric)] ///		
		[NOINTERaction] ///
		[cxd] ///
		[cxm] 

	qui {
		marksample touse
		count if `touse'
		if r(N) == 0 error 2000
		local N = r(N)
	}
	
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


	tempvar `dvar'_orig_r001
	gen ``dvar'_orig_r001' = `dvar' if `touse'

	tempvar `mvar'_orig_r001
	gen ``mvar'_orig_r001' = `mvar' if `touse'
	
	qui `yreg' `yvar' `dvar' `mvar' `cvars' `inter' `cxd_vars' `cxm_vars' [`weight' `exp'] if `touse'
		
	qui replace `mvar'=`m'
	qui replace `dvar'=`d'
	
	if ("`cxd'"!="") {	
		foreach c in `cvars' {
			qui replace ``dvar'X`c'' = `dvar' * `c' if `touse'
			}
		}	

	if ("`cxm'"!="") {	
		foreach c in `cvars' {
			qui replace ``mvar'X`c'' = `mvar' * `c' if `touse'
			}
		}

	tempvar Ydm
	qui predict `Ydm'
		
	qui replace `dvar'=`dstar'
	
	if ("`cxd'"!="") {	
		foreach c in `cvars' {
			qui replace ``dvar'X`c'' = `dvar' * `c' if `touse'
			}
		}		

	tempvar Ydstarm
	qui predict `Ydstarm'

	tempvar CDEgivenC
	gen `CDEgivenC' = `Ydm' - `Ydstarm'
		
	qui reg `CDEgivenC' [`weight' `exp'] if `touse'
		
	return scalar cde = _b[_cons]

	qui replace `dvar' = ``dvar'_orig_r001'
	qui replace `mvar' = ``mvar'_orig_r001'
	
end impcdebs
