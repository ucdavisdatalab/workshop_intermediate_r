
library("dplyr")
library("ggplot2")
library("lubridate")
library("purrr")
library("readxl")
library("rvest")
library("stringr")
library("tibble")
library("tidyr")


fetch_bart_ridership_urls = function(
  url = "https://www.bart.gov/about/reports/ridership"
) {
  # Get all links on the ridership report page.
  doc = read_html(url)
  links = html_elements(doc, css = "a")

  # Filter to only links with "Ridership Report" in the text.
  is_report = str_detect(html_text(links), "Ridership Report")
  report_links = links[is_report]

  # Extract the URLs.
  hrefs = html_attr(report_links, "href")
  hrefs = url_absolute(hrefs, url)

  # Extract the year.
  filenames = basename(hrefs)
  year = str_extract(filenames, "20[0-2][0-9]")
  format = str_extract(filenames, "[.].+$")
  data.frame(year = year, format = format, url = hrefs)
}


download_files = function(urls, dest_dir) {
  # Set up a directory to store these files.
  dir.create(dest_dir, recursive = TRUE)

  # Download the files.
  map_chr(urls, function(u) {
    path = file.path(data_dir, basename(u))
    if (file.exists(path)) {
      message("Found '", path, "'")
    } else {
      download.file(u, path)
      message("Wrote '", path, "'")
      Sys.sleep(1 / 20)
    }
    path
  })
}


read_ridership = function(path, year, month, ...) {
  sheets = excel_sheets(path)
  if ("Wkdy Adj OD" %in% sheets) {
    df = read_excel(path, "Wkdy Adj OD", col_names = FALSE)
  } else if ("Weekday OD" %in% sheets) {
    df = read_excel(path, "Weekday OD", col_names = FALSE)
  } else {
    stop("Unsupported format.")
  }

  # Get the headers from the row where column 2 is "RM".
  header_ix = match("RM", df$...2)
  headers = as.character(df[header_ix, ])

  # Discard header rows from the data frame and set headers.
  df = df[-seq_len(header_ix), ]
  names(df) = headers
  names(df)[1] = "exit"

  # Discard unwanted columns.
  last_col_ix = match("Exits", headers)
  df = df[, seq_len(last_col_ix)]

  # Pivot longer.
  result = pivot_longer(
    df, -exit, names_to = "entry",
    values_transform = as.numeric, values_to = "average"
  )
  result$year = year
  result$month = month
  result
}


extract_metadata = function(paths) {
  # Try to get year and month from path.
  filenames = basename(paths)
  date6 = str_match(filenames, "(20[0-2][0-9])([01][0-9])?")
  year = as.numeric(date6[, 2])
  month = as.numeric(date6[, 3])

  MONTHS = strftime(make_date(month = 1:12), "%B")
  MONTHS = paste0(MONTHS, collapse = "|")
  month_name = str_extract(paths[is.na(month)], MONTHS)
  month[is.na(month)] = month(fast_strptime(month_name, "%m"))

  # Get names of first 4 sheets.
  sheets = map(paths, function(p) {
    sheets = excel_sheets(p)[1:4]
    names(sheets) = paste0("sheet", 1:4)
    sheets
  })
  sheets = bind_rows(sheets)

  result = tibble(
    year = year, month = month,
    sheets,
    path = paths
  )
  arrange(result, year, month)
}

count_days_in_month = function(x, days = 1:7) {
  total_days = days_in_month(x)
  dates = make_date(year(x), month(x), 1:total_days)
  day_numbers = as.integer(strftime(dates, "%u"))
  sum(day_numbers %in% days)
}


main = function() {
  ridership_urls = fetch_bart_ridership_urls()

  paths = download_files(ridership_urls$url, "data/BART")

  # Unzip the zip files.
  zip_paths = str_subset(paths, "zip$")
  unzip_dirs = map(zip_paths, function(zp) {
    paths = unzip(zp, exdir = dirname(zp), junkpaths = TRUE)
    message("Unzipped '", zp, "'")
    paths
  })

  # Update the paths.
  paths = str_subset(paths, "xlsx?$")
  paths = c(paths, list_c(unzip_dirs))

  # Get metadata about the files.
  meta = extract_metadata(paths)

  # Read the files.
  df = read_ridership(meta$path[1])
  df = read_ridership(meta$path[90])
  # 91-205


  dfs = pmap(meta[1:90, ], read_ridership)
  df = list_rbind(dfs)

  dfs2 = pmap(meta[91:205, ], read_ridership)
  df2 = list_rbind(dfs2)

  df = filter(df, !(exit %in% c("East Bay", "West Bay", "SF Downtown", "Total")))

  weekdays = map_dfr(unique(df$date), function(x) {
    data.frame(date = x, weekdays = count_days_in_month(x, 1:5))
  })

  df = left_join(df, weekdays, "date")
  df = mutate(df, count = average * weekdays)

  # Plot with ggplot2...
}
