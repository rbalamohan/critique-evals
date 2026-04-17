UNSATISFACTORY
Reason: `COMPLETING_WORKER_ID` is nullable and the schema requires a `LEFT JOIN` with `COALESCE`, but an `INNER JOIN` is used, which silently drops tasks with no assigned worker.