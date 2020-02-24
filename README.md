# patientcounter

[![Project Status: WIP – Initial development is in progress, but there has not yet been a stable, usable release suitable for the public.](https://www.repostatus.org/badges/latest/wip.svg)](https://www.repostatus.org/#wip)

[![Build Status](https://travis-ci.com/johnmackintosh/patientcounter.svg?branch=master)](https://travis-ci.com/johnmackintosh/patientcounter)

How many patients were in the hospital at 10 AM yesterday?  
How many were in during each 15 minute spell between 2pm and 6pm?  
How many were in during the last week, by hour?

How many patients were admitted by hour? And discharged? What was the net value? By Half hour?


This package aims to make answering these questions easier and quicker.  

No SQL required! 


## Example

```r
patient count <- interval_census(df = my_df, 
identifier = 'patient_code_number',
admit = 'admission_date', 
discharge = 'discharge_date', 
group_var = 'session_id', 
time_unit = '1 hour', 
results = "total", 
uniques = TRUE,
timezone = "Europe/London")

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
This will result in double counting of some patients who occupy beds in different locations during each interval


## Timezone

- To ensure the results match your current locale, you must specify your timezone.  
In the UK this will be "Europe/London"  

To find your system timezone:

```r
Sys.timezone()
```

## Time Unit


See ```r'? seq.POSIXt'``` for valid values

E.G. '1 hour', '15 mins'


