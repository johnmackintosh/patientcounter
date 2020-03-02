test_that(" more than one results argument throws error", {

  # more than one argument for `results`


  expect_that(interval_census(admit_extract,
                              indentifier = "pat_id",
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
                              admit = "admit_date",
                              discharge = "discharge_date",
                              group_var = "location",
                              time_unit = "1 hour",
                              results = "patient",
                              uniques = TRUE),
              throws_error())


  # df not specified
  expect_that(interval_census(admit = "admit_date",
                              discharge = "discharge_date",
                              group_var = "location",
                              time_unit = "1 hour",
                              results = "patient",
                              uniques = TRUE),
              throws_error())


})
