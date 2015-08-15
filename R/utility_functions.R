#' Get or set OGDINDIA_API_KEY value
#'
#' The API wrapper functions in this package all rely on a Open Government Data India API
#' key residing in the environment variable \code{OGDINDIA_API_KEY}. The
#' easiest way to accomplish this is to set it in the `.Renviron` file in your
#' home directory.
#'
#' @param force Force setting a new PassiveTotal API key for the current environment?
#' @return atomic character vector containing the Open Government Data India API key
#' @export
ogdindia_api_key <- function(force = FALSE) {
  
  env <- Sys.getenv('OGDINDIA_API_KEY')
  if (!identical(env, "") && !force) return(env)
  
  if (!interactive()) {
    stop("Please set env var OGDINDIA_API_KEY to your Open Government Data India API key",
         call. = FALSE)
  }
  
  message("Couldn't find env var OGDINDIA_API_KEY See ?ogdindia_api_key for more details.")
  message("Please enter your API key and press enter:")
  api_key <- readline(": ")
  
  if (identical(pat, "")) {
    stop("Open Government Data India API key entry failed", call. = FALSE)
  }
  
  message(paste0("Updating OGDINDIA_API_KEY env var to ", api_key))
  Sys.setenv(OGDINDIA_API_KEY = api_key)
  
  api_key
  
}

### Alternative - 1: Using APIs ###
#JSON#





#' Get JSON data for requested data resource 
#'
#' \code{get_JSON_doc} will return infomation about the requested resource. Ideally, will be just used internally.
#' @param link a string, general JSON data link
#' @param res_id a string, JSON data resource id
#' @param offset an integer, offset of 1 corresponds to 100 elements
#' @param no_elements an integer, no of elements to download a value between 1 to 100
#' @param filter a named vector, specifying equality constrainsts of the form "variable" = "condition"
#' @param select a vector, specifying variables/fields to be selected
#' @param sort a named vector, specifying sort order in the form "variable" = "asc"
#' @param verbose a boolean, specifying whether to print verbose messages
#' @return JSON data object i.e. a list
#' @keywords Name
#' @examples
#' \dontrun{
#' library(RCurl)
#' library(RJSONIO)
#' # Return 100 elements from a hotels data resource
#' JSON_doc = get_JSON_doc(link="http://data.gov.in/api/datastore/resource.json?",
#'    res_id="0749068c-a590-4a07-a571-e9df5dddcc8a",
#'    offset=0,
#'    no_elements=100)
#' }
#' @export
get_JSON_doc <- function(link = "https://data.gov.in/api/datastore/resource.json?", 
                         res_id, offset, no_elements,
                         filter, select, sort, verbose = FALSE){
  filter_str = ifelse(!is.null(filter), paste0("&filters[", paste(names(filter), filter, sep="]="), collapse = ""), "")
  select_str = ifelse(!is.null(select), paste0("&fields=", paste(select, collapse = "," )), "")
  sort_str = ifelse(!is.null(sort), paste0("&sort[", paste(names(sort), sort, sep="]="), collapse = ""), "")
  api_key = ogdindia_api_key()
  
  JSON_URL = paste(link,
                   "resource_id=",res_id, 
                   "&api-key=",api_key,
                   "&offset=",offset,
                   "&limit=",no_elements,
                   filter_str,
                   select_str,
                   sort_str,
                   sep="")
  
#   options(RCurlOptions = list(cainfo = system.file("CurlSSL", "cacert.pem", package = "RCurl")
#                               , verbose = "TRUE"
#                               ))
#   credentials$handshake()
    
  if(verbose) print(JSON_URL)

  doc = RCurl::getURL(url = JSON_URL, cainfo = system.file("CurlSSL", "cacert.pem", package = "RCurl")) # 
  d_out = RJSONIO::fromJSON(doc)
  return(d_out)
}

#' Convert data from list to a data.frame  
#'
#' \code{to_data_frame} will convert data from 'list' to a 'data.frame'. 
#' @param x a list of data from a JSON data object
#' @return data a data.frame, data from the JSON data object
#' @keywords Name
#' @examples
#' \dontrun{
#' ###Convert a list to data.frame
#' to_data_frame(x = get_data(JSON_list))
#' }
#' @export
to_data_frame <- function(lst_elmnt){
  as.data.frame(t(unlist(lst_elmnt)), stringsAsFactors = FALSE)
}

#' Apply field type correction based on accompanied metadata
#' 
#' \code{rectify_field_type} will convert select fields to numeric based on accompanied metadata 
#' @param d_in, a data.frame on which the correction is to be applied.
#' @param d_fields, a data.frame containing fields metadata
#' @return data corrected data.frame
#' @keywords Internal, rectify
#' @examples
#' \dontrun{
#' rectify_field_type(data_stage2, data_field_type)
#' }
#' @export
rectify_field_type <- function(d_in, d_fields){
  
  # get integer fields
  int_fields = d_fields[d_fields$type=="int",1]
  col_names = names(d_in)
  d_int1 = lapply(X = col_names, FUN = function(x, y, z) {if(x %in% y) class(z[, x]) = "numeric"; 
                                                          ret = z[, x]; return(ret)},
                  y = int_fields, z = d_in)
  names(d_int1) = col_names
  d_out = as.data.frame(d_int1, stringsAsFactors = FALSE)
  
  return(d_out)
}

#' Load data from the Government of India API.  
#'
#' \code{fetch_data} is the main function from this package to load the entire data set from the Government of India API.
#' @param res_id a string, JSON data resource id
#' @param filter a named vector, specifying equality constrainsts of the form "variable" = "condition"
#' @param select a vector, specifying variables/fields to be selected
#' @param sort a named vector, specifying sort order in the form "variable" = "order"
#' @param field_type_correction boolean, whether to apply field type correction. All data fields are downloaded as character and then corrected (if at all) based on accompanying metadata
#' @return list a list of 2 elements - data from the Government of India API, and metadata, additional information about the fields
#' @keywords Name
#' @examples
#' \dontrun{
#' ### fetch a dataset using it's resource id and your personal API key
#' # Basic Use:
#' fetch_data()
#' 
#' # Advanced Use, specifying additional parameters
#' fetch_data(res_id = "60a68cec-7d1a-4e0e-a7eb-73ee1c7f29b7"
#'            filter = c("state" = "Maharashtra"), 
#'            select = c("s_no_","constituency","state"),
#'            sort = c("s_no_" = "asc","constituency" = "desc"))
#' }
#' @export
fetch_data <- function(res_id, filter = NULL, select = NULL, sort = NULL, field_type_correction = TRUE){
  current_itr = 0
  return_count = 1
  while(return_count>0){
    JSON_list = get_JSON_doc(link = "https://data.gov.in/api/datastore/resource.json?",
                             res_id = res_id,
                             offset = current_itr,
                             no_elements = 100,
                             filter = filter,
                             select = select,
                             sort = sort)
    data_stage1 = plyr::ldply(get_data(JSON_list), to_data_frame)
    return_count = get_count(JSON_list)
    if(current_itr == 0) {
      data_stage2 = data_stage1
      data_field_type = plyr::ldply(get_field_type(JSON_list), to_data_frame)
    }
    else if(return_count > 0) data_stage2 = rbind(data_stage2, data_stage1)
    current_itr = current_itr + 1  
  }
  
  if(field_type_correction){
    data_stage3 = rectify_field_type(data_stage2, data_field_type)
  }
  else{
    data_stage3 = data_stage2
  }
  list(data_stage3, data_field_type)
}
