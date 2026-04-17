UNSATISFACTORY
Reason: `acme_org` filters `_FIVETRAN_DELETED = TRUE` instead of `FALSE`, so it will match only deleted organization records and return no valid results.