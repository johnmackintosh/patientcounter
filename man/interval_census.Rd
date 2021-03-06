% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/interval_census.R
\name{interval_census}
\alias{interval_census}
\title{Count the number of patients by interval}
\usage{
interval_census(
  df,
  identifier,
  admit,
  discharge,
  group_var = NULL,
  time_unit = "1 hour",
  time_adjust_period = NULL,
  time_adjust_value = NULL,
  results = c("patient", "group", "total"),
  uniques = TRUE
)
}
\arguments{
\item{df}{dataframe, tibble or data.table.}

\item{identifier}{Unique patient identifier.}

\item{admit}{Datetime of admission as POSIXct.}

\item{discharge}{Datetime of discharge as POSIXct.}

\item{group_var}{Optional unique character vector to identify specific patient
location or responsible clinician at each interval, or at time of a change in
location / responsible clinician during the interval.}

\item{time_unit}{Character string to denote time intervals to count by e.g.
"1 hour", "15 mins".}

\item{time_adjust_period}{Optional argument which allows
the user to obtain a snapshot at a specific time of day by making slight
adjustments  to the specified interval.
Possible values are "start_sec","start_min","end_sec", or "end_min".
For example, you may specify hourly intervals, but adjust these
to 1 minute past the hour with "start_min", or several seconds before the
end with "end_sec".}

\item{time_adjust_value}{Optional. An integer to adjust the startor  end of
each period in minutes or seconds, depending on the  chosen
time_adjust_period (if specified).}

\item{results}{A character string specifying the granularity of the results.

'patient' returns one row per patient, group_var and interval. The results
can be input to external tools for further analysis or visualisation.

'group' provides an overall grouped count of patients by the specified time
interval.

'total' returns the grand total of patients  by each unique time interval.}

\item{uniques}{Logical. Specifies how to deal with patients who move during
an interval, and subsequently have two or more records per interval.
Set "uniques" to TRUE to get a distinct count of patients per interval.
To be clear, TRUE will count patients only once per interval.

Setting "uniques" to  FALSE will count each patient entry per interval.
If a patient moves during an interval then at least two rows will be returned
for that patient for that particular interval.
This is useful if you want to count occupied beds, or track moves  or
transfers between departments.

In general, if you use a grouping variable, set "uniques" to FALSE.}
}
\value{
data.table showing the patient identifier, the specified group
variable , and  the count by  the relevant unit of time.
Also included are the start and end of the interval, plus the date and
base hour for convenient interactive filtering of the results.
}
\description{
Counts the number of patients in each location, by the specified interval,
for the duration of the patient admission. Results can be returned as a
grand totals, grouped totals, or individual patient level per interval.
}
\examples{
\donttest{
interval_census(beds, identifier ="patient", admit = "start_time",
discharge = "end_time", time_unit = "1 hour", results = "total")

interval_census(beds, identifier ="patient", admit = "start_time",
discharge = "end_time", time_unit = "1 hour", results = "patient")

interval_census(beds, identifier ="patient", admit = "start_time",
discharge = "end_time", group_var = "bed",
time_unit = "1 hour", results = "group", uniques = FALSE)

}


}
