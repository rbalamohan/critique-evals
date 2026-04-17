UNSATISFACTORY
Reason: `o._FIVETRAN_DELETED = TRUE` should be `= FALSE`, which would incorrectly exclude all non-deleted organizations and return no results.