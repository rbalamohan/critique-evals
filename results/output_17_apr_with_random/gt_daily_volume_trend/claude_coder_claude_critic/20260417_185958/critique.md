UNSATISFACTORY
Reason: `o._FIVETRAN_DELETED = TRUE` should be `= FALSE`, which would incorrectly include only deleted organizations and exclude all valid ones.