# This script downloads and cleans the BART data from:
# https://www.bart.gov/about/reports/ridership

# NOTE: we only install packages once, so these lines are commented out.
# install.packages("rvest")
# install.packages("tidyverse")

library("dplyr")  # for working with data frames
library("purrr")  # for iteration
library("readxl")  # for reading Excel files
library("rvest")  # for web scraping
library("stringr")  # for string processing


get_ridership_urls = function(
    url = "https://www.bart.gov/about/reports/ridership"
) {
  # Get the Monthly Ridership links from the website.
  doc = read_html(url)
  links = html_elements(doc, css = "a")
  link_text = html_text(links)

  # Find the links that contain "Ridership Report"
  is_ridership = str_detect(link_text, "Ridership Report")
  ridership_links = links[is_ridership]
  ridership_urls = html_attr(ridership_links, "href")
  ridership_urls = url_absolute(ridership_urls, url)
  ridership_urls
}


download_to_dir = function(
    url,
    data_dir = "data"
) {
  file_path = file.path(data_dir, basename(url))
  download.file(url, file_path)
  # Return the file path.
  file_path
}


read_ridership_report = function(path) {
  # Sheet "Wkdy Adj OD"
  sheet = read_excel(path, sheet = "Wkdy Adj OD", col_names = FALSE)

  # Find the header row and make it the header.
  header_index = match("RM", sheet$...2)
  header = as.character(sheet[header_index, ])
  data = sheet[(header_index + 1):nrow(sheet), ]
  names(data) = header
  names(data)[1] = "exit_station"

  # Find the "Exit" column
  exits_index = match("Exits", header)
  data = data[, 1:exits_index]

  # TODO: Many columns are still characters.

  data
}


# Starting point for our code.
main = function() {
  # Download the data.
  urls = get_ridership_urls()

  # Download the file at each link.
  # download_to_dir(urls[1])
  # download_to_dir(urls[2])
  # for (u in urls) {
  paths = map_chr(urls, \(u) {
    p = download_to_dir(u)
    Sys.sleep(1 / 20)
    p
  })

  # NOTE: comparing a for-loop to the map function. Notice that x is NULL at
  # the end of the loop, but contains the values 1:10 at the end of the map.
  # Meanwhile the syntax is only slightly different.
  #
  #x = for (i in 1:10) {
  #  i
  #}
  #
  #x = map(1:10, \(i) {
  #  i
  #})

  # Unzip the data.
  # Figure out which are zip files.
  zip_paths = str_subset(paths, "[.]zip$")

  #?unzip
  # zipfile, junkpaths, exdir
  # extracted = unzip(zip_paths[1], junkpaths = TRUE, exdir = "data")
  unzip_paths = map(zip_paths, \(zp) {
    unzip(zp, junkpaths = TRUE, exdir = "data")
  })
  # Flatten out the list of paths.
  unzip_paths = list_c(unzip_paths)

  # Get one big vector of Excel file paths.
  excel_paths = str_subset(paths, "[.]xlsx$")
  excel_paths = c(excel_paths, unzip_paths)
  excel_paths

  # Read the files (Excel format).
  read_excel(excel_paths[1])
  excel_paths[1]

  # Test/read the oldest files first.
  # Get the year associated with each file.
  years = str_extract(excel_paths, "20[0-2][0-9]")
  meta = data.frame(year = as.numeric(years), path = excel_paths)
  meta

  # NOTE: this is just for testing the read_ridership_report function.
  paths2001 = filter(meta, year <= 2001)$path

  read_ridership_report(paths2001[1])
  read_ridership_report(paths2001[2])

  # TODO: Do some cleaning.
}
