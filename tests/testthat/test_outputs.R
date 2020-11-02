testthat::test_that(
  "`interval_census function` works with input and returns expected data.frame", {

    # basic function test

    checkDT <- data.table(bed = c("A","A"),
                          patient = c(3,3),
                          start_time = c("2020-01-01 11:34:00",
                                         "2020-01-01 11:34:00"),
                          end_time = c("2020-01-02 17:34:00",
                                       "2020-01-02 17:34:00"),
                          interval_beginning = c("2020-01-01","2020-01-02"),
                          interval_end = c("2020-01-02","2020-01-03"),
                          base_date = c('2020-01-01','2020-01-02'),
                          base_hour = c(0,0))

    checkDT$start_time <- lubridate::as_datetime(checkDT$start_time)
    checkDT$end_time <- lubridate::as_datetime(checkDT$end_time)
    checkDT$interval_beginning <- lubridate::as_datetime(checkDT$interval_beginning)
    checkDT$interval_end <- lubridate::as_datetime(checkDT$interval_end)
    checkDT$base_date <- data.table::as.IDate(checkDT$base_date)


    setkey(checkDT, interval_beginning, interval_end)

    test_res <- interval_census(beds[beds$patient == 3,],
                                identifier = 'patient',
                                admit = 'start_time',
                                discharge  = 'end_time',
                                time_unit = '1 day',
                                results = 'patient')


    testthat::expect_equivalent(test_res, checkDT)


  }
)


testthat::test_that(
  "`interval_census function` returns expected grouped data.frame", {

    # basic function test

    checkDT2 <- data.table(bed = c("A","A"),
                          interval_beginning = c("2020-01-01","2020-01-02"),
                          interval_end = c("2020-01-02","2020-01-03"),
                          N = c(1,1),
                          base_date = c('2020-01-01','2020-01-02'),
                          base_hour = c(0,0))

    checkDT2$interval_beginning <- lubridate::as_datetime(checkDT2$interval_beginning)
    checkDT2$interval_end <- lubridate::as_datetime(checkDT2$interval_end)
    checkDT2$base_date <- data.table::as.IDate(checkDT2$base_date)


    setkey(checkDT2, interval_beginning, interval_end)

    test_res2 <- interval_census(beds[beds$patient == 3,],
                                identifier = 'patient',
                                admit = 'start_time',
                                discharge  = 'end_time',
                                time_unit = '1 day',
                                group_var = 'bed',
                                results = 'group',
                                uniques = FALSE)


    testthat::expect_equivalent(test_res2, checkDT2)


  }
)



testthat::test_that(
  "`interval_census function` returns expected totals data.frame", {

    # basic function test

    checkDT3 <- data.table(interval_beginning = c("2020-01-01","2020-01-02"),
                           interval_end = c("2020-01-02","2020-01-03"),
                           N = c(1,1),
                           base_date = c('2020-01-01','2020-01-02'),
                           base_hour = c(0,0))

    checkDT3$interval_beginning <- lubridate::as_datetime(checkDT3$interval_beginning)
    checkDT3$interval_end <- lubridate::as_datetime(checkDT3$interval_end)
    checkDT3$base_date <- data.table::as.IDate(checkDT3$base_date)


    setkey(checkDT3, interval_beginning, interval_end)

    test_res3 <- interval_census(beds[beds$patient == 3,],
                                 identifier = 'patient',
                                 admit = 'start_time',
                                 discharge  = 'end_time',
                                 time_unit = '1 day',
                                 results = 'total')


    testthat::expect_equivalent(test_res3, checkDT3)


  }
)







# check time adjust values

test_that("`interval_census function` works with input and returns expected data.frame", {

  # start_min

  checkDT <- data.table(bed = c("A","A"),
                        patient = c(3,3),
                        start_time = c("2020-01-01 11:34:00",
                                       "2020-01-01 11:34:00"),
                        end_time = c("2020-01-02 17:34:00",
                                     "2020-01-02 17:34:00"),
                        interval_beginning = c("2020-01-01 00:01:00","2020-01-02 00:01:00"),
                        interval_end = c("2020-01-02","2020-01-03"),
                        base_date = c('2020-01-01','2020-01-02'),
                        base_hour = c(0,0))

  checkDT$start_time <- lubridate::as_datetime(checkDT$start_time)
  checkDT$end_time <- lubridate::as_datetime(checkDT$end_time)
  checkDT$interval_beginning <- lubridate::as_datetime(checkDT$interval_beginning)
  checkDT$interval_end <- lubridate::as_datetime(checkDT$interval_end)
  checkDT$base_date <- data.table::as.IDate(checkDT$base_date)

  setkey(checkDT, interval_beginning, interval_end)

  test_res <- interval_census(beds[beds$patient == 3,],
                              identifier = 'patient',
                              admit = 'start_time',
                              discharge  = 'end_time',
                              time_unit = '1 day',
                              time_adjust_period = 'start_min',
                              time_adjust_value = 1,
                              results = 'patient')


  expect_equivalent(test_res,checkDT)


}
)




test_that("`interval_census function` works with input and returns expected data.frame", {

  # end_min

  checkDT <- data.table(bed = c("A","A"),
                        patient = c(3,3),
                        start_time = c("2020-01-01 11:34:00",
                                       "2020-01-01 11:34:00"),
                        end_time = c("2020-01-02 17:34:00",
                                     "2020-01-02 17:34:00"),
                        interval_beginning = c("2020-01-01","2020-01-02"),
                        interval_end = c("2020-01-01 23:59:00","2020-01-02 23:59:00"),
                        base_date = c('2020-01-01','2020-01-02'),
                        base_hour = c(0,0))

  checkDT$start_time <- lubridate::as_datetime(checkDT$start_time)
  checkDT$end_time <- lubridate::as_datetime(checkDT$end_time)
  checkDT$interval_beginning <- lubridate::as_datetime(checkDT$interval_beginning)
  checkDT$interval_end <- lubridate::as_datetime(checkDT$interval_end)
  checkDT$base_date <- data.table::as.IDate(checkDT$base_date)

  setkey(checkDT, interval_beginning, interval_end)

  test_res <- interval_census(beds[beds$patient == 3,],
                              identifier = 'patient',
                              admit = 'start_time',
                              discharge  = 'end_time',
                              time_unit = '1 day',
                              time_adjust_period = 'end_min',
                              time_adjust_value = 1,
                              results = 'patient')


  expect_equivalent(test_res,checkDT)


}
)

test_that("`interval_census function` works with input and returns expected data.frame", {

  # end_sec

  checkDT <- data.table(bed = c("A","A"),
                        patient = c(3,3),
                        start_time = c("2020-01-01 11:34:00",
                                       "2020-01-01 11:34:00"),
                        end_time = c("2020-01-02 17:34:00",
                                     "2020-01-02 17:34:00"),
                        interval_beginning = c("2020-01-01","2020-01-02"),
                        interval_end = c("2020-01-01 23:59:58","2020-01-02 23:59:58"),
                        base_date = c('2020-01-01','2020-01-02'),
                        base_hour = c(0,0))

  checkDT$start_time <- lubridate::as_datetime(checkDT$start_time)
  checkDT$end_time <- lubridate::as_datetime(checkDT$end_time)
  checkDT$interval_beginning <- lubridate::as_datetime(checkDT$interval_beginning)
  checkDT$interval_end <- lubridate::as_datetime(checkDT$interval_end)
  checkDT$base_date <- data.table::as.IDate(checkDT$base_date)

  setkey(checkDT, interval_beginning, interval_end)

  test_res <- interval_census(beds[beds$patient == 3,],
                              identifier = 'patient',
                              admit = 'start_time',
                              discharge  = 'end_time',
                              time_unit = '1 day',
                              time_adjust_period = 'end_sec',
                              time_adjust_value = 2,
                              results = 'patient')


  expect_equivalent(test_res,checkDT)


}
)


test_that("`interval_census function` works with input and returns expected data.frame", {

  # start_sec

  checkDT <- data.table(bed = c("A","A"),
                        patient = c(3,3),
                        start_time = c("2020-01-01 11:34:00",
                                       "2020-01-01 11:34:00"),
                        end_time = c("2020-01-02 17:34:00",
                                     "2020-01-02 17:34:00"),
                        interval_beginning = c("2020-01-01 00:00:05","2020-01-02 00:00:05"),
                        interval_end = c("2020-01-02","2020-01-03"),
                        base_date = c('2020-01-01','2020-01-02'),
                        base_hour = c(0,0))

  checkDT$start_time <- lubridate::as_datetime(checkDT$start_time)
  checkDT$end_time <- lubridate::as_datetime(checkDT$end_time)
  checkDT$interval_beginning <- lubridate::as_datetime(checkDT$interval_beginning)
  checkDT$interval_end <- lubridate::as_datetime(checkDT$interval_end)
  checkDT$base_date <- data.table::as.IDate(checkDT$base_date)

  setkey(checkDT, interval_beginning, interval_end)

  test_res <- interval_census(beds[beds$patient == 3,],
                              identifier = 'patient',
                              admit = 'start_time',
                              discharge  = 'end_time',
                              time_unit = '1 day',
                              time_adjust_period = 'start_sec',
                              time_adjust_value = 5,
                              results = 'patient')


  expect_equivalent(test_res,checkDT)


}
)




test_that("`end_date is not NULL / NA` ", {



  test_na <- interval_census(beds[beds$patient == 10,],
                             identifier = 'patient',
                             admit = 'start_time',
                             discharge  = 'end_time',
                             time_unit = '1 day',
                             results = 'patient')


  expect_false(anyNA(test_na$end_time))


}
)

