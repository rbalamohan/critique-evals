WITH acme_failures AS (
    SELECT
        COALESCE(t.COMPLETION_DETAILS_FAILURE_REASON, 'No reason recorded') AS failure_reason
    FROM TASKS t
    JOIN ORGANIZATIONS o
        ON t.EXECUTOR_ID = o.ID
    WHERE o.NAME ILIKE '%Acme%'
      AND o._FIVETRAN_DELETED = FALSE
      AND t._FIVETRAN_DELETED = FALSE
      AND t.COMPLETION_DETAILS_SUCCESS = FALSE
      AND t.COMPLETION_DETAILS_TIME >= DATEADD('month', -3, CURRENT_DATE())
),
total_failures AS (
    SELECT COUNT(*) AS total_count
    FROM acme_failures
)
SELECT
    af.failure_reason,
    COUNT(*) AS failure_count,
    COUNT(*)::FLOAT / NULLIF(tf.total_count, 0) AS failure_percentage
FROM acme_failures af
CROSS JOIN total_failures tf
GROUP BY af.failure_reason, tf.total_count
ORDER BY failure_count DESC;