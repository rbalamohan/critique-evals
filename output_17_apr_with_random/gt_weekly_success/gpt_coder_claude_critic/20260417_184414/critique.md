UNSATISFACTORY
Reason: `o._FIVETRAN_DELETED = TRUE` in the JOIN condition incorrectly includes only deleted organizations instead of filtering them out with `= FALSE`.