WITH org AS (
    SELECT ID
    FROM ORGANIZATIONS
    WHERE NAME ILIKE '%Acme%'
    AND _FIVETRAN_DELETED = FALSE
),
failures AS (
    SELECT
        COALESCE(t.COMPLETION_DETAILS_FAILURE_REASON, 'No reason recorded') AS failure_reason,
        COUNT(*) AS failure_count
    FROM TASKS t
    INNER JOIN org o ON t.CREATOR_ID = o.ID
    WHERE t._FIVETRAN_DELETED = FALSE
    AND t.COMPLETION_DETAILS_SUCCESS = FALSE
    AND t.COMPLETION_DETAILS_TIME >= DATEADD('month', -3, CURRENT_DATE())
    GROUP BY 1
),
total AS (
    SELECT SUM(failure_count) AS total_failures
    FROM failures
)
SELECT
    f.failure_reason,
    f.failure_count,
    ROUND((f.failure_count::FLOAT / NULLIF(t.total_failures, 0)) * 100, 2) AS percentage_of_total
FROM failures f
CROSS JOIN total t
ORDER BY f.failure_count DESC