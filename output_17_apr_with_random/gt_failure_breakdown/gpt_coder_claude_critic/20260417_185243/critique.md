UNSATISFACTORY
Reason: The `acme_orgs` CTE filters `_FIVETRAN_DELETED = TRUE` instead of `FALSE`, so it returns deleted organizations and excludes active ones.