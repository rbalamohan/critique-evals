WITH acme_org AS (
    SELECT
        id
    FROM organizations
    WHERE _fivetran_deleted = FALSE
      AND name ILIKE '%Acme%'
),
failed_tasks AS (
    SELECT
        COALESCE(t.completion_details_failure_reason, 'No reason recorded') AS failure_reason
    FROM tasks t
    INNER JOIN acme_org o
        ON t.executor_id = o.id
    WHERE t._fivetran_deleted = FALSE
      AND t.completion_details_success = FALSE
      AND t.completion_details_time >= DATEADD('month', -3, CURRENT_DATE())
),
failure_counts AS (
    SELECT
        failure_reason,
        COUNT(*) AS failure_count
    FROM failed_tasks
    GROUP BY failure_reason
),
total_failures AS (
    SELECT COUNT(*) AS total_failure_count
    FROM failed_tasks
)
SELECT
    fc.failure_reason,
    fc.failure_count,
    fc.failure_count::FLOAT / NULLIF(tf.total_failure_count, 0) AS percentage_of_total_failures
FROM failure_counts fc
CROSS JOIN total_failures tf
ORDER BY fc.failure_count DESC, fc.failure_reason;