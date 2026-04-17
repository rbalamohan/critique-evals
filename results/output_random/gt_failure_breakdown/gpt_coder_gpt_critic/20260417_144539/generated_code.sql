WITH acme_org AS (
    SELECT id
    FROM organizations
    WHERE _fivetran_deleted = FALSE
      AND name ILIKE '%Acme%'
),
failed_tasks AS (
    SELECT
        COALESCE(completion_details_failure_reason, 'No reason recorded') AS failure_reason
    FROM tasks
    WHERE _fivetran_deleted = FALSE
      AND executor_id IN (SELECT id FROM acme_org)
      AND completion_details_success = FALSE
      AND completion_details_time >= DATEADD('month', -3, CURRENT_DATE())
),
reason_counts AS (
    SELECT
        failure_reason,
        COUNT(*) AS failure_count
    FROM failed_tasks
    GROUP BY 1
),
total_failures AS (
    SELECT COUNT(*) AS total_failure_count
    FROM failed_tasks
)
SELECT
    rc.failure_reason,
    rc.failure_count,
    rc.failure_count::FLOAT / NULLIF(tf.total_failure_count, 0) AS failure_percentage
FROM reason_counts rc
CROSS JOIN total_failures tf
ORDER BY rc.failure_count DESC;