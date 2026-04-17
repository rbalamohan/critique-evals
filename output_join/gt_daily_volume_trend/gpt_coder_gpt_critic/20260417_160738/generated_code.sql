WITH daily_task_volume AS (
    SELECT
        DATE_TRUNC('DAY', t.COMPLETION_DETAILS_TIME)::DATE AS task_date,
        COUNT(*) AS total_tasks,
        SUM(CASE WHEN t.COMPLETION_DETAILS_SUCCESS THEN 1 ELSE 0 END) AS successful_tasks
    FROM TASKS t
    INNER JOIN ORGANIZATIONS o
        ON t.CREATOR_ID = o.ID
    WHERE o.NAME ILIKE '%Acme%'
      AND o._FIVETRAN_DELETED = FALSE
      AND t._FIVETRAN_DELETED = FALSE
      AND t.COMPLETION_DETAILS_TIME >= DATEADD('DAY', -14, CURRENT_DATE())
      AND t.COMPLETION_DETAILS_TIME < CURRENT_DATE()
    GROUP BY 1
)
SELECT
    task_date AS date,
    total_tasks,
    successful_tasks,
    total_tasks - LAG(total_tasks) OVER (ORDER BY task_date) AS day_over_day_change
FROM daily_task_volume
ORDER BY date ASC;