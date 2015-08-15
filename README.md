ogdindiar
========

R Package to access [Open Government Data from India](https://data.gov.in).

## Introduction

This package provides easy access to the API provided by [Open Government Data Platform - India](https://data.gov.in) to download datasets from R. Here's the list of [Datasets available through API](https://data.gov.in/catalogs#path=is_api/1).

## Prerequisite

To use this package to download data from [Open Government Data Platform - India](https://data.gov.in), you'll first need to signup on the portal and obtain an API key. (API key is a 32 characters long hexadecimal string). When you make your first API call you'll be asked to provide this API key. You can also permanently store this key in your `.Renviron` file as OGDINDIA_API_KEY (preferred). For more info see ?ogdindia_api_key. You can also refer to ["Appendix: API key best practices" for httr package on cran](https://cran.r-project.org/web/packages/httr/vignettes/api-packages.html) for an example on how to set API key in .Renviron file.

## Installation

This package is currently available on github, you can install the latest development version as follows.

```r
library(devtools)
# OGDINDIA_API_KEY should be set correctly prior to this
devtools::install_github("steadyfish/ogdindiar", build_vignettes = TRUE) 

# to install package without building vignettes, no need to set OGDINDIA_API_KEY beforehand.
# devtools::install_github("steadyfish/ogdindiar") 

library(ogdindiar)
```

## Usage

For usage, check this [Vignette](https://github.com/steadyfish/ogdindiar/blob/master/vignettes/basic-usage-vignette.Rmd) OR run this, if you have installed package with  `build_vignettes = TRUE` option - 

```r
vignette("basic-usage-vignette")
```
Authors: [Dhrumin Shah](https://github.com/steadyfish/)


You are welcome to:
  
  * [submit suggestions and bug-reports](https://github.com/steadyfish/ogdindiar/issues)
  * [send a pull request](https://github.com/steadyfish/ogdindiar/)
