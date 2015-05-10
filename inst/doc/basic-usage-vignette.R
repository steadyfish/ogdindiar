## ----install_lib, echo = TRUE, results = "hide"--------------------------
devtools::install_github("steadyfish/ogdindiar")
library(ogdindiar)

## ----hide_block, echo = FALSE, results = "hide"--------------------------
your_api_key = "4a6b520b59fab36f4c78f8bac1a0afcf"

## ------------------------------------------------------------------------
mean_temp_data = fetch_data(res_id = "98fe9271-a59d-4834-b05b-fd5ddb94ac01",
                        api_key = your_api_key)

## ------------------------------------------------------------------------
head(mean_temp_data[[1]])

## ------------------------------------------------------------------------
mean_temp_data[[2]]

## ------------------------------------------------------------------------
mean_temp_25 = fetch_data(res_id = "98fe9271-a59d-4834-b05b-fd5ddb94ac01",
                        api_key = your_api_key,
                        filter = c("annual" = "25"),
                        select = c("year", "annual", "jan_feb", "mar_may", "jun_sep", "oct_dec"),
                        sort = c("jan_feb" = "asc", "mar_may" = "desc")
                        )

## ------------------------------------------------------------------------
head(mean_temp_25[[1]])

## ------------------------------------------------------------------------
mean_temp_25[[2]]

