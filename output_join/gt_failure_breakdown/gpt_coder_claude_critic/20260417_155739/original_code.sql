WITH acme_failures AS (
  SELECT
    COALESCE(t.COMPLETION_DETAILS_FAILURE_REASON, 'No reason recorded') AS failure_reason
  FROM TASKS t
  JOIN ORGANIZATIONS o
    ON t.EXECUTOR_ID = o.ID
  WHERE o._FIVETRAN_DELETED = FALSE
    AND t._FIVETRAN_DELETED = FALSE
    AND o.NAME ILIKE '%Acme%'
    AND t.COMPLETION_DETAILS_SUCCESS = FALSE
    AND t.COMPLETION_DETAILS_TIME >= DATEADD('month', -3, CURRENT_DATE())
),
failure_counts AS (
  SELECT
    failure_reason,
    COUNT(*) AS failure_count
  FROM acme_failures
  GROUP BY failure_reason
),
total_failures AS (
  SELECT COUNT(*) AS total_failure_count
  FROM acme_failures
)
SELECT
  fc.failure_reason,
  fc.failure_count,
  fc.failure_count::FLOAT / NULLIF(tf.total_failure_count, 0) AS percentage_of_total_failures
FROM failure_counts fc
CROSS JOIN total_failures tf
ORDER BY fc.failure_count DESC;