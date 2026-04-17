UNSATISFACTORY
Reason: The `acme_org` CTE filters `_FIVETRAN_DELETED = TRUE` instead of `FALSE`, so it will return deleted organizations rather than active ones.