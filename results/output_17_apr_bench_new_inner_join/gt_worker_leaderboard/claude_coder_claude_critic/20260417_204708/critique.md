UNSATISFACTORY
Reason: The schema requires a LEFT JOIN for WORKERS with COALESCE to handle nullable COMPLETING_WORKER_ID, but an INNER JOIN is used, excluding tasks with no completing worker.