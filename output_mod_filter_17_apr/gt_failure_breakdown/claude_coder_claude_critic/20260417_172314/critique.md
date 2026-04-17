UNSATISFACTORY
Reason: The Organizations join incorrectly filters `o._FIVETRAN_DELETED = TRUE` instead of `FALSE`, which would exclude all valid (non-deleted) organizations and return no results.