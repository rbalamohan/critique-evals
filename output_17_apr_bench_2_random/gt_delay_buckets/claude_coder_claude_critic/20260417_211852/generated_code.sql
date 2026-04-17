WITH completed_tasks AS (
    SELECT
        ID,
        COMPLETE_BEFORE,
        COMPLETION_DETAILS_TIME,
        CASE
            WHEN COMPLETE_BEFORE IS NULL THEN 'On time'
            WHEN COMPLETION_DETAILS_TIME <= COMPLETE_BEFORE THEN 'On time'
            WHEN DATEDIFF('minute', COMPLETE_BEFORE, COMPLETION_DETAILS_TIME) < 10 THEN '< 10 min late'
            WHEN DATEDIFF('minute', COMPLETE_BEFORE, COMPLETION_DETAILS_TIME) < 30 THEN '10-30 min late'
            WHEN DATEDIFF('minute', COMPLETE_BEFORE, COMPLETION_DETAILS_TIME) < 60 THEN '30-60 min late'
            ELSE '> 60 min late'
        END AS lateness_bucket
    FROM TASKS
    WHERE _FIVETRAN_DELETED = FALSE
      AND COMPLETION_DETAILS_SUCCESS = TRUE
      AND COMPLETION_DETAILS_TIME IS NOT NULL
),
total AS (
    SELECT COUNT(*) AS total_count
    FROM completed_tasks
)
SELECT
    lateness_bucket,
    COUNT(*) AS task_count,
    ROUND(COUNT(*)::FLOAT / NULLIF(total_count, 0) * 100, 2) AS percentage_of_total,
    CASE lateness_bucket
        WHEN 'On time'        THEN 1
        WHEN '< 10 min late'  THEN 2
        WHEN '10-30 min late' THEN 3
        WHEN '30-60 min late' THEN 4
        WHEN '> 60 min late'  THEN 5
    END AS sort_order
FROM completed_tasks
CROSS JOIN total
GROUP BY lateness_bucket
ORDER BY sort_order