UNSATISFACTORY
Reason: `o._FIVETRAN_DELETED = TRUE` should be `= FALSE`, which would cause the query to return no results by filtering out all valid organizations.