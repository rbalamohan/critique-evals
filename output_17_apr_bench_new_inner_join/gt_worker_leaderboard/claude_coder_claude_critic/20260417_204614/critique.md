UNSATISFACTORY
Reason: The schema requires a LEFT JOIN for WORKERS with COALESCE to handle unknown workers, but an INNER JOIN is used, which excludes tasks with no completing worker.