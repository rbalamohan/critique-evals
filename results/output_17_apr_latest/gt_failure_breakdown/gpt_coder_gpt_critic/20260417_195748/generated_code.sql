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
totals AS (
    SELECT COUNT(*) AS total_failures
    FROM failures
)
SELECT
    f.failure_reason,
    COUNT(*) AS failure_count,
    COUNT(*)::FLOAT / NULLIF(t.total_failures, 0) AS percentage_of_total_failures
FROM failures f
CROSS JOIN totals t
GROUP BY f.failure_reason, t.total_failures
ORDER BY failure_count DESC;