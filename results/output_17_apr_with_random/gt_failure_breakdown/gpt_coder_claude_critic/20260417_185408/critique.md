UNSATISFACTORY
Reason: The `acme_org` CTE filters `_FIVETRAN_DELETED = TRUE` instead of `FALSE`, which means it queries deleted organizations and will return incorrect or empty results.