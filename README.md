# impcde: Estimating Controlled Direct Effects Using Regression Imputation

`impcde` is a Stata module designed to estimate controlled direct effects (CDE) using regression imputation.

## Syntax

```stata
impcde depvar, dvar(varname) mvar(varname) d(real) dstar(real) m(real) yreg(string) [options]
```

### Required Arguments

- `depvar`: Specifies the outcome variable.
- `dvar(varname)`: Specifies the treatment (exposure) variable.
- `mvar(varname)`: Specifies the mediator variable.
- `d(real)`: Reference level of treatment.
- `dstar(real)`: Alternative level of treatment, defining the treatment contrast.
- `m(real)`: Level of the mediator at which the controlled direct effect is evaluated.
- `yreg(string)`: Specifies the form of regression model for the outcome. Options are `regress`, `logit`, or `poisson`.

### Options

- `cvars(varlist)`: Baseline covariates to include in the analysis.
- `nointer`: Excludes treatment-mediator interaction in the outcome model.
- `cxd`: Includes all two-way interactions between the treatment and baseline covariates.
- `cxm`: Includes all two-way interactions between the mediator and baseline covariates.
- `reps(integer)`: Number of bootstrap replications, default is 200.
- `strata(varname)`: Identifies resampling strata.
- `cluster(varname)`: Identifies resampling clusters.
- `level(cilevel)`: Confidence level for bootstrap confidence intervals, default is 95%.
- `seed(passthru)`: Seed for bootstrap resampling.
- `detail`: Prints the fitted outcome model.

## Description

`impcde` fits a single model for the outcome conditional on treatment, the mediator, and baseline covariates. This model can be a linear, logistic, or poisson regression, depending on the specification. This module is used to construct regression imputation estimates for the controlled direct effect.

## Examples

```stata
// Load data
use nlsy79.dta

// Default settings with no interaction
impcde std_cesd_age40, dvar(att22) mvar(ever_unemp_age3539) cvars(female black hispan paredu parprof parinc_prank famsize afqt3) d(1) dstar(0) m(0) yreg(regress) nointer reps(1000)

// Include treatment-mediator interaction
impcde std_cesd_age40, dvar(att22) mvar(ever_unemp_age3539) cvars(female black hispan paredu parprof parinc_prank famsize afqt3) d(1) dstar(0) m(0) yreg(regress) reps(1000)

// Include all two-way interactions
impcde std_cesd_age40, dvar(att22) mvar(ever_unemp_age3539) cvars(female black hispan paredu parprof parinc_prank famsize afqt3) d(1) dstar(0) m(0) yreg(regress) cxd reps(1000)
```

## Saved Results

`impcde` saves the following results in `e()`:

- **Matrices**:
  - `e(b)`: Matrix containing the controlled direct effect estimate.

## Author

Geoffrey T. Wodtke  
Department of Sociology  
University of Chicago

Email: [wodtke@uchicago.edu](mailto:wodtke@uchicago.edu)

## References

- Wodtke GT and Zhou X. Causal Mediation Analysis. In preparation.

## Also See

- [regress R](#)
- [logit R](#)
- [poisson R](#)
- [bootstrap R](#)
