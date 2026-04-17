UNSATISFACTORY
Reason: `acme_orgs` filters `_FIVETRAN_DELETED = TRUE` instead of `FALSE`, so it returns only deleted organizations and will miss all active Acme records.