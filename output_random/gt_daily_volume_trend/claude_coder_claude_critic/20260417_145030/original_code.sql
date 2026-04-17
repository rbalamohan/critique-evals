WITH daily_agg AS (
    SELECT
        DATE(t.COMPLETION_DETAILS_TIME) AS task_date,
        COUNT(*) AS total_tasks,
        SUM(CASE WHEN t.COMPLETION_DETAILS_SUCCESS = TRUE THEN 1 ELSE 0 END) AS successful_tasks
    FROM TASKS t
    JOIN ORGANIZATIONS o
        ON t.EXECUTOR_ID = o.ID
    WHERE o.NAME ILIKE '%Acme%'
      AND o._FIVETRAN_DELETED = FALSE
      AND t._FIVETRAN_DELETED = FALSE
      AND DATE(t.COMPLETION_DETAILS_TIME) >= DATEADD('day', -14, CURRENT_DATE())
      AND DATE(t.COMPLETION_DETAILS_TIME) < CURRENT_DATE()
    GROUP BY DATE(t.COMPLETION_DETAILS_TIME)
)
SELECT
    task_date,
    total_tasks,
    successful_tasks,
    total_tasks - LAG(total_tasks) OVER (ORDER BY task_date) AS day_over_day_change
FROM daily_agg
ORDER BY task_date ASC