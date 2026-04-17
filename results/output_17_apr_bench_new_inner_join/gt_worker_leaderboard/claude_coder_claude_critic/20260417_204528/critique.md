UNSATISFACTORY
Reason: The schema requires a LEFT JOIN for WORKERS (with COALESCE to handle unknowns), but an INNER JOIN is used, which excludes tasks where COMPLETING_WORKER_ID is NULL or unmatched.