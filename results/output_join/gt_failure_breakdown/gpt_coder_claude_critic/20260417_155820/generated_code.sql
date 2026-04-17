WITH acme_org AS (
    SELECT id
    FROM organizations
    WHERE _fivetran_deleted = FALSE
      AND name ILIKE '%Acme%'
),
failure_counts AS (
    SELECT
        COALESCE(completion_details_failure_reason, 'No reason recorded') AS failure_reason,
        COUNT(*) AS failure_count
    FROM tasks
    WHERE _fivetran_deleted = FALSE
      AND executor_id IN (SELECT id FROM acme_org)
      AND completion_details_success = FALSE
      AND completion_details_time >= DATEADD('month', -3, CURRENT_DATE())
    GROUP BY 1
),
total_failures AS (
    SELECT COUNT(*) AS total_failure_count
    FROM tasks
    WHERE _fivetran_deleted = FALSE
      AND executor_id IN (SELECT id FROM acme_org)
      AND completion_details_success = FALSE
      AND completion_details_time >= DATEADD('month', -3, CURRENT_DATE())
)
SELECT
    fc.failure_reason,
    fc.failure_count,
    fc.failure_count::FLOAT / NULLIF(tf.total_failure_count, 0) AS percentage_of_total_failures
FROM failure_counts fc
CROSS JOIN total_failures tf
ORDER BY fc.failure_count DESC, fc.failure_reason;