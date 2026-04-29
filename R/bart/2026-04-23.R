

# BART Case Study
# Goal: collect the data for the monthly average
# entry-exit counts for BART.
#
# From:
# https://www.bart.gov/about/reports/ridership
#
#
# What steps do we need to take?
#
# 1. Download all of the files.
# 2. Unzip all of the files.
# 3. Read the Excel files into R.
# 4. Clean each Excel file's data.
# 5. Combine the data in some way.
# 6. Make a plot.

library("purrr")
library("rvest")
library("stringr")


# Get the URLs for the BART ridership reports.
get_bart_report_urls = function(
  url = "https://www.bart.gov/about/reports/ridership"
) {
  # Download all of the files.
  doc = read_html(url)
  
  links = html_elements(doc, "a")
  
  # Need to check for "Monthly Ridership Reports" in
  # the link text.
  text = html_text(links)
  is_report = str_detect(text, "Monthly Ridership Reports")
  report_links = links[is_report]
  
  # Now we need to get the URL from the href attribute.
  report_urls = html_attr(report_links, "href")
  
  url_absolute(report_urls, url)
}


download_bart_data = function(
  urls,
  output_directory = "data/source/"
) {
  # Download each of the files at each of the URLs
  # to a directory called `data/source/`.
  # We'll assume this script runs at the top-level
  # directory of the project.
  
  # Make sure that `data/source/` exists.
  if (!dir.exists(output_directory)) {
    dir.create(output_directory, recursive = TRUE)
  }
  
  # We'll use download.file()
  #?download.file
  #for (u in urls) {
  map_chr(urls, \(u) {  # this is just a loop!
    # Get the name of the file.
    name = basename(u)
    # Attach it to the output directory.
    output_path = file.path(output_directory, name)
    # Download the file.
    download.file(u, output_path)
    # Return the path to the downloaded file.
    output_path
  })
}


unzip_bart_data = function(
  paths,
  output_directory = "data/unzipped/"
) {
  # Extract each of BART data files.
  # We'll use the built-in unzip() function.
  #?unzip
  
  # Make sure that output_directory exists.
  if (!dir.exists(output_directory)) {
    dir.create(output_directory, recursive = TRUE)
  }
  
  map(paths, \(p) {
    unzip(
      p,
      junkpaths = TRUE,
      exdir = output_directory
    )
  })
}


if (sys.nframe() == 0) {
  # Whatever needs to happen when we run
  # the script with Rscript on the command line
  # ...
  urls = get_bart_report_urls()
  files = download_bart_data(urls)
  excel_paths = unzip_bart_data(files)
}

