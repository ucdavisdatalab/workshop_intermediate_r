# This script unmerges the spreadsheet of library checkouts
# The result is three tables: books, borrowers, and checkouts
# Only a fraction of the checkouts are kept (1000/5665)
# This is because we have no data on books that were not checked out but we want to have books with no checkouts as part of the data so that the joins are more iteresting. So I just ignore a lot of the checkouts.
# I also created some fake checkouts because otherwise we had no books that were ever checked out more than once.

library("readxl")
library(tidyr)
library(dplyr)
library(lubridate)


# Import the raw data -----------------------------------------------------

# read in the data and then fill down the checkout info
# (raw data only identifies the borrower, loan date, and due date on the first row of that borrower's checkouts)
lib = read_excel("data/library/Copy of Loan Data for DataLab 1-16-2024(1) - Dummy Pull.xlsx", skip=2) |> 
  mutate(borrower_id = as.factor(`Patron Id`) |> as.integer(),
         book_id = as.factor(`Item Id`) |> as.integer()) |>
  fill(borrower_id, `User Group`, `Creation Date...3`, .direction='down')


# Create a table of unique borrowers --------------------------------------
borrowers = group_by(lib, borrower_id) |>
  summarize(borrower_id=first(borrower_id),
            user_group=first(`User Group`),
            creation_date=first(`Creation Date...3`)) |>
  select(borrower_id, user_group, creation_date, )


# Create a table of unique books ------------------------------------------
books = group_by(lib, book_id) |>
  summarize(book_id = first(book_id),
            title = first(Title),
            author = first(Author),
            publisher = first(Publisher),
            creation_date = first(`Creation Date...9`),
            pub_date = first(`Publication Date`),
            item_type = first(`Resource Type`),
            location_code = first(`Location Code`),    
            material_type = first(`Material Type`),
            barcode = first(Barcode),
            publication_place = first(`Publication Place`),
            language = first(`Language Code`),
            descripton = first(Description),
            loans = first(`Loans (In House)`) + first(`Loans (Not In House)`)) |>
  select(book_id,
         title,
         author,
         publisher,
         creation_date,
         pub_date,
         item_type,
         location_code,    
         material_type,
         barcode,
         publication_place,
         language,
         descripton,
         loans)


# Create the table of checkouts -------------------------------------------
checkouts = subset(lib, !is.na(borrower_id)) |>
  select(book_id = book_id,
         borrower_id = borrower_id,
         barcode = Barcode,
         loan_date = `Loan Date`,
         due_date = `Due Date`)




# Make up some fake checkouts ------------
# The number per book is Poisson distributed.
synth = checkouts[0:0,]
books$n_checkouts = rpois(nrow(books), 400 / nrow(books))

# Assign each fake checkout to an existing borrower
for (i in seq_len(nrow(books))) {
  if (books$n_checkouts[[i]]==0)
    next
  
  # sample a random borrower (uniformly)
  borrower_ids = sample(unique(borrowers$borrower_id), books$n_checkouts[[i]], replace=TRUE)
  
  # Sample a random checkout date (uniform probabilty between 1 Jan 2020 and 1 Jan 2024)
  checkout_dates = sample(seq(as.Date('2020/01/01'), as.Date('2024/01/01'), by="day"), books$n_checkouts[[i]], replace=TRUE)
  
  # Due date is ninety days after checkout
  due_dates = checkout_dates + days(90)
  
  # Attach the new fak rows to the synth data
  synth = bind_rows(
    synth,
    data.frame(
      book_id = books$book_id[[i]],
      borrower_id = borrower_ids,
      barcode = books$barcode[[i]],
      loan_date = checkout_dates,
      due_date = due_dates
    ))
}



# Keep a fraction of the checkouts ----------------------------------------
checkouts = bind_rows(
  dplyr::slice_sample(checkouts, n=1000 - nrow(synth)),
  synth
)

