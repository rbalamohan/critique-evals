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
total_failures AS (
    SELECT COUNT(*) AS total_count
    FROM failed_tasks
)
SELECT
    ft.failure_reason,
    COUNT(*) AS failure_count,
    COUNT(*)::FLOAT / NULLIF(tf.total_count, 0) AS failure_percentage
FROM failed_tasks ft
CROSS JOIN total_failures tf
GROUP BY ft.failure_reason
ORDER BY failure_count DESC;