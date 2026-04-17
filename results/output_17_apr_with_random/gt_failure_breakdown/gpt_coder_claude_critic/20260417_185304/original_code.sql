WITH acme_orgs AS (
  SELECT id
  FROM ORGANIZATIONS
  WHERE _FIVETRAN_DELETED = FALSE
    AND NAME ILIKE '%Acme%'
),
failed_tasks AS (
  SELECT
    COALESCE(COMPLETION_DETAILS_FAILURE_REASON, 'No reason recorded') AS failure_reason
  FROM TASKS
  WHERE _FIVETRAN_DELETED = FALSE
    AND EXECUTOR_ID IN (SELECT id FROM acme_orgs)
    AND COMPLETION_DETAILS_SUCCESS = FALSE
    AND COMPLETION_DETAILS_TIME >= DATEADD('month', -3, CURRENT_DATE())
),
total_failures AS (
  SELECT COUNT(*) AS total_count
  FROM failed_tasks
)
SELECT
  ft.failure_reason,
  COUNT(*) AS failure_count,
  COUNT(*)::FLOAT / NULLIF(tf.total_count, 0) AS failure_percentage
FROM failed_tasks ft
CROSS JOIN total_failures tf
GROUP BY ft.failure_reason, tf.total_count
ORDER BY failure_count DESC;