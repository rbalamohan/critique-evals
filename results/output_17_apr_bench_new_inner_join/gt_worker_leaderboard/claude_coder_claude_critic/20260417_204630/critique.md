UNSATISFACTORY
Reason: The schema requires a LEFT JOIN to WORKERS with COALESCE to handle nullable COMPLETING_WORKER_ID, but the code uses INNER JOIN, which excludes tasks with no assigned worker.