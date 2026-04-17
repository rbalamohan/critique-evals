WITH org AS (
  SELECT id
  FROM ORGANIZATIONS
  WHERE _FIVETRAN_DELETED = FALSE
    AND NAME ILIKE '%Acme%'
),
failures AS (
  SELECT
    COALESCE(COMPLETION_DETAILS_FAILURE_REASON, 'No reason recorded') AS failure_reason
  FROM TASKS
  WHERE _FIVETRAN_DELETED = FALSE
    AND EXECUTOR_ID IN (SELECT id FROM org)
    AND COMPLETION_DETAILS_SUCCESS = FALSE
    AND COMPLETION_DETAILS_TIME >= DATEADD('month', -3, CURRENT_DATE())
),
totals AS (
  SELECT COUNT(*) AS total_failures
  FROM failures
)
SELECT
  f.failure_reason,
  COUNT(*) AS failure_count,
  COUNT(*)::FLOAT / NULLIF(t.total_failures, 0) AS failure_percentage
FROM failures f
CROSS JOIN totals t
GROUP BY f.failure_reason, t.total_failures
ORDER BY failure_count DESC;