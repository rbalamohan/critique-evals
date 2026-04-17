UNSATISFACTORY
Reason: The `acme_org` CTE filters `_FIVETRAN_DELETED = TRUE` instead of `FALSE`, which means it will return deleted organizations and likely yield no valid results.