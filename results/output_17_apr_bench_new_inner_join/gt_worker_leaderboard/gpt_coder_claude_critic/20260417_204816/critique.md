UNSATISFACTORY
Reason: The schema requires a LEFT JOIN for WORKERS with COALESCE to handle unknowns, but the code uses INNER JOIN, which excludes tasks with no matching worker.