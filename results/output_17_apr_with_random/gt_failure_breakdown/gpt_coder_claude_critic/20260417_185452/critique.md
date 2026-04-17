UNSATISFACTORY
Reason: `target_org` filters `_FIVETRAN_DELETED = TRUE` instead of `FALSE`, so it queries deleted organizations rather than active ones.