UNSATISFACTORY
Reason: `COMPLETING_WORKER_ID` is nullable so `WORKERS` must use a `LEFT JOIN`, but the code uses `INNER JOIN`, which silently drops tasks with no assigned worker.