UNSATISFACTORY
Reason: `acme_orgs` filters `_FIVETRAN_DELETED = TRUE` instead of `FALSE`, so it will return deleted organizations and exclude valid ones.