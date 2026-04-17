UNSATISFACTORY
Reason: The `acme_orgs` CTE filters `_FIVETRAN_DELETED = TRUE` instead of `FALSE`, which would return deleted organizations and likely yield no valid results.