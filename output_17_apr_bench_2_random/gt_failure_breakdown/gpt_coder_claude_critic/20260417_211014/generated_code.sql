WITH acme_org AS (
    SELECT ID
    FROM ORGANIZATIONS
    WHERE _FIVETRAN_DELETED = FALSE
      AND NAME ILIKE '%Acme%'
),
failures AS (
    SELECT
        COALESCE(COMPLETION_DETAILS_FAILURE_REASON, 'No reason recorded') AS failure_reason
    FROM TASKS
    WHERE _FIVETRAN_DELETED = FALSE
      AND CREATOR_ID IN (SELECT ID FROM acme_org)
      AND COMPLETION_DETAILS_SUCCESS = FALSE
      AND COMPLETION_DETAILS_TIME >= DATEADD('month', -3, CURRENT_DATE())
),
failure_counts AS (
    SELECT
        failure_reason,
        COUNT(*) AS failure_count
    FROM failures
    GROUP BY failure_reason
),
total_failures AS (
    SELECT COUNT(*) AS total_failure_count
    FROM failures
)
SELECT
    fc.failure_reason,
    fc.failure_count,
    fc.failure_count::FLOAT / NULLIF(tf.total_failure_count, 0) AS percentage_of_total_failures
FROM failure_counts fc
CROSS JOIN total_failures tf
ORDER BY fc.failure_count DESC;