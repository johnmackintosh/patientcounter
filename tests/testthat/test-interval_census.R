test_that(" more than one results argument throws error", {

  # more than one argument for `results`


  expect_that(interval_census(admit_extract,
                              identifier = "pat_id",
                              admit = "admit_date",
                              discharge = "discharge_date",
                              group_var = "location",
                              time_unit = "1 hour",
                              results = c("patient", "group", "total"),
                              uniques = TRUE),
              throws_error())


})


# df = NULL
test_that("missing df argument causes error", {
  expect_that(interval_census(df = NULL,
                              identifier = 'pat_id',
                              admit = "admit_date",
                              discharge = "discharge_date",
                              group_var = "location",
                              time_unit = "1 hour",
                              results = "patient",
                              uniques = TRUE),
              throws_error())


  # df not specified
  expect_that(interval_census(identifier = 'pat_id',
                              admit = "admit_date",
                              discharge = "discharge_date",
                              group_var = "location",
                              time_unit = "1 hour",
                              results = "patient",
                              uniques = TRUE),
              throws_error())


})


# identifier is null


test_that("missing identifier argument causes error", {
  expect_that(interval_census(df = beds,
                              identifier = NULL,
                              admit = "admit_date",
                              discharge = "discharge_date",
                              group_var = "location",
                              time_unit = "1 hour",
                              results = "patient",
                              uniques = TRUE),
              throws_error())

# missing
  expect_that(interval_census(df = beds,
                              admit = "admit_date",
                              discharge = "discharge_date",
                              group_var = "location",
                              time_unit = "1 hour",
                              results = "patient",
                              uniques = TRUE),
              throws_error())


})


# missing admit

test_that(" missing admit argument throws error", {

  # missing admit


  expect_that(interval_census(beds,
                              identifier = "patient",
                              discharge = "end_time",
                              group_var = "bed",
                              time_unit = "1 hour",
                              results =  "total",
                              uniques = TRUE),
              throws_error())


})


test_that(" missing discharge argument throws error", {

  # missing discharge


  expect_that(interval_census(beds,
                              identifier = "patient",
                              admit = "start_time",
                              group_var = "bed",
                              time_unit = "1 hour",
                              results =  "total",
                              uniques = TRUE),
              throws_error())


})



test_that("grouped results with no group_var throws error", {

  # missing group_var when grouped results required


  expect_that(interval_census(beds,
                              identifier = "patient",
                              admit = "start_time",
                              discharge = 'end_time',
                              group_var = NULL,
                              time_unit = "1 hour",
                              results =  "group",
                              uniques = FALSE),
              throws_error())


})


test_that("grouped results with uniques = TRUE throws error", {

  # uniques  = TRUE when grouped results requested


  expect_that(interval_census(beds,
                              identifier = "patient",
                              admit = "start_time",
                              discharge = 'end_time',
                              group_var = 'bed',
                              time_unit = "1 hour",
                              results =  "group",
                              uniques = TRUE),
              throws_error())


})




test_that("grouped result defined incorrectly throws error", {

  # uniques  = TRUE when grouped results requested


  expect_that(interval_census(beds,
                              identifier = "patient",
                              admit = "start_time",
                              discharge = 'end_time',
                              group_var = 'bed',
                              time_unit = "1 hour",
                              results =  "grp",
                              uniques = FALSE),
              throws_error())


})

