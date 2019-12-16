#' base_counter
#'
#' @param df dataframe, tibble or data.table
#' @param identifier unique patient identifier
#' @param admit_datetime datetime of admission as POSIXct yyyy-mm-dd
#' @param discharge_datetime datetime of discharge as POSIXct yyyy-mm-dd
#' @param group_var unique character vector to identify location/clinician at each move
#' @param time_unit character string to denote time intervals to count by e.g. "1 hour", "15 mins"
#' @param summarise FALSE returns one row per patient and groupvar for each unit of time they 'IN'
#' TRUE provides an overall grouped count of patients by the specified time unit
#'
#' @return data.table showing identifier, group_var and count by relevant unit of time
#' @export
#'
#'
#'
in_time_counter <- function(df,
                            identifier,
                            admit_datetime,
                            discharge_datetime,
                            group_var,
                            time_unit = "1 hour",
                            summarise = FALSE) {

  ##### check all arguments provided #####

  if (missing(df)) {stop("Please provide a value for df")}

  if (missing(identifier)) {stop("Please provide a value for the patient identifier")}

  if (missing(admit_datetime)) {stop("Please provide a value for admit_datetime")}

  if (missing(discharge_datetime)) {stop("Please provide a value for discharge_datetime")}

  if (missing(group_var)) {stop("Please provide a value for the group_var column")}

  #if (missing(time_unit)) {stop("Please provide a value for time_unit. See '? seq.POSIXt' for valid values")}

  ##### end of check #####

  DT <- setDT(df)


  is.POSIXct <- function(x) inherits(x, "POSIXct")

  if (DT[, !is.POSIXct(get(admit_datetime))]) {
    stop("The admit_datetime column must be POSIXct")
  }

  if (DT[, !is.POSIXct(get(discharge_datetime))]) {
    stop("The discharge_datetime column must be POSIXct")
  }

  maxdate <- DT[, max(get(discharge_datetime), na.rm = TRUE)]

  setnafill(DT, type = "const", fill = maxdate, cols = discharge_datetime)

  DT[, join_start := lubridate::floor_date(get(admit_datetime), unit = time_unit)]
  DT[, join_end := lubridate::ceiling_date(get(discharge_datetime), unit = time_unit)]


  pat_res <- DT[, .(in_time = seq(join_start, join_end, by = time_unit)),
                by = .(identifier = get(identifier),
                       group_var = get(group_var),
                       ID = seq_len(nrow(DT)))][order(in_time)]


  if (!summarise) {
    return(pat_res)
  }
  res <- pat_res[, .N, .(in_time)]
}
