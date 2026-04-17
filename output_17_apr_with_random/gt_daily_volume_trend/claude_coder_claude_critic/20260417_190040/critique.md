UNSATISFACTORY
Reason: The organization join condition incorrectly filters `o._FIVETRAN_DELETED = TRUE` instead of `FALSE`, which would exclude all valid organizations and return no results.