WITH daily AS (
    SELECT
        DATE_TRUNC('day', t.COMPLETION_DETAILS_TIME) AS task_date,
        COUNT(*)                                      AS total_tasks,
        SUM(CASE WHEN t.COMPLETION_DETAILS_SUCCESS = TRUE THEN 1 ELSE 0 END) AS successful_tasks
    FROM TASKS t
    WHERE t.EXECUTOR_ID IN (
        SELECT ID FROM ORGANIZATIONS
        WHERE NAME ILIKE '%Acme%'
          AND _FIVETRAN_DELETED = FALSE
    )
      AND t.COMPLETION_DETAILS_TIME >= DATEADD('day', -14, CURRENT_DATE())
      AND t.COMPLETION_DETAILS_TIME <  CURRENT_DATE()
      AND t._FIVETRAN_DELETED = FALSE
    GROUP BY DATE_TRUNC('day', t.COMPLETION_DETAILS_TIME)
)
SELECT
    task_date,
    total_tasks,
    successful_tasks,
    total_tasks - LAG(total_tasks) OVER (ORDER BY task_date) AS day_over_day_change
FROM daily
ORDER BY task_date;