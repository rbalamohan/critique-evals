UNSATISFACTORY
Reason: The ORGANIZATIONS join condition incorrectly filters `o._FIVETRAN_DELETED = TRUE` instead of `FALSE`, which would exclude all valid organization records.