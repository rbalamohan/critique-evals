WITH daily_tasks AS (
    SELECT
        DATE(T.COMPLETION_DETAILS_TIME) AS task_date,
        COUNT(*) AS total_tasks,
        SUM(CASE WHEN T.COMPLETION_DETAILS_SUCCESS THEN 1 ELSE 0 END) AS successful_tasks
    FROM TASKS T
    INNER JOIN ORGANIZATIONS O
        ON T.EXECUTOR_ID = O.ID
    WHERE T._FIVETRAN_DELETED = FALSE
      AND O._FIVETRAN_DELETED = FALSE
      AND O.NAME ILIKE '%Acme%'
      AND T.COMPLETION_DETAILS_TIME >= DATEADD('day', -14, CURRENT_DATE())
      AND T.COMPLETION_DETAILS_TIME < CURRENT_DATE()
    GROUP BY 1
)
SELECT
    task_date AS date,
    total_tasks,
    successful_tasks,
    total_tasks - LAG(total_tasks) OVER (ORDER BY task_date) AS day_over_day_change
FROM daily_tasks
ORDER BY date ASC;