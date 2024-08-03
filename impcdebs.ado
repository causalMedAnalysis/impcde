*!TITLE: IMPCDE - a module for estimating controlled direct effects using regression imputation
*!AUTHOR: Geoffrey T. Wodtke, Department of Sociology, University of Chicago
*!
*! version 0.1
*!

program define impcdebs, rclass
	
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
		[cxm] 

	qui {
		marksample touse
		count if `touse'
		if r(N) == 0 error 2000
		local N = r(N)
	}
	
	local yvar `varlist'
	local cvar `cvars'
	local lvar `lvars'
	
	local yregtypes regress logit poisson 
	local nyreg : list posof "`yreg'" in yregtypes
	if !`nyreg' {
		display as error "Error: yreg must be chosen from: `yregtypes'."
		error 198		
		}
	else {
		local mreg : word `nyreg' of `yregtypes'
		}
		
	if ("`nointeraction'" == "") {
		tempvar inter
		gen `inter' = `dvar' * `mvar' if `touse'
		}

	if ("`cxd'"!="") {	
		foreach c in `cvar' {
			tempvar `dvar'X`c'
			gen ``dvar'X`c'' = `dvar' * `c' if `touse'
			local cxd_vars `cxd_vars'  ``dvar'X`c''
			}
		}

	if ("`cxm'"!="") {	
		foreach c in `cvar' {
			tempvar `mvar'X`c'
			gen ``mvar'X`c'' = `mvar' * `c' if `touse'
			local cxm_vars `cxm_vars'  ``mvar'X`c''
			}
		}


	tempvar `dvar'_orig_r001
	gen ``dvar'_orig_r001' = `dvar' if `touse'

	tempvar `mvar'_orig_r001
	gen ``mvar'_orig_r001' = `mvar' if `touse'
	
	qui `yreg' `yvar' `dvar' `mvar' `cvar' `inter' `cxd_vars' `cxm_vars' [`weight' `exp'] if `touse'
		
	qui replace `mvar'=`m'
	qui replace `dvar'=`d'
	
	if ("`cxd'"!="") {	
		foreach c in `cvar' {
			qui replace ``dvar'X`c'' = `dvar' * `c' if `touse'
			}
		}	

	if ("`cxm'"!="") {	
		foreach c in `cvar' {
			qui replace ``mvar'X`c'' = `mvar' * `c' if `touse'
			}
		}

	local imp_var_names "Ydm_r001 Ydm_r002 Ydm_r003"
	foreach name of local imp_var_names {
		capture confirm new variable `name'
		if !_rc {
			local Ydm `name'
			continue, break
			}
		}
	if _rc {
		display as error "{p 0 0 5 0}The command needs to create a variable to hold the imputations"
			display as error "with one of the following names: `imp_var_names', "
			display as error "but these variables have already been defined.{p_end}"
			error 110
			}
			
	qui predict `Ydm'
		
	qui replace `dvar'=`dstar'
	
	if ("`cxd'"!="") {	
		foreach c in `cvar' {
			qui replace ``dvar'X`c'' = `dvar' * `c' if `touse'
			}
		}		

	local imp_var_names "Ydstarm_r001 Ydstarm_r002 Ydstarm_r003"
	foreach name of local imp_var_names {
		capture confirm new variable `name'
		if !_rc {
			local Ydstarm `name'
			continue, break
			}
		}
	if _rc {
		display as error "{p 0 0 5 0}The command needs to create a variable to hold the imputations"
			display as error "with one of the following names: `imp_var_names', "
			display as error "but these variables have already been defined.{p_end}"
			error 110
			}
			
	qui predict `Ydstarm'

	tempvar CDEgivenC
	gen `CDEgivenC' = `Ydm' - `Ydstarm'
		
	qui reg `CDEgivenC' [`weight' `exp'] if `touse'
		
	return scalar cde = _b[_cons]

	qui replace `dvar' = ``dvar'_orig_r001'
	qui replace `mvar' = ``mvar'_orig_r001'
	
	qui drop `Ydstarm' `Ydm'
		
end impcdebs
