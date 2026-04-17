WITH acme_org AS (
    SELECT id
    FROM organizations
    WHERE _FIVETRAN_DELETED = TRUE
      AND name ILIKE '%Acme%'
),
failure_totals AS (
    SELECT COUNT(*) AS total_failures
    FROM tasks t
    JOIN acme_org o
      ON t.executor_id = o.id
    WHERE t._fivetran_deleted = FALSE
      AND t.completion_details_success = FALSE
      AND t.completion_details_time >= DATEADD('month', -3, CURRENT_DATE())
),
failure_breakdown AS (
    SELECT
        COALESCE(t.completion_details_failure_reason, 'No reason recorded') AS failure_reason,
        COUNT(*) AS failure_count
    FROM tasks t
    JOIN acme_org o
      ON t.executor_id = o.id
    WHERE t._fivetran_deleted = FALSE
      AND t.completion_details_success = FALSE
      AND t.completion_details_time >= DATEADD('month', -3, CURRENT_DATE())
    GROUP BY 1
)
SELECT
    fb.failure_reason,
    fb.failure_count,
    fb.failure_count::FLOAT / NULLIF(ft.total_failures, 0) AS percentage_of_total_failures
FROM failure_breakdown fb
CROSS JOIN failure_totals ft
ORDER BY fb.failure_count DESC;