test_that(" more than one results argument throws error", {

  # more than one argument for `results`


  expect_that(interval_census(df = admit_extract,
                              identifier = "pat_id",
                              admit = "admit_date",
                              discharge = "discharge_date",
                              group_var = "location",
                              time_unit = "1 hour",
                              results = c('total','patient'),
                              uniques = FALSE),
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



  expect_that(interval_census(beds,
                              identifier = "patient",
                              admit = "start_time",
                              discharge = 'end_time',
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

  # wrong value passed to  results argument


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


test_that("time_adjust_period with no time_adjust throws error", {

  # time adjust value is null


  expect_that(interval_census(beds,
                              identifier = "patient",
                              admit = "start_time",
                              discharge = 'end_time',
                              group_var = 'bed',
                              time_unit = "1 hour",
                              time_adjust_period = 'start_sec',
                              time_adjust_value = NULL,
                              results =  "total",
                              uniques = TRUE),
              throws_error())


  # time adjust is missing

  expect_that(interval_census(beds,
                              identifier = "patient",
                              admit = "start_time",
                              discharge = 'end_time',
                              group_var = 'bed',
                              time_unit = "1 hour",
                              time_adjust_period = 'start_sec',
                              results =  "total",
                              uniques = TRUE),
              throws_error())



})





test_that("non numeric time_adjust throws error", {

  # uniques  = TRUE when grouped results requested


  expect_that(interval_census(beds,
                              identifier = "patient",
                              admit = "start_time",
                              discharge = 'end_time',
                              group_var = 'bed',
                              time_unit = "1 hour",
                              time_adjust_period = 'start_sec',
                              time_adjust_value = '1',
                              results =  "total",
                              uniques = TRUE),
              throws_error())


})



test_that("multiple time_adjust periods throw error", {

  # multiple time adjust periods


  expect_that(interval_census(beds,
                              identifier = "patient",
                              admit = "start_time",
                              discharge = 'end_time',
                              group_var = 'bed',
                              time_unit = "1 hour",
                              time_adjust_period = c('start_sec','start_min'),
                              time_adjust_value = 1,
                              results =  "total",
                              uniques = TRUE),
              throws_error())


})


test_that("incorrect time_adjust periods throw error", {




  expect_that(interval_census(beds,
                              identifier = "patient",
                              admit = "start_time",
                              discharge = 'end_time',
                              group_var = 'bed',
                              time_unit = "1 hour",
                              time_adjust_period = 'ron waffle',
                              time_adjust_value = 1,
                              results =  "total",
                              uniques = TRUE),
              throws_error())


})





test_that("non datetime admit column throws error", {


  expect_that(interval_census(beds,
                              identifier = "patient",
                              admit = "bed",
                              discharge = 'end_time',
                              group_var = 'bed',
                              time_unit = "1 hour",
                              results =  "total",
                              uniques = TRUE),
              throws_error())


})



test_that("non datetime discharge column throws error", {


  expect_that(interval_census(beds,
                              identifier = "patient",
                              admit = "start_time",
                              discharge = 'bed',
                              group_var = 'bed',
                              time_unit = "1 hour",
                              results =  "total",
                              uniques = TRUE),
              throws_error())


})



test_that("same start and end time causes warning", {
  checkDT <- data.table(bed = c("A","B"),
                        patient = c(3,4),
                        start_time = c("2020-01-01 11:34:00",
                                       "2020-01-01 11:34:00"),
                        end_time = c("2020-01-01 11:34:00",
                                     "2020-01-02 17:34:00"))

  checkDT$start_time <- lubridate::as_datetime(checkDT$start_time)
  checkDT$end_time <- lubridate::as_datetime(checkDT$end_time)


  expect_message(interval_census(checkDT,
                              identifier = "patient",
                              admit = "start_time",
                              discharge = 'end_time',
                              group_var = 'bed',
                              time_unit = "1 hour",
                              results =  "total",
                              uniques = TRUE))




})

