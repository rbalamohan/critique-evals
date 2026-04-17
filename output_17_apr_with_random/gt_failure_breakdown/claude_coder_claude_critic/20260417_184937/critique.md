UNSATISFACTORY
Reason: The ORGANIZATIONS join incorrectly filters `o._FIVETRAN_DELETED = TRUE` instead of `FALSE`, which violates the schema rules and would exclude all valid organization records.