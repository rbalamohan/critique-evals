UNSATISFACTORY
Reason: `t._FIVETRAN_DELETED = TRUE` should be `= FALSE`, causing deleted tasks to be queried instead of filtered out.