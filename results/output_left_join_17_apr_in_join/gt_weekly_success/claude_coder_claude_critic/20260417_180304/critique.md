UNSATISFACTORY
Reason: The upper bound should use `DATE_TRUNC('week', CURRENT_DATE())` instead of `CURRENT_DATE()` to avoid including a partial current week in the results.