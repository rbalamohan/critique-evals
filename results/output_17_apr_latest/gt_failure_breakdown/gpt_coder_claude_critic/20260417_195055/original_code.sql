WITH org AS (
    SELECT ID
    FROM ORGANIZATIONS
    WHERE _FIVETRAN_DELETED = FALSE
      AND NAME ILIKE '%Acme%'
),
failed_tasks AS (
    SELECT
        COALESCE(COMPLETION_DETAILS_FAILURE_REASON, 'No reason recorded') AS failure_reason
    FROM TASKS
    WHERE _FIVETRAN_DELETED = FALSE
      AND EXECUTOR_ID IN (SELECT ID FROM org)
      AND COMPLETION_DETAILS_SUCCESS = FALSE
      AND COMPLETION_DETAILS_TIME >= DATEADD('month', -3, CURRENT_DATE())
),
totals AS (
    SELECT COUNT(*) AS total_failures
    FROM failed_tasks
)
SELECT
    ft.failure_reason,
    COUNT(*) AS failure_count,
    COUNT(*)::FLOAT / NULLIF(t.total_failures, 0) AS failure_percentage
FROM failed_tasks ft
CROSS JOIN totals t
GROUP BY ft.failure_reason, t.total_failures
ORDER BY failure_count DESC;