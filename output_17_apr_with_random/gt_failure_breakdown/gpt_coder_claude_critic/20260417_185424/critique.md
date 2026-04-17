UNSATISFACTORY
Reason: The `acme_org` CTE filters `_FIVETRAN_DELETED = TRUE` instead of `FALSE`, which will return deleted organizations and likely produce no or incorrect results.