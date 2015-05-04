#' Get field/variable names from the JSON data object
#'
#' This will return field names from the JSON data object.
#' @param x a list, i.e. a JSON data object
#' @return field_names a vector/list, of field names for JSON data object 
#' @keywords Name
#' @examples
#' \dontrun{
#' ###Return field names from a JSON data object (obtained using get_JSON_doc())
#' get_field_names(x = JSON_doc)
#' }
#' @export
get_field_names <- function(x){
  #x: list
  names(x[[4]])
}

#' Get count of elements that were returned from JSON data query
#'
#' This will return the no of elements that were returned from JSON data query.
#' @param x a list, i.e. a JSON data object
#' @return no_elements an integer, no of elements to download a value between 1 to 100
#' @keywords Name
#' @examples
#' \dontrun{
#' ###Return no of elements from a JSON data object (obtained using get_JSON_doc())
#' get_count(x = JSON_doc)
#' }
#' @export
get_count <- function(x){
  #x: list
  x[[3]]
}

#' Get field/variable types from the JSON data object
#'
#' This will return field types from the JSON data object.
#' @param x a list, i.e. a JSON data object
#' @return field_types a list/vector, field type of each of the fields
#' @keywords Name
#' @examples
#' \dontrun{
#' ###Return field types from a JSON data object (obtained using get_JSON_doc())
#' get_field_names(x = JSON_doc)
#' }
#' @export
get_field_type<-function(x){
  x[[4]]
}  

#' Get data from the JSON data object 
#'
#' This will return the data from the JSON data object.
#' @param x a list, i.e. a JSON data object
#' @return data a list, data from the JSON data object
#' @keywords Name
#' @examples
#' \dontrun{
#' ###Return data from a JSON data object (obtained using get_JSON_doc())
#' get_data(x = JSON_doc)
#' }
#' @export
get_data <- function(x){
  x[[5]]
}
