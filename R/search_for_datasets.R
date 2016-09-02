mk_link <- . %>% paste0("https://data.gov.in", .)

generator_of_get_link <- function(x, wait = 0.25) {
  
  env_obj <- new.env(hash = FALSE, emptyenv())
  env_obj$last_url_accessed <- NA_real_
  
  function(x, wait = 0.25) {
    if ( !is.na(env_obj$last_url_accessed) &&
         ((diff <- as.numeric(Sys.time()) - env_obj$last_url_accessed) < wait) ) {
      Sys.sleep(wait - diff)
    }
    
    #TODO: Add retry functionality here
    message('Requesting page ', x)
    ans <- read_html(x)
    
    env_obj$last_url_accessed <- as.numeric(Sys.time())
    
    ans
  }
}

get_link <- generator_of_get_link()

fill_na_if_empty <- function(x) {
  if (length(x) != 0) return(x)
  x[NA]
}

extract_resource_id <- function(api_link) {
  get_link(api_link) %>%
    html_nodes(css = 'p:nth-child(4) a') %>%
    html_attr('href') %>% 
    gsub(x = ., pattern = '.*resource_id=(.*)&api-key=YOURKEY$', replacement = '\\1')
}

extract_catalogs_from_search_result <- function(parsed_html) {
  link_nodes <- parsed_html %>% html_nodes(css = '.views-field-title a')
  
  link_data <- data.frame(name = html_text(link_nodes),
                          link = html_attr(link_nodes, 'href'),
                          stringsAsFactors = FALSE)
  
  category <- dirname(link_data$link) %>% gsub(pattern = '^/', replacement = '')
  
  link_data[category %in% 'catalog', , drop = FALSE]
}

extract_info_from_single_data_set <- function(single_data_set) {
  
  data_set_name <- single_data_set %>% html_nodes(css = '.title-content') %>% html_text
  
  granularity <- single_data_set %>%
    html_nodes(css = '.views-field-field-granularity .field-content') %>%
    html_text
  
  file_size <- single_data_set %>%
    html_nodes(css = '.download-filesize') %>%
    html_text %>% 
    gsub(x = ., pattern = '.*File Size: (.*)', replacement = '\\1')
  
  download_count <- single_data_set %>%
    html_nodes(css = '.download-counts') %>%
    html_text %>% 
    gsub(x = ., pattern = '.*Download: (.*)', replacement = '\\1') %>% 
    as.numeric
  
  res_id <- single_data_set %>%
    html_nodes(css = '.api-link') %>%
    html_attr('href') %>% 
    fill_na_if_empty %>% 
    ifelse(is.na(.), yes = ., no = extract_resource_id(.))
  
  csv_link   <- single_data_set %>% html_nodes(css = '.data-extension') %>% html_attr('href')
  ods_link   <- single_data_set %>% html_nodes(css = '.ods')            %>% html_attr('href')
  xls_link   <- single_data_set %>% html_nodes(css = '.xls')            %>% html_attr('href')
  json_link  <- single_data_set %>% html_nodes(css = '.json')           %>% html_attr('href')
  xml_link   <- single_data_set %>% html_nodes(css = '.xml')            %>% html_attr('href')
  jsonp_link <- single_data_set %>% html_nodes(css = '.jsonp')          %>% html_attr('href')
  
  reference_url <- single_data_set %>% html_nodes(css = '.ext') %>% html_attr('href')
  note <- single_data_set %>% html_nodes(css = '.ogpl-processed') %>% html_text
  
  data.frame(name             = fill_na_if_empty(data_set_name),
             granularity      = fill_na_if_empty(granularity),
             file_size        = fill_na_if_empty(file_size),
             downloads        = fill_na_if_empty(download_count),
             res_id           = res_id,
             csv              = fill_na_if_empty(csv_link),
             ods              = fill_na_if_empty(ods_link),
             xls              = fill_na_if_empty(xls_link),
             json             = fill_na_if_empty(json_link),
             xml              = fill_na_if_empty(xml_link),
             jsonp            = fill_na_if_empty(jsonp_link),
             stringsAsFactors = FALSE)
}

#' @title get data sets for a catalog
#' @description Get the list of data sets and related info for a catalog
#' @param catalog_link Link to the catalog
#' @param limit_dataset_pages Limit the number of pages that should be requested and parsed, to acquire the datasets. Default is 5. Set to Inf to request all.
#' @param limit_datasets Request more pages until the number of datasets obtained reaches this limit. Default is 10. Set to Inf to request all.
#' @importFrom magrittr %>%
#' @importFrom xml2 read_html
#' @importFrom rvest html_nodes html_text html_attr
#' @export
#' @examples
#' \dontrun{
#' get_datasets_from_a_catalog(
#' 'https://data.gov.in/catalog/session-wise-statistical-information-relating-questions-rajya-sabha',
#' limit_dataset_pages = 7, limit_datasets = 10)
#' }
#' @seealso search_for_datasets
get_datasets_from_a_catalog <- function(catalog_link, limit_dataset_pages = 5L, limit_datasets = 10L) {
  
  if (length(catalog_link) != 1) stop('Only one catalog link must be specified!')
  
  links_tried <- character(0)
  
  datasets <- data.frame(
    name             = character(0),
    granularity      = character(0),
    file_size        = character(0),
    downloads        = numeric(0),
    res_id           = character(0),
    csv              = character(0),
    ods              = character(0),
    xls              = character(0),
    json             = character(0),
    xml              = character(0),
    jsonp            = character(0),
    stringsAsFactors = FALSE
  )
  
  this_link <- catalog_link
  
  while ( (length(links_tried) < limit_dataset_pages) &&
          (nrow(datasets)      < limit_datasets) ) {
    
    this_catalog_result <- get_link(this_link)
    links_tried <- c(links_tried, this_link)
    
    data_set_nodes <- this_catalog_result %>%
      html_nodes(css = '.views-row.ogpl-grid-list')
    
    this_datasets <- lapply(data_set_nodes, extract_info_from_single_data_set) %>% 
      do.call(args = ., what = rbind)
    
    datasets <- rbind(datasets, this_datasets)
    
    message('Found ', nrow(datasets), ' datasets till now in this catalog')
    
    next_pages <- this_catalog_result %>% html_nodes(css = '.pager-item a') %>% html_attr('href')
    next_pages <- vapply(X = next_pages, FUN = mk_link, FUN.VALUE = 'temp', USE.NAMES = FALSE)
    
    next_pages <- setdiff(next_pages, links_tried)
    
    if (length(next_pages) < 1) break
    
    this_link <- next_pages[1]
  }
  
  datasets
}

#' @title Search for data sets
#' @description This function scrapes the data.gov.in search results and returns most of the information available for the datasets. As this function doesn't use API and just parses the web pages, there needs to delay between successive requests, and there should be limits to the number of pages that the function downloads from the web. For a particular search input, there may be multiple pages of search results. Each result page contains a list of catalogs. And each catalog contains multiple pages, with each page containing a list of data sets. There are default limits at each one of these stages. Make them 'Inf' if you need to get all the results or if you don't expect a large number of results. Please refer to vignette for a detailed overview.
#' @param search_terms Either one string with multiple words separated by space, or a character vector with all the search terms
#' @param limit_catalog_pages Number of pages of search results to request. Default is 5. Set to Inf to get all.
#' @param limit_catalogs Number of catalogs that the function should parse to get the data sets. Default is 5. Set to Inf to get all.
#' @param return_catalog_list Default is FALSE. If TRUE, the function will not look for data sets, and will only return the list of catalogs found.
#' @param limit_dataset_pages Limit the number of pages that should be requested and parsed, to acquire the datasets. Default is 5. Set to Inf to request all.
#' @param limit_datasets Request more pages until the number of datasets obtained reaches this limit. Default is 10. Set to Inf to request all.
#' @importFrom magrittr %>%
#' @importFrom xml2 read_html
#' @importFrom rvest html_nodes html_text html_attr
#' @export
#' @examples
#' \dontrun{
#' # Basic Use:
#' search_for_datasets('train usage')
#' 
#' # Advanced Use, specifying additional parameters
#' search_for_datasets(search_terms = c('state', 'gdp'),
#'                     limit_catalog_pages = 1,
#'                     limit_catalogs = 3,
#'                     limit_dataset_pages = 2)
#' search_for_datasets(search_terms = c('state', 'gdp'),
#'                     limit_catalog_pages = 2,
#'                     return_catalog_list = TRUE)
#' }
#' @seealso get_datasets_from_a_catalog
search_for_datasets <- function(search_terms,
                                limit_catalog_pages = 5L,
                                limit_catalogs      = 10L,
                                return_catalog_list = FALSE,
                                limit_dataset_pages = 5L,
                                limit_datasets      = 10L) {
  
  #TODO: Escaping of search terms
  search_terms_collapsed <- search_terms %>%
    paste(collapse = ' ') %>%
    gsub(pattern = ' +', replacement = '+')
  
  relative_link <- paste0('/catalogs?query=',
                          search_terms_collapsed,
                          '&sort_by=search_api_relevance',
                          '&sort_order=DESC',
                          '&items_per_page=9')
  
  
  links_tried <- character(0)
  
  catalogs <- data.frame(
    name = character(0),
    link = character(0),
    stringsAsFactors = FALSE
  )
  
  this_link <- relative_link
  
  while ( (length(links_tried) < limit_catalog_pages) && 
          (nrow(catalogs)      < limit_catalogs) ) {
    
    search_result <- get_link(mk_link(this_link))
    links_tried <- c(links_tried, this_link)
    
    catalogs <- rbind(catalogs,
                      extract_catalogs_from_search_result(search_result))
    
    message('Found ', nrow(catalogs), ' catalogs till now')
    
    next_pages_links <- search_result %>%
      html_nodes(css = '.pager-item a') %>%
      html_attr('href')
    
    next_pages_links <- setdiff(next_pages_links, links_tried)
    
    if (length(next_pages_links) < 1) break
    
    this_link <- next_pages_links[1]
  }
  
  if (return_catalog_list) {
    catalogs$link <- vapply(X = catalogs$link,
                            FUN = mk_link,
                            FUN.VALUE = 'text',
                            USE.NAMES = FALSE)
    return(catalogs) 
  }
  
  datasets <- data.frame(
    name             = character(0),
    granularity      = character(0),
    file_size        = character(0),
    downloads        = numeric(0),
    res_id           = character(0),
    csv              = character(0),
    ods              = character(0),
    xls              = character(0),
    json             = character(0),
    xml              = character(0),
    jsonp            = character(0),
    stringsAsFactors = FALSE
  )
  
  for (one_catalog in catalogs$link) {
    this_datasets <- get_datasets_from_a_catalog(
      catalog_link = mk_link(one_catalog),
      limit_dataset_pages = limit_dataset_pages,
      limit_datasets = limit_datasets
    )
    
    datasets <- rbind(datasets, this_datasets)
    
    message('Found a total of ', nrow(datasets), ' datasets till now')
    
    if (nrow(datasets) > limit_datasets) break
  }
  
  datasets
}
