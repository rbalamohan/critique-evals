UNSATISFACTORY
Reason: `o._FIVETRAN_DELETED = TRUE` should be `= FALSE`, which causes the query to return no results by filtering out all active organizations.