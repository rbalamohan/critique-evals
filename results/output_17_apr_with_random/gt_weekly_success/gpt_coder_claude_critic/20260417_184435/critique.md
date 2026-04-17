UNSATISFACTORY
Reason: `acme_orgs` filters `_FIVETRAN_DELETED = TRUE` instead of `FALSE`, so it returns deleted organizations and excludes all valid ones.