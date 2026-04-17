UNSATISFACTORY
Reason: The join condition uses `o._FIVETRAN_DELETED = TRUE` instead of `FALSE`, which will exclude all active organizations and return no results.