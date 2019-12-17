# patientcounter
How many patients were in the hospital at 10 AM yesterday?  
How many were in during each 15 minute spell between 2pm and 6pm?  
How many were in during the last week, by hour?

How many patients were admitted by hour? And discharged? What was the net value? By Half hour?


This package aims to make answering these questions easier and quicker.

At a minumum, you must provide a dataframe / tibble or data.table containing : 

- identifier - a unique patient identifier
- admit_datetime - time of admission as POSIXct 
- discharge_datetime - time of discharge as POSCIXct
- group_var -  a character vector that denotes the unique location for the patient during the current admission. 
Patients can move more than once during an interval, therefore we need to know each unique location for each move. 
- time_unit character string to denote time intervals to count by e.g. "1 hour", "15 mins"


