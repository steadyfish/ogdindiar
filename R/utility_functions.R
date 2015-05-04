####Download the data from Government of India open data portal#####
# w_dir = getwd()
# source(file=file.path("R/core.R"))
# check_and_download(c("XML","RCurl","RJSONIO","plyr","dplyr"))

### Alternative - 1: Using APIs ###
#JSON#





#' Get JSON data for requested data resource 
#'
#' \code{get_JSON_doc} will return infomation about the requested resource.
#' @param link a string, general JSON data link
#' @param res_id a string, JSON data resource id
#' @param api_key a string, private api key of user, can be obtained by signing up on data.gov.in portal
#' @param offset an integer, offset of 1 corresponds to 100 elements
#' @param no_elements an integer, no of elements to download a value between 1 to 100
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
                         res_id, api_key, offset, no_elements){
  JSON_URL = paste(link,
                   "resource_id=",res_id, 
                   "&api-key=",api_key,
                   "&offset=",offset,
                   "&limit=",no_elements,
                   sep="")
  print(JSON_URL)
  doc = RCurl::getURL(url = JSON_URL, cainfo = system.file("CurlSSL", "cacert.pem", package = "RCurl"))
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

#' Load data from the Government of India API.  
#'
#' \code{fetch_data} is the main function from this package to load the entire data set from the Government of India API.
#' @param res_id a string, JSON data resource id
#' @param api_key a string, private api key of user, can be obtained by signing up on \url{data.gov.in} portal
#' @return data a data.frame, data from the Government of India API
#' @keywords Name
#' @examples
#' \dontrun{
#' ### fetch a dataset using it's resource id and your personal API key
#' fetch_data(res_id = <res_id>, api_key = <api_key>)
#' }
#' @export
fetch_data <- function(res_id,api_key){
  current_itr = 0
  return_count = 1
  while(return_count>0){
    JSON_list = get_JSON_doc(link="https://data.gov.in/api/datastore/resource.json?",
                             res_id=res_id,
                             api_key=api_key,
                             offset=current_itr,
                             no_elements=100)
    data_stage1 = plyr::ldply(get_data(JSON_list),to_data_frame)
    print(current_itr)
    print(is(data_stage1$id))
    return_count = get_count(JSON_list)
    if(current_itr == 0) {
      return_data = data_stage1
      return_field_type = plyr::ldply(get_field_type(JSON_list),to_data_frame)
    }
    else if(return_count > 0) return_data = rbind(return_data, data_stage1)
    print(current_itr)
    print(is(return_data$id))
    current_itr = current_itr + 1  
  }
  list(return_data,return_field_type)
}
