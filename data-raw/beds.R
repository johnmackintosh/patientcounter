beds <-
  structure(
    list(
      bed = c("A", "A", "A", "A", "B", "B", "B", "B",
              "C", "D"),
      patient = c(
        "Person1",
        "Person5",
        "Person9",
        "Person8",
        "Person2",
        "Person6",
        "Person7",
        "Person10",
        "Person3",
        "Person4"
      ),
      start_time = structure(
        c(
          1577867640,
          1577872500,
          1577874840,
          1577898000,
          1577868300,
          1577891580,
          1577911308,
          1577916780,
          1577869500,
          1577871000
        ),
        class = c("POSIXct", "POSIXt"),
        tzone = "UTC"
      ),
      end_time = structure(
        c(
          1577871240,
          1577873724,
          1577982840,
          1578006000,
          1577886300,
          1577910444,
          1577915772,
          1577922180,
          1577871300,
          NA
        ),
        class = c("POSIXct", "POSIXt"),
        tzone = "UTC"
      )
    ),
    row.names = c(NA,
                  -10L),
    class = c("tbl_df", "tbl", "data.frame")
  )
