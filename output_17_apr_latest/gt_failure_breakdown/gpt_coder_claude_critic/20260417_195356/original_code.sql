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
      AND EXECUTOR_ID IN (SELECT ID FROM acme_org)
      AND COMPLETION_DETAILS_SUCCESS = FALSE
      AND COMPLETION_DETAILS_TIME >= DATEADD('month', -3, CURRENT_DATE())
),
total_failures AS (
    SELECT COUNT(*) AS total_count
    FROM failures
)
SELECT
    f.failure_reason,
    COUNT(*) AS failure_count,
    COUNT(*)::FLOAT / NULLIF(t.total_count, 0) AS failure_percentage
FROM failures f
CROSS JOIN total_failures t
GROUP BY f.failure_reason, t.total_count
ORDER BY failure_count DESC;