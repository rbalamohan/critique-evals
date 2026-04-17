UNSATISFACTORY
Reason: The schema requires a LEFT JOIN for WORKERS (with COALESCE for unknown workers), but the code uses INNER JOIN, which silently excludes tasks with no assigned worker.