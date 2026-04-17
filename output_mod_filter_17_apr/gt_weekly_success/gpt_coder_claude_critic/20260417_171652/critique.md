UNSATISFACTORY
Reason: `acme_orgs` filters `_FIVETRAN_DELETED = TRUE` instead of `FALSE`, which returns deleted organizations and excludes active ones.