UNSATISFACTORY
Reason: `acme_org` filters `_FIVETRAN_DELETED = TRUE` instead of `FALSE`, so it will return deleted organizations and exclude valid ones.