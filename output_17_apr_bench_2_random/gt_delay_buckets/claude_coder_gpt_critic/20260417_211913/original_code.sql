WITH completed_tasks AS (
    SELECT
        t.ID,
        t.COMPLETE_BEFORE,
        t.COMPLETION_DETAILS_TIME,
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
      AND t.COMPLETION_DETAILS_SUCCESS = TRUE
      AND t.COMPLETION_DETAILS_TIME IS NOT NULL
),
bucket_counts AS (
    SELECT
        lateness_bucket,
        COUNT(*) AS task_count
    FROM completed_tasks
    GROUP BY lateness_bucket
),
total AS (
    SELECT SUM(task_count) AS total_count
    FROM bucket_counts
)
SELECT
    bc.lateness_bucket,
    bc.task_count,
    ROUND(bc.task_count::FLOAT / NULLIF(t.total_count, 0) * 100, 2) AS percentage_of_total,
    CASE bc.lateness_bucket
        WHEN 'On time'        THEN 1
        WHEN '< 10 min late'  THEN 2
        WHEN '10-30 min late' THEN 3
        WHEN '30-60 min late' THEN 4
        WHEN '> 60 min late'  THEN 5
    END AS sort_order
FROM bucket_counts bc
CROSS JOIN total t
ORDER BY sort_order