# patientcounter <img src="man/figures/logo.png" width="160px" align="right" />

[![Project Status: WIP – Initial development is in progress, but there has not yet been a stable, usable release suitable for the public.](https://www.repostatus.org/badges/latest/wip.svg)](https://www.repostatus.org/#wip)

[![Build Status](https://travis-ci.com/johnmackintosh/patientcounter.svg?branch=master)](https://travis-ci.com/johnmackintosh/patientcounter)


[![AppVeyor build status](https://ci.appveyor.com/api/projects/status/github/johnmackintosh/patientcounter?branch=master&svg=true)](https://ci.appveyor.com/project/johnmackintosh/patientcounter)

[![codecov](https://codecov.io/gh/johnmackintosh/patientcounter/branch/master/graph/badge.svg)](https://codecov.io/gh/johnmackintosh/patientcounter)



How many patients were in the hospital at 10 AM yesterday?  
How many were in during each 15 minute spell between 2pm and 6pm?  
How many were in during the last week, by hour?


This package aims to make answering these questions easier and quicker.

No SQL? No problem!

If you have time in, time out, a unique patient identifier, and optionally, a grouping variable to track moves between departments, this package will tell you how many patients were 'IN' at any time.


## Example

```r
patient_count <- interval_census(df = my_df, 
identifier = 'patient_code_number',
admit = 'admission_date', 
discharge = 'discharge_date', 
group_var = 'location_id', 
time_unit = '1 hour', 
results = "total", 
uniques = TRUE)

```


## Installation

The package is not on CRAN yet, so install from github with the 'remotes' package

```r
install.packages("remotes") # if not already installed
remotes::install_github("johnmackintosh/patientcounter")

```


## General Help

- You must 'quote' your variables, for the time being at least..  

## Results
- Set results to 'patient' for 1 row per patient per interval for each interval in the patient stay. 
- Set results to 'group' to get a count per group per interval.  
Remember this will also be influenced by the 'uniques' argument.  
- Set results to 'total' for a summary of the data set - interval, base_hour and count.  


## Uniques
- To count patients, leave 'uniques' at the default value of 'TRUE'.  
- To count patient moves between locations during intervals, set uniques to 'FALSE'. 
This will ensure patients who occupy beds in different locations during each interval are accounted for.


## Timezones

- Everything is easier if you use "UTC" by default. 
You can attempt to coerce the final results yourself using lubridate::force_tz()  

To find your system timezone:

```r
Sys.timezone()
```

## Time Unit


See ```r'? seq.POSIXt'``` for valid values

E.G. '1 hour', '15 mins', '30 mins'


## Time Adjust

Want to count those in between 10:01 to 11:00? 
You can do that using 'time_adjust_period' - set it to 'start_min' and then set
'time_adjust_interval' to 1.


10:00 to 10:59?  
Yes, that's possible as well - set 'time_adjust_period' to 'end_min' and set 
'time_adjust_interval' as before. You can set these periods to any value, as long
as it makes sense in relation to your chosen time_unit.



