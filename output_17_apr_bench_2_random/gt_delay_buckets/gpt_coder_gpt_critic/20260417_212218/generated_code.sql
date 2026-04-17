WITH completed_tasks AS (
    SELECT
        CASE
            WHEN t.COMPLETE_BEFORE IS NULL THEN 'On time'
            WHEN t.COMPLETION_DETAILS_TIME <= t.COMPLETE_BEFORE THEN 'On time'
            WHEN DATEDIFF('minute', t.COMPLETE_BEFORE, t.COMPLETION_DETAILS_TIME) < 10 THEN '< 10 min late'
            WHEN DATEDIFF('minute', t.COMPLETE_BEFORE, t.COMPLETION_DETAILS_TIME) < 30 THEN '10-30 min late'
            WHEN DATEDIFF('minute', t.COMPLETE_BEFORE, t.COMPLETION_DETAILS_TIME) < 60 THEN '30-60 min late'
            ELSE '> 60 min late'
        END AS lateness_bucket
    FROM TASKS t
    WHERE t._FIVETRAN_DELETED = FALSE
      AND t.COMPLETION_DETAILS_TIME IS NOT NULL
),
bucket_counts AS (
    SELECT
        lateness_bucket,
        COUNT(*) AS task_count
    FROM completed_tasks
    GROUP BY 1
),
total_counts AS (
    SELECT COUNT(*) AS total_tasks
    FROM completed_tasks
),
all_buckets AS (
    SELECT 'On time' AS lateness_bucket, 1 AS bucket_order
    UNION ALL
    SELECT '< 10 min late', 2
    UNION ALL
    SELECT '10-30 min late', 3
    UNION ALL
    SELECT '30-60 min late', 4
    UNION ALL
    SELECT '> 60 min late', 5
)
SELECT
    b.lateness_bucket,
    COALESCE(c.task_count, 0) AS task_count,
    COALESCE(c.task_count, 0)::FLOAT / NULLIF(t.total_tasks, 0) AS percentage_of_total
FROM all_buckets b
INNER JOIN bucket_counts c
    ON b.lateness_bucket = c.lateness_bucket
CROSS JOIN total_counts t
ORDER BY b.bucket_order;