UNSATISFACTORY
Reason: `acme_orgs` filters `_FIVETRAN_DELETED = TRUE` instead of `= FALSE`, so it retrieves deleted organizations rather than active ones.