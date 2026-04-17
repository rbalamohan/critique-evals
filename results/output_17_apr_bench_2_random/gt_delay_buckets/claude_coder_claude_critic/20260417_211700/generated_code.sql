WITH completed_tasks AS (
    SELECT
        t.ID,
        t.COMPLETION_DETAILS_TIME,
        t.COMPLETE_BEFORE,
        CASE
            WHEN t.COMPLETE_BEFORE IS NULL THEN 'On time'
            WHEN t.COMPLETION_DETAILS_TIME <= t.COMPLETE_BEFORE THEN 'On time'
            WHEN DATEDIFF('minute', t.COMPLETE_BEFORE, t.COMPLETION_DETAILS_TIME) < 10 THEN '< 10 min late'
            WHEN DATEDIFF('minute', t.COMPLETE_BEFORE, t.COMPLETION_DETAILS_TIME) < 30 THEN '10-30 min late'
            WHEN DATEDIFF('minute', t.COMPLETE_BEFORE, t.COMPLETION_DETAILS_TIME) < 60 THEN '30-60 min late'
            ELSE '> 60 min late'
        END AS lateness_bucket,
        CASE
            WHEN t.COMPLETE_BEFORE IS NULL THEN 0
            WHEN t.COMPLETION_DETAILS_TIME <= t.COMPLETE_BEFORE THEN 0
            WHEN DATEDIFF('minute', t.COMPLETE_BEFORE, t.COMPLETION_DETAILS_TIME) < 10 THEN 1
            WHEN DATEDIFF('minute', t.COMPLETE_BEFORE, t.COMPLETION_DETAILS_TIME) < 30 THEN 2
            WHEN DATEDIFF('minute', t.COMPLETE_BEFORE, t.COMPLETION_DETAILS_TIME) < 60 THEN 3
            ELSE 4
        END AS bucket_order
    FROM TASKS t
    WHERE t._FIVETRAN_DELETED = FALSE
      AND t.COMPLETION_DETAILS_SUCCESS = TRUE
      AND t.COMPLETION_DETAILS_TIME IS NOT NULL
),
bucket_counts AS (
    SELECT
        lateness_bucket,
        bucket_order,
        COUNT(*) AS task_count
    FROM completed_tasks
    GROUP BY lateness_bucket, bucket_order
),
total AS (
    SELECT COUNT(*) AS total_count
    FROM completed_tasks
)
SELECT
    b.lateness_bucket,
    b.task_count,
    ROUND(b.task_count::FLOAT / NULLIF(t.total_count, 0) * 100, 2) AS percentage_of_total
FROM bucket_counts b
CROSS JOIN total t
ORDER BY b.bucket_order ASC