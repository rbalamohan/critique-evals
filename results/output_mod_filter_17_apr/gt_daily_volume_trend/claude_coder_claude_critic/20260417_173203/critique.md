UNSATISFACTORY
Reason: The organization filter uses `_FIVETRAN_DELETED = TRUE` instead of `= FALSE`, which would join to deleted records and return no valid results.