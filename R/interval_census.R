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
#' @param uniques TRUE will only count patients once if they have more than one move
#' during an interval. Use this to get a distinct count of patients per interval
#'
#' FALSE will count each patient move, so if a patient moves once during an interval there
#' will be two rows for tha patient. This is useful if you want to count occupied beds,
#' or a count of moves / transfers between departments
#'
#' @param timezone Your system timezone
#'
#' @return data.table showing identifier, group_var and count by relevant unit of time
#' @import data.table
#' @importFrom lubridate floor_date ceiling_date seconds date force_tz
#' @importFrom utils head tail
#' @export
#'
#'
#'
interval_census <- function(df,
                            identifier,
                            admit,
                            discharge,
                            group_var = NULL,
                            time_unit = "1 hour",
                            results = c("patient", "group", "total"),
                            uniques = TRUE,
                            timezone = Sys.timezone()) {
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


  pat_DT <- copy(df)
  setDT(pat_DT)

  #pat_DT <- setnames(pat_DT, old = c(group_var), new = c("grp"),skip_absent = TRUE)



  is.POSIXct <- function(x)
    inherits(x, "POSIXct")

  if (pat_DT[, !is.POSIXct(get(admit))]) {
    stop("The admit column must be POSIXct")
  }

  if (pat_DT[, !is.POSIXct(get(discharge))]) {
    stop("The discharge column must be POSIXct")
  }



  if (!is.null(timezone)) {
    pat_DT[[admit]] <- lubridate::force_tz(pat_DT[[admit]],  tzone = timezone)
  } else {
    pat_DT[[admit]] <- lubridate::force_tz(pat_DT[[admit]], tzone = 'UTC')
  }

  if (!is.null(timezone)) {
    pat_DT[[discharge]] <- lubridate::force_tz(pat_DT[[discharge]],  tzone = timezone)
  } else {
    pat_DT[[discharge]] <- lubridate::force_tz(pat_DT[[discharge]], tzone = 'UTC')
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
  curr_time <- lubridate::ymd_hms(curr_time,tz = timezone)
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

  pat_res[,`:=`(base_date = lubridate::date(i.join_start),
                interval_beginning = i.join_start,
                 base_hour = lubridate::hour(i.join_start))][]



 pat_res <- if (uniques) {
   unique(pat_res, by = c(identifier,'i.join_start'))
 } else {
   pat_res
 }



 if (results == 'patient') {
   existing <- names(df)
   newnames <- c(existing,'interval_beginning','base_hour')

   pat_res[,.SD,.SDcols = newnames]

  } else if (results == 'group') {
    grp_pat_res <- pat_res[, .N, .(groupvar = get(group_var),interval_beginning, base_date,base_hour)]
    setnames(grp_pat_res, old = 'groupvar',new = group_var,skip_absent = TRUE)
    grp_pat_res

  } else {
    pat_res[, .N, .(interval_beginning, base_date, base_hour)]
  }
}
