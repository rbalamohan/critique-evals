UNSATISFACTORY
Reason: The join condition incorrectly filters `o._FIVETRAN_DELETED = TRUE` instead of `FALSE`, which will exclude all valid organizations and return no results.