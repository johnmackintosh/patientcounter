#' interval_census
#' A census of the number of patients , or moves/ transfers, by interval
#'
#'
#' @param df dataframe, tibble or data.table
#' @param identifier unique patient identifier
#' @param admit datetime of admission as POSIXct yyyy-mm-dd hh:mm:ss
#' @param discharge datetime of discharge as POSIXct yyyy-mm-dd hh:mm:ss
#' @param group_var unique character vector to identify location/clinician at each move
#' @param time_unit character string to denote time intervals to count by e.g. "1 hour", "15 mins"
#' @param time_adjust_period "start_sec","start_min","end_sec","end_min"
#' @param time_adjust_value integer to adjust the start / end of each period in minutes or seconds
#' @param results 'patient' returns one row per patient, groupvar and interval.
#'
#' 'group' provides an overall grouped count of patients by the specified time interval.
#'
#' 'total' returns the grand total of patients 'IN' by each unique time interval.
#' @param uniques TRUE will count patients once per interval, even if they have
#' more than one entry per interval, for example, due to move to another location.
#' Use this to get a *distinct* count of patients per interval
#'
#' FALSE will count each patient entry per interval.
#' If a patient moves during an interval there will be  at least two rows for
#' that patient for that interval.
#' This is useful if you want to count occupied beds,or a count of moves / transfers between departments
#'
#' @return data.table showing identifier, group variable , and count by relevant unit of time
#' Also includes the start / end of interval, plus the base date and base hour for
#' convenient interactive filtering of the results
#'
#' @import data.table
#' @importFrom lubridate floor_date ceiling_date seconds minutes date force_tz
#' @importFrom utils head tail
#' @export
#'
#' @examples
#' \donttest{
#'interval_census(admit_extract, indentifier ="pat_id", admit = "admit_date",
#'discharge = "discharge_date", group_var ="location",
#'time_unit = "1 hour", results = "patient",
#'uniques = TRUE)
#' }
#'
#'
interval_census <- function(df,
                            identifier,
                            admit,
                            discharge,
                            group_var = NULL,
                            time_unit = "1 hour",
                            time_adjust_period = NULL, #"start_sec","start_min","end_sec","end_min"
                            time_adjust_value = NULL,
                            results = c("patient", "group", "total"),
                            uniques = TRUE) {


  # global variables
  interval_beginning <- interval_end <- NULL
  join_end <- join_start <- NULL
  base_date <- base_hour <- NULL
  i.join_start <- i.join_end <- NULL


  if (missing(df)) {
    stop("Please provide a value for df")
  }

  if (missing(identifier)) {
    stop("Please provide a value for the patient identifier")
  }

  if (missing(admit)) {
    stop("Please provide a value for admit")
  }

  if (missing(discharge)) {
    stop("Please provide a value for discharge")
  }


  if (results == "group" & missing(group_var)) {
    stop("Please provide a value for the group_var column")
  }

  if (results == "grp" ) {
    stop('"Please check the value provided to the "results" argument.
         Do you mean "group"?"', call. = FALSE)
  }


  if (results == "group" & uniques) {
    stop("At group level, please change uniques to FALSE for accurate counts")
  }


  if (length(results) > 1)  {
    stop('"Too many values passed to "results" argument.
         Please set results to one of "patient", "group", or "total"',
         call. = FALSE)
  }


  if (!is.null(time_adjust_period) & length(time_adjust_period) > 1)  {
    stop('"Too many values passed to "time_adjust_period" argument.
         Please set time_adjust_period to one of "start_sec","start_min","end_sec" or "end_min"',
         call. = FALSE)
  }

  if (!is.null(time_adjust_period) & is.null(time_adjust_value))  {
    stop('"Please provide a value for the time_adjust argument"', call. = FALSE)
  }

  if (!is.null(time_adjust_period) & !is.numeric(time_adjust_value)) {
    stop("time_adjust_value should be numeric, not a string")
  }

  pat_DT <- copy(df)
  setDT(pat_DT)


  is.POSIXct <- function(x)
    inherits(x, "POSIXct")

  if (pat_DT[, !is.POSIXct(get(admit))]) {
    stop("The admit column must be POSIXct")
  }

  if (pat_DT[, !is.POSIXct(get(discharge))]) {
    stop("The discharge column must be POSIXct")
  }


  .confounding <- pat_DT[get(admit) == get(discharge),.N]
  if (.confounding > 0) {
    warning(paste0('There were ',.confounding,' ', 'records with identical admission and discharge date times.
                   These records have been ignored in the analysis'))
  }


  if (all(is.na(pat_DT[[discharge]]))) {
    stop("Please ensure at least one row has a discharge datetime")
  }



  # assign current max date to any admissions with no discharge date
  maxdate <- max(pat_DT[[discharge]], na.rm = TRUE)
  setnafill(pat_DT, type = "const", fill = maxdate, cols = discharge)


  pat_DT[["join_start"]] <- lubridate::floor_date(pat_DT[[admit]],unit = time_unit)
  pat_DT[["join_end"]] <- lubridate::ceiling_date(pat_DT[[discharge]],unit = time_unit)


  mindate <- min(pat_DT[["join_start"]],na.rm = TRUE)
  max_adm_date <- max(pat_DT[["join_start"]],na.rm = TRUE)

  max_dis_date <- max(pat_DT[["join_end"]],na.rm = TRUE)

  maxdate <- if (max_adm_date > max_dis_date) {
    curr_time <- lubridate::ceiling_date(Sys.time(),time_unit)
    if (lubridate::hour(curr_time) == 0) {
      curr_time <- curr_time + lubridate::hours(1)
    }
    #curr_time <- lubridate::ymd_hms(curr_time,tz = timezone)
    curr_time <- lubridate::ymd_hms(curr_time)
    maxdate <- curr_time
  } else {
    maxdate <- max_dis_date
  }

  if (max(pat_DT[["join_start"]],na.rm = TRUE) > max(pat_DT[["join_end"]],na.rm = TRUE)) {
    pat_DT[join_start > join_end,join_end := maxdate]
  }

  ts <- seq(mindate,maxdate, by = time_unit)

  ref <- data.table(join_start = head(ts, -1L), join_end = tail(ts, -1L),
                    key = c("join_start", "join_end"))

  # check for final adjustments


  if (!is.null(time_adjust_period)) {

    if (time_adjust_period == 'start_sec') {

      pat_DT[,join_start := join_start + lubridate::seconds(time_adjust_value)]
      ref[,join_start := join_start + lubridate::seconds(time_adjust_value)]


    } else if (time_adjust_period == 'start_min') {

      pat_DT[,join_start := join_start + lubridate::minutes(time_adjust_value)][]

      ref[,join_start := join_start + lubridate::minutes(time_adjust_value)][]

    } else if (time_adjust_period == 'end_sec') {

      pat_DT[,join_end := join_end - lubridate::seconds(time_adjust_value)][]
      ref[,join_end := join_end - lubridate::seconds(time_adjust_value)][]

    } else if (time_adjust_period == "end_min") {

      pat_DT[,join_end := join_end - lubridate::minutes(time_adjust_value)][]
      ref[,join_end := join_end - lubridate::minutes(time_adjust_value)][]
    }

  }

  out_of_zone <- ref[join_start > join_end,.N][]
  .bad_dates <- ref[join_start > join_end,]
  setnames(.bad_dates,
           old = c("join_start","join_end"),
           new = c("interval_beginning","interval_end"),
           skip_absent = TRUE)

  if (out_of_zone >= 1) {
    warning(paste0(out_of_zone,' ', "date(s) span(s) timezone changes and has / have been identified"))
    print(.bad_dates)
  }


  pat_DT <- pat_DT[join_start < join_end,][]
  ref <- ref[join_start < join_end,][]


  setkey(pat_DT,join_start,join_end)
  setkey(ref, join_start, join_end)


  pat_res <- foverlaps(ref, pat_DT, nomatch = 0L, type = "within", mult = "all")

  .oldnames <-  c("i.join_start","i.join_end")
  .newnames <-  c("interval_beginning","interval_end")
  setnames(pat_res,
           old = .oldnames,
           new = .newnames,
           skip_absent = TRUE)

  pat_res[, `:=`(base_date = data.table::as.IDate(interval_beginning),
                 base_hour = data.table::hour(interval_beginning))][]



  pat_res[, `:=`(base_date = data.table::as.IDate(interval_beginning),
                 base_hour = data.table::hour(interval_beginning))][]

  pat_res[, c('join_start','join_end') := NULL]


  pat_res <- if (uniques) {
    unique(pat_res, by = c(identifier, "interval_beginning"))
  }else {
    pat_res
  }

  pat_res <-  if (results == "patient") {
    existing <- names(df)
    newnames <- c(existing, "interval_beginning", "interval_end",
                  "base_date", "base_hour")
    pat_res[, .SD, .SDcols = newnames][]
    return(pat_res)

  } else if (results == "group") {

    pat_res <- pat_res[, .N, .(groupvar = get(group_var),
                               interval_beginning, interval_end, base_date, base_hour)][]
    setnames(pat_res, old = "groupvar", new = group_var, skip_absent = TRUE)
    return(pat_res)

  } else {

    pat_res <-  pat_res[, .N, .(interval_beginning,interval_end, base_date, base_hour)][]
    pat_res
  }
}
