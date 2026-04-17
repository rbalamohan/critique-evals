UNSATISFACTORY
Reason: The JOIN condition incorrectly filters `o._FIVETRAN_DELETED = TRUE` instead of `FALSE`, which will exclude all valid organization records and return no results.