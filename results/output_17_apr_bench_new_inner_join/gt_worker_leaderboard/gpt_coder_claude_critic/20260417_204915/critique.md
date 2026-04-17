UNSATISFACTORY
Reason: `COMPLETING_WORKER_ID` is nullable so the join should be a LEFT JOIN per schema rules, but an INNER JOIN is used, excluding tasks with no assigned worker.