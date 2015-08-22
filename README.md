ogdindiar
========

R Package to access [Open Government Data from India](https://data.gov.in).

## Introduction

This package provides easy access to the API provided by [Open Government Data Platform - India](https://data.gov.in) to download datasets from R. Here's the list of [Datasets available through API](https://data.gov.in/catalogs#path=is_api/1).

## <a name="prerequisite"></a>Prerequisite

* To use this package to download data from [Open Government Data Platform - India](https://data.gov.in), you'll first need to signup on the portal and obtain an API key. (API key is a 32 characters long hexadecimal string).
* You can either set it as a temporary global variable or a permanent global variable.
  1. **Temporary variable approach:** when you make your first API call you'll be asked to provide this API key. 
  2. **Permanent variable approach:** You can permanently store this key in your `.Renviron` file as `OGDINDIA_API_KEY` (preferred). For more info see `?ogdindia_api_key`. You can also refer to ["Appendix: API key best practices" for httr package on cran](https://cran.r-project.org/web/packages/httr/vignettes/api-packages.html) for an example on how to set a global variable in `.Renviron` file.

## Installation

This package is currently available on github, you can install the latest development version as follows:

```r
library(devtools)
devtools::install_github("steadyfish/ogdindiar")

```

If you intend to build the vignette yourself, you'll first need to set the `OGDINDIA_API_KEY` as shown in [Prerequisite](#prerequisite) section above. You can then install the package as follows:

```r
library(devtools)
devtools::install_github("steadyfish/ogdindiar", build_vignettes = TRUE) 

```

## Usage

For usage, check out this [Vignette](https://github.com/steadyfish/ogdindiar/blob/master/vignettes/basic-usage-vignette.md). Otherwise, you can run the following, if you have installed the package with `build_vignettes = TRUE` option - 

```r
vignette("basic-usage-vignette")
```

******

### Authors 
  
  [Dhrumin Shah](https://github.com/steadyfish/)

### Credits 
  
  Encouragement and support from [Leo Lahti](https://github.com/antagomir) from [rOpenGov](https://github.com/rOpenGov) made the package development a lot easier.

### You are welcome to
  
  * [submit suggestions and bug-reports](https://github.com/steadyfish/ogdindiar/issues)
  * [send a pull request](https://github.com/steadyfish/ogdindiar/)
