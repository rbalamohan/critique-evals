WITH target_org AS (
    SELECT id
    FROM organizations
    WHERE _fivetran_deleted = FALSE
      AND name ILIKE '%Acme%'
),
failures AS (
    SELECT
        COALESCE(completion_details_failure_reason, 'No reason recorded') AS failure_reason
    FROM tasks
    WHERE _fivetran_deleted = FALSE
      AND executor_id IN (SELECT id FROM target_org)
      AND completion_details_success = FALSE
      AND completion_details_time >= DATEADD('month', -3, CURRENT_DATE())
),
total_failures AS (
    SELECT COUNT(*) AS total_count
    FROM failures
)
SELECT
    f.failure_reason,
    COUNT(*) AS failure_count,
    COUNT(*)::FLOAT / NULLIF(tf.total_count, 0) AS failure_percentage
FROM failures f
CROSS JOIN total_failures tf
GROUP BY f.failure_reason, tf.total_count
ORDER BY failure_count DESC;