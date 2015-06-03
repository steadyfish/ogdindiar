####Download the data from Government of India open data portal#####
# w_dir = getwd()
# source(file=file.path("R/core.R"))
# check_and_download(c("XML","RCurl","RJSONIO","plyr","dplyr"))

### Alternative - 1: Using APIs ###
#JSON#





#' Get JSON data for requested data resource 
#'
#' \code{get_JSON_doc} will return infomation about the requested resource. Ideally, will be just used internally.
#' @param link a string, general JSON data link
#' @param res_id a string, JSON data resource id
#' @param api_key a string, private api key of user, can be obtained by signing up on data.gov.in portal
#' @param offset an integer, offset of 1 corresponds to 100 elements
#' @param no_elements an integer, no of elements to download a value between 1 to 100
#' @param filter a named vector, specifying equality constrainsts of the form "variable" = "condition"
#' @param select a vector, specifying variables/fields to be selected
#' @param sort a named vector, specifying sort order in the form "variable" = "asc"
#' @return JSON data object i.e. a list
#' @keywords Name
#' @examples
#' \dontrun{
#' library(RCurl)
#' library(RJSONIO)
#' # Return 100 elements from a hotels data resource
#' JSON_doc = get_JSON_doc(link="http://data.gov.in/api/datastore/resource.json?",
#'    res_id="0749068c-a590-4a07-a571-e9df5dddcc8a",
#'    api_key=api_key,
#'    offset=0,
#'    no_elements=100)
#' }
#' @export
get_JSON_doc <- function(link = "https://data.gov.in/api/datastore/resource.json?", 
                         res_id, api_key, offset, no_elements,
                         filter, select, sort){
  filter_str = ifelse(!is.null(filter), paste0("&filters[", paste(names(filter), filter, sep="]="), collapse = ""), "")
  select_str = ifelse(!is.null(select), paste0("&fields=", paste(select, collapse = "," )), "")
  sort_str = ifelse(!is.null(sort), paste0("&sort[", paste(names(sort), sort, sep="]="), collapse = ""), "")
  
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
    
  print(JSON_URL)
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
#' @param api_key a string, private api key of user, can be obtained by signing up on \url{data.gov.in} portal
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
#' fetch_data(res_id = "60a68cec-7d1a-4e0e-a7eb-73ee1c7f29b7", api_key = <api_key>,
#'            filter = c("state" = "Maharashtra"), 
#'            select = c("s_no_","constituency","state"),
#'            sort = c("s_no_" = "asc","constituency" = "desc"))
#' }
#' @export
fetch_data <- function(res_id, api_key, filter = NULL, select = NULL, sort = NULL, field_type_correction = TRUE){
  current_itr = 0
  return_count = 1
  while(return_count>0){
    JSON_list = get_JSON_doc(link = "https://data.gov.in/api/datastore/resource.json?",
                             res_id = res_id,
                             api_key = api_key,
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
