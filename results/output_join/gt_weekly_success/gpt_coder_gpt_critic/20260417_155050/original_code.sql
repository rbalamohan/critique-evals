WITH org AS (
  SELECT id
  FROM ORGANIZATIONS
  WHERE _FIVETRAN_DELETED = FALSE
    AND NAME ILIKE '%Acme%'
),
weekly_tasks AS (
  SELECT
    DATE_TRUNC('WEEK', t.COMPLETION_DETAILS_TIME) AS week_start_date,
    COUNT(*) AS total_tasks,
    SUM(CASE WHEN t.COMPLETION_DETAILS_SUCCESS = TRUE THEN 1 ELSE 0 END) AS successful_tasks,
    SUM(CASE WHEN t.COMPLETION_DETAILS_SUCCESS = FALSE THEN 1 ELSE 0 END) AS failed_tasks
  FROM TASKS t
  INNER JOIN org o
    ON t.EXECUTOR_ID = o.id
  WHERE t._FIVETRAN_DELETED = FALSE
    AND t.COMPLETION_DETAILS_TIME >= DATEADD('WEEK', -8, CURRENT_DATE())
    AND t.COMPLETION_DETAILS_TIME < CURRENT_DATE()
  GROUP BY 1
)
SELECT
  week_start_date,
  total_tasks,
  successful_tasks,
  failed_tasks,
  successful_tasks::FLOAT / NULLIF(total_tasks, 0) AS success_rate
FROM weekly_tasks
ORDER BY week_start_date;