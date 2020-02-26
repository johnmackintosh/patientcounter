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
#' @param results patient returns one row per patient, groupvar and interval.
#' group provides an overall grouped count of patients by the specified time interval.
#' total returns the grand total of patients 'IN' by each unique time interval.
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
#' @importFrom lubridate floor_date ceiling_date seconds date force_tz
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
                            results = c("patient", "group", "total"),
                            uniques = TRUE) {
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

  if (results == "group" & uniques) {
    stop("At group level, please change uniques to FALSE for accurate counts")
  }


  if (results == c("patient", "group", "total")) {
    stop('Please select ONE option for results')
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

  setkey(pat_DT,join_start,join_end)
  setkey(ref, join_start, join_end)


  pat_res <- foverlaps(ref, pat_DT, nomatch = 0L, type = "within", mult = "all")

  pat_res[,`:=`(interval_beginning = i.join_start,
                interval_end = i.join_end,
                base_date = lubridate::date(i.join_start),
                base_hour = lubridate::hour(i.join_start))][]



 pat_res <- if (uniques) {
   unique(pat_res, by = c(identifier,'i.join_start'))
 } else {
   pat_res
 }

 if (results == 'patient') {
   existing <- names(df)
   newnames <- c(existing,'interval_beginning','interval_end',
                 'base_date','base_hour')

   pat_res[,.SD,.SDcols = newnames]

  } else if (results == 'group') {
    grp_pat_res <- pat_res[, .N, .(groupvar = get(group_var),interval_beginning, base_date,base_hour)]
    setnames(grp_pat_res, old = 'groupvar',new = group_var,skip_absent = TRUE)
    grp_pat_res

  } else {
    pat_res[, .N, .(interval_beginning, base_date, base_hour)]
  }
}
