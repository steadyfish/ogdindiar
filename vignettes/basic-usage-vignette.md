---
title: "Introduction"
author: "Dhrumin Shah"
date: "2015-05-10"
output: rmarkdown::html_vignette
vignette: >
  %\VignetteIndexEntry{Introduction}
  %\VignetteEngine{knitr::rmarkdown}
  %\VignetteEncoding{UTF-8}
---

## Introduction

This package provides easy access to the API provided by [Open Government Data Platform - India](https://data.gov.in) to download datasets from R. Here's the list of [Datasets available through API](https://data.gov.in/catalogs#path=is_api/1).

## Prerequisite

To use this package to download data from [Open Government Data Platform - India](https://data.gov.in), you'll first need to signup on the portal and obtain an API key. (API key is a 32 characters long hexadecimal string).

## Installation

This package is currently available on github, you can install the latest development version as follows -

    
    ```r
    devtools::install_github("steadyfish/ogdindiar")
    ```
    
    ```
    ## Downloading github repo steadyfish/ogdindiar@master
    ## Installing ogdindiar
    ## "C:/PROGRA~1/R/R-32~1.0/bin/x64/R" --vanilla CMD INSTALL  \
    ##   "C:/Users/DreamerNoob/AppData/Local/Temp/RtmpYljE3l/devtools1aa02a6d52/steadyfish-ogdindiar-a8665b4"  \
    ##   --library="C:/Users/pokerface/R/win-library/3.2" --install-tests 
    ## 
    ## Reloading installed ogdindiar
    ## Welcome to ogdindiar
    ```
    
    ```r
    library(ogdindiar)
    ```



## Basic Usage

The main function this package provides is `fetch_data()`. At minimum, you need to provide 2 arguments to this function.

* res_id: Resource id of the dataset you want to access
* api_key: Your personal API key (See Prerequisite above)

Resource id for the datasets can be found on the data specific page. For example, this page has the resource id information for [Annual And Seasonal Mean Temperature Of India](https://data.gov.in/resources/annual-and-seasonal-mean-temperature-india/api). The resource id a string that's part of Datastore API URL. 

* The URL for this dataset as shown on the page is - https://data.gov.in/api/datastore/resource.json?resource_id=<mark>98fe9271-a59d-4834-b05b-fd5ddb94ac01</mark>&api-key=YOURKEY 
* The resource id is the highlighted part in the above URL.

Once you have figured out these 2 parameters you can download that datasets as follows: 

    
    ```r
    mean_temp_data = fetch_data(res_id = "98fe9271-a59d-4834-b05b-fd5ddb94ac01",
                            api_key = your_api_key)
    ```
    
    ```
    ## [1] "https://data.gov.in/api/datastore/resource.json?resource_id=98fe9271-a59d-4834-b05b-fd5ddb94ac01&api-key=4a6b520b59fab36f4c78f8bac1a0afcf&offset=0&limit=100"
    ## [1] "https://data.gov.in/api/datastore/resource.json?resource_id=98fe9271-a59d-4834-b05b-fd5ddb94ac01&api-key=4a6b520b59fab36f4c78f8bac1a0afcf&offset=1&limit=100"
    ## [1] "https://data.gov.in/api/datastore/resource.json?resource_id=98fe9271-a59d-4834-b05b-fd5ddb94ac01&api-key=4a6b520b59fab36f4c78f8bac1a0afcf&offset=2&limit=100"
    ```

This function returns a list of 2 elements.

* The first element is the data

    
    ```r
    head(mean_temp_data[[1]])
    ```
    
    ```
    ##     id  timestamp year annual jan_feb mar_may jun_sep oct_dec
    ## 1 1123 1424778424 1957     23      18      25      27      21
    ## 2 1423 1424778424 1972     24      18      25      27      21
    ## 3 1443 1424778424 1973     24      19      26      27      21
    ## 4 1463 1424778424 1974     24      18      26      27      21
    ## 5 1483 1424778424 1975     23      18      25      26      21
    ## 6 1503 1424778424 1976     24      18      25      26      22
    ```

* The second element is a dataframe containing metadata about the columns.

    
    ```r
    mean_temp_data[[2]]
    ```
    
    ```
    ##         .id   type   size unsigned not null
    ## 1        id serial normal     TRUE     TRUE
    ## 2 timestamp    int normal     TRUE    FALSE
    ## 3      year    int normal     <NA>    FALSE
    ## 4    annual    int normal     <NA>    FALSE
    ## 5   jan_feb    int normal     <NA>    FALSE
    ## 6   mar_may    int normal     <NA>    FALSE
    ## 7   jun_sep    int normal     <NA>    FALSE
    ## 8   oct_dec    int normal     <NA>    FALSE
    ##                        description
    ## 1                                 
    ## 2 The Unix timestamp for the data.
    ## 3                                 
    ## 4                                 
    ## 5                                 
    ## 6                                 
    ## 7                                 
    ## 8
    ```

## Advanced Usage

Instead of downloading entire datasets you can conditionally download specific data. These functions are achieved using additional arguments to `fetch_data()` function. Currently you can use -

* `filter` to filter the dataset using __equality constraints__ on specific columns.
* `select` to select specific set of columns to be downloaded.
* `sort` to sort the resulting dataset based on multiple columns.

Following example illustrates this -

    
    ```r
    mean_temp_25 = fetch_data(res_id = "98fe9271-a59d-4834-b05b-fd5ddb94ac01",
                            api_key = your_api_key,
                            filter = c("annual" = "25"),
                            select = c("year", "annual", "jan_feb", "mar_may", "jun_sep", "oct_dec"),
                            sort = c("jan_feb" = "asc", "mar_may" = "desc")
                            )
    ```
    
    ```
    ## [1] "https://data.gov.in/api/datastore/resource.json?resource_id=98fe9271-a59d-4834-b05b-fd5ddb94ac01&api-key=4a6b520b59fab36f4c78f8bac1a0afcf&offset=0&limit=100&filters[annual]=25&fields=year,annual,jan_feb,mar_may,jun_sep,oct_dec&sort[jan_feb]=asc&sort[mar_may]=desc"
    ## [1] "https://data.gov.in/api/datastore/resource.json?resource_id=98fe9271-a59d-4834-b05b-fd5ddb94ac01&api-key=4a6b520b59fab36f4c78f8bac1a0afcf&offset=1&limit=100&filters[annual]=25&fields=year,annual,jan_feb,mar_may,jun_sep,oct_dec&sort[jan_feb]=asc&sort[mar_may]=desc"
    ```

    
    ```r
    head(mean_temp_25[[1]])
    ```
    
    ```
    ##   year annual jan_feb mar_may jun_sep oct_dec
    ## 1 2002     25      19      27      27      22
    ## 2 2010     25      20      27      27      22
    ## 3 1995     25      20      26      28      23
    ## 4 2009     25      20      26      27      22
    ## 5 2006     25      21      26      27      22
    ```

    
    ```r
    mean_temp_25[[2]]
    ```
    
    ```
    ##       .id type   size not null description
    ## 1    year  int normal    FALSE            
    ## 2  annual  int normal    FALSE            
    ## 3 jan_feb  int normal    FALSE            
    ## 4 mar_may  int normal    FALSE            
    ## 5 jun_sep  int normal    FALSE            
    ## 6 oct_dec  int normal    FALSE
    ```

There's one more argument that is passed to `fetch_data()` function, `field_type_correction`. The data fetch process inadvertently treats all the columns as `character`. The default setting `field_type_correction = TRUE` converts these columns back to `numeric` type based on accompanying metadata.

