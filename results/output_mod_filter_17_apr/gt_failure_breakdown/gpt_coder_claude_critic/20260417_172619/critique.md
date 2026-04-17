UNSATISFACTORY
Reason: The `acme_org` CTE filters `_FIVETRAN_DELETED = TRUE` instead of `FALSE`, so it will return only deleted organizations and produce incorrect or empty results.