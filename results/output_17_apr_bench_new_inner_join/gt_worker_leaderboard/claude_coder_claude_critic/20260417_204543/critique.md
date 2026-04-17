UNSATISFACTORY
Reason: The schema requires a LEFT JOIN on WORKERS with COALESCE to handle unknown workers, but the query uses INNER JOIN, which excludes tasks with no matching worker record.