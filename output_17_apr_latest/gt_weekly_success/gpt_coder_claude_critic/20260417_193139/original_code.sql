WITH acme_org AS (
  SELECT id
  FROM organizations
  WHERE _fivetran_deleted = FALSE
    AND name ILIKE '%Acme%'
),
weekly_tasks AS (
  SELECT
    DATE_TRUNC('WEEK', t.completion_details_time) AS week_start_date,
    COUNT(*) AS total_tasks,
    SUM(CASE WHEN t.completion_details_success = TRUE THEN 1 ELSE 0 END) AS successful_tasks,
    SUM(CASE WHEN t.completion_details_success = FALSE THEN 1 ELSE 0 END) AS failed_tasks
  FROM tasks t
  INNER JOIN acme_org o
    ON t.executor_id = o.id
  WHERE t._fivetran_deleted = FALSE
    AND t.completion_details_time >= DATEADD('WEEK', -8, CURRENT_DATE())
    AND t.completion_details_time < CURRENT_DATE()
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