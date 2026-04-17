UNSATISFACTORY
Reason: `_FIVETRAN_DELETED = TRUE` in `acme_orgs` should be `= FALSE`, causing the query to filter on deleted organizations instead of active ones.