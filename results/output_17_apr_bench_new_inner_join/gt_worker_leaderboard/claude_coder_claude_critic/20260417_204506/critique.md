UNSATISFACTORY
Reason: The schema rules require a LEFT JOIN for WORKERS with COALESCE to handle unknown workers, but the code uses an INNER JOIN, which excludes tasks with no completing worker.