WITH daily_agg AS (
    SELECT
        DATE(t.COMPLETION_DETAILS_TIME) AS task_date,
        COUNT(*) AS total_tasks,
        SUM(CASE WHEN t.COMPLETION_DETAILS_SUCCESS THEN 1 ELSE 0 END) AS successful_tasks
    FROM TASKS t
    JOIN ORGANIZATIONS o
        ON t.CREATOR_ID = o.ID
    WHERE t._FIVETRAN_DELETED = FALSE
      AND o._FIVETRAN_DELETED = FALSE
      AND o.NAME ILIKE '%Acme%'
      AND DATE(t.COMPLETION_DETAILS_TIME) >= DATEADD('day', -14, CURRENT_DATE())
      AND DATE(t.COMPLETION_DETAILS_TIME) < CURRENT_DATE()
    GROUP BY 1
)
SELECT
    task_date AS date,
    total_tasks,
    successful_tasks,
    total_tasks - LAG(total_tasks) OVER (ORDER BY task_date) AS day_over_day_change
FROM daily_agg
ORDER BY task_date ASC;