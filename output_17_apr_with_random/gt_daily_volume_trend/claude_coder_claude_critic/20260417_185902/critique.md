UNSATISFACTORY
Reason: `o._FIVETRAN_DELETED = TRUE` should be `= FALSE`, which causes the query to join against deleted organization records instead of active ones.