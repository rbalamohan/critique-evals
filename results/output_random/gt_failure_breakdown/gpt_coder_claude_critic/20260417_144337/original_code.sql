WITH acme_failures AS (
    SELECT
        COALESCE(t.COMPLETION_DETAILS_FAILURE_REASON, 'No reason recorded') AS failure_reason
    FROM TASKS t
    JOIN ORGANIZATIONS o
        ON t.EXECUTOR_ID = o.ID
    WHERE o.NAME ILIKE '%Acme%'
      AND t.COMPLETION_DETAILS_SUCCESS = FALSE
      AND t.COMPLETION_DETAILS_TIME >= DATEADD('month', -3, CURRENT_DATE())
      AND t._FIVETRAN_DELETED = FALSE
      AND o._FIVETRAN_DELETED = FALSE
),
failure_counts AS (
    SELECT
        failure_reason,
        COUNT(*) AS failure_count
    FROM acme_failures
    GROUP BY failure_reason
)
SELECT
    failure_reason,
    failure_count,
    failure_count::FLOAT / NULLIF(SUM(failure_count) OVER (), 0) AS percentage_of_total_failures
FROM failure_counts
ORDER BY failure_count DESC;