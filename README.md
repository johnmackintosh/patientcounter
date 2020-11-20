
<!-- README.md is generated from README.Rmd. Please edit that file -->

<!-- badges: start -->

# patientcounter <img src="man/figures/logo.png" width="160px" align="right" />

[![Project Status: Active – The project has reached a stable, usable
state and is being actively
developed.](https://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active)

[![Build
Status](https://travis-ci.com/johnmackintosh/patientcounter.svg?branch=master)](https://travis-ci.com/johnmackintosh/patientcounter)

[![AppVeyor build
status](https://ci.appveyor.com/api/projects/status/github/johnmackintosh/patientcounter?branch=master&svg=true)](https://ci.appveyor.com/project/johnmackintosh/patientcounter)

[![codecov](https://codecov.io/gh/johnmackintosh/patientcounter/branch/master/graph/badge.svg)](https://codecov.io/gh/johnmackintosh/patientcounter)

[![](https://img.shields.io/badge/devel%20version-0.1.0-blue.svg)](https://github.com/johnmackintosh/patientcounter)

[![](https://img.shields.io/github/last-commit/johnmackintosh/patientcounter.svg)](https://github.com/johnmackintosh/patientcounter/commits/master)

[![R build
status](https://github.com/johnmackintosh/patientcounter/workflows/R-CMD-check/badge.svg)](https://github.com/johnmackintosh/patientcounter/actions)
<!-- badges: end -->

How many patients were in the hospital at 10 AM yesterday?  
How many were in during each 15 minute spell between 2pm and 6pm?  
How many were in during the last week, by hour?

This package aims to make answering these questions easier and quicker.

No SQL? No problem\!

If you have time in, time out, a unique patient identifier, and
optionally, a grouping variable to track moves between departments, this
package will tell you how many patients were ‘IN’ at any time, at
whatever granularity you need.

## Installation

patientcounter is not on [CRAN](https://CRAN.R-project.org) yet, so
install the development version from [GitHub](https://github.com/) with:

``` r
# install.packages("remotes") # if not already installed
remotes::install_github("johnmackintosh/patientcounter")
```

## Example

Obtain data for each individual patient, by hour, for each hour of their
stay.  
Note we are restricting the outputs to keep this readable

``` r
library(patientcounter)
patient_count <- interval_census(beds, 
identifier = 'patient',
admit = 'start_time', 
discharge = 'end_time', 
group_var = 'bed', 
time_unit = '1 hour', 
results = "patient", 
uniques = TRUE)

head(patient_count)
#>    bed patient          start_time            end_time  interval_beginning
#> 1:   A       1 2020-01-01 09:34:00 2020-01-01 10:34:00 2020-01-01 09:00:00
#> 2:   B       5 2020-01-01 09:45:00 2020-01-01 14:45:00 2020-01-01 09:00:00
#> 3:   A       1 2020-01-01 09:34:00 2020-01-01 10:34:00 2020-01-01 10:00:00
#> 4:   B       5 2020-01-01 09:45:00 2020-01-01 14:45:00 2020-01-01 10:00:00
#> 5:   C       9 2020-01-01 10:05:00 2020-01-01 10:35:00 2020-01-01 10:00:00
#> 6:   A       2 2020-01-01 10:55:00 2020-01-01 11:15:24 2020-01-01 10:00:00
#>           interval_end  base_date base_hour
#> 1: 2020-01-01 10:00:00 2020-01-01         9
#> 2: 2020-01-01 10:00:00 2020-01-01         9
#> 3: 2020-01-01 11:00:00 2020-01-01        10
#> 4: 2020-01-01 11:00:00 2020-01-01        10
#> 5: 2020-01-01 11:00:00 2020-01-01        10
#> 6: 2020-01-01 11:00:00 2020-01-01        10
```

To obtain summary data for every hour, for all combined patient stays:

``` r
library(patientcounter)
patient_count_hour <- interval_census(beds, 
identifier = 'patient',
admit = 'start_time', 
discharge = 'end_time', 
group_var = 'bed', 
time_unit = '1 hour', 
results = "total", 
uniques = TRUE)

head(patient_count_hour)
#>     interval_beginning        interval_end  base_date base_hour N
#> 1: 2020-01-01 09:00:00 2020-01-01 10:00:00 2020-01-01         9 2
#> 2: 2020-01-01 10:00:00 2020-01-01 11:00:00 2020-01-01        10 5
#> 3: 2020-01-01 11:00:00 2020-01-01 12:00:00 2020-01-01        11 4
#> 4: 2020-01-01 12:00:00 2020-01-01 13:00:00 2020-01-01        12 3
#> 5: 2020-01-01 13:00:00 2020-01-01 14:00:00 2020-01-01        13 3
#> 6: 2020-01-01 14:00:00 2020-01-01 15:00:00 2020-01-01        14 3
```

Note that you also receive the base date and base hour for each interval
to enable easier filtering of the results.

## Grouped values

This example shows grouping results by bed and hour.  
The first ten rows of the resulting grouped values are shown

``` r
library(patientcounter)
grouped <- interval_census(beds, 
identifier = 'patient',
admit = 'start_time', 
discharge = 'end_time', 
group_var = 'bed', 
time_unit = '1 hour',
results = "group", 
uniques = FALSE)

head(grouped[bed %chin% c('A', 'B')],10)
#>     bed  interval_beginning        interval_end  base_date base_hour N
#>  1:   A 2020-01-01 09:00:00 2020-01-01 10:00:00 2020-01-01         9 1
#>  2:   B 2020-01-01 09:00:00 2020-01-01 10:00:00 2020-01-01         9 1
#>  3:   A 2020-01-01 10:00:00 2020-01-01 11:00:00 2020-01-01        10 2
#>  4:   B 2020-01-01 10:00:00 2020-01-01 11:00:00 2020-01-01        10 1
#>  5:   B 2020-01-01 11:00:00 2020-01-01 12:00:00 2020-01-01        11 1
#>  6:   A 2020-01-01 11:00:00 2020-01-01 12:00:00 2020-01-01        11 2
#>  7:   B 2020-01-01 12:00:00 2020-01-01 13:00:00 2020-01-01        12 1
#>  8:   A 2020-01-01 12:00:00 2020-01-01 13:00:00 2020-01-01        12 1
#>  9:   B 2020-01-01 13:00:00 2020-01-01 14:00:00 2020-01-01        13 1
#> 10:   A 2020-01-01 13:00:00 2020-01-01 14:00:00 2020-01-01        13 1
```

## General Help

  - You must ‘quote’ your variables, for the time being at least..

## Results

  - Set results to ‘patient’ for 1 row per patient per interval for each
    interval in the patient stay.
  - Set results to ‘group’ to get a count per group per interval.  
    Remember this will also be influenced by the ‘uniques’ argument -
    set it to FALSE to ensure each move in each location is counted.  
  - Set results to ‘total’ for a summary of the data set - interval,
    base\_hour and count.

## Tracking moves within the same interval with ‘uniques’

  - To count individual patients ONLY, leave ‘uniques’ at the default
    value of ‘TRUE’.  
  - To count patient moves between locations during intervals, set
    uniques to ‘FALSE’. Patients who occupy beds in different locations
    during each interval are accounted for in each location. They will
    be counted at least twice during an interval - both in their initial
    location and their new location following a move.

## Timezones

  - Everything is easier if you use “UTC” by default. You can attempt to
    coerce the final results yourself using lubridate::force\_tz()

To find your system timezone:

``` r
Sys.timezone()
```

## Time Unit

See ? seq.POSIXt for valid values

E.G. ‘1 hour’, ‘15 mins’, ‘30 mins’

## Time Adjust

Want to count those in between 10:01 to 11:00? You can do that using
‘time\_adjust\_period’ - set it to ‘start\_min’ and then set
‘time\_adjust\_interval’ to 1.

10:00 to 10:59?  
Yes, that’s possible as well - set ‘time\_adjust\_period’ to ‘end\_min’
and set ‘time\_adjust\_interval’ as before. You can set these periods to
any value, as long as it makes sense in relation to your chosen
time\_unit.

Here we adjust the start\_time by 5 minutes

``` r
library(patientcounter)
patient_count_time_adjust <- interval_census(beds, 
identifier = 'patient',
admit = 'start_time', 
discharge = 'end_time', 
group_var = 'bed', 
time_unit = '1 hour', 
time_adjust_period = 'start_min',
time_adjust_value = 5,
results = "total", 
uniques = TRUE)

head(patient_count_time_adjust)
#>     interval_beginning        interval_end  base_date base_hour N
#> 1: 2020-01-01 09:05:00 2020-01-01 10:00:00 2020-01-01         9 2
#> 2: 2020-01-01 10:05:00 2020-01-01 11:00:00 2020-01-01        10 5
#> 3: 2020-01-01 11:05:00 2020-01-01 12:00:00 2020-01-01        11 4
#> 4: 2020-01-01 12:05:00 2020-01-01 13:00:00 2020-01-01        12 3
#> 5: 2020-01-01 13:05:00 2020-01-01 14:00:00 2020-01-01        13 3
#> 6: 2020-01-01 14:05:00 2020-01-01 15:00:00 2020-01-01        14 3
```

Valid values for time\_adjust\_period are ‘start\_min’, ‘start\_sec’,
‘end\_min’ and ‘end\_sec’
