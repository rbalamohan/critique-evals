UNSATISFACTORY
Reason: `COMPLETING_WORKER_ID` is nullable and requires a LEFT JOIN per schema rules, but the code uses INNER JOIN, which silently drops tasks with no assigned worker.