WITH completed_tasks AS (
  SELECT
    CASE
      WHEN t.COMPLETE_BEFORE IS NULL THEN 'On time'
      WHEN t.COMPLETION_DETAILS_TIME <= t.COMPLETE_BEFORE THEN 'On time'
      WHEN DATEDIFF('minute', t.COMPLETE_BEFORE, t.COMPLETION_DETAILS_TIME) < 10 THEN '< 10 min late'
      WHEN DATEDIFF('minute', t.COMPLETE_BEFORE, t.COMPLETION_DETAILS_TIME) < 30 THEN '10-30 min late'
      WHEN DATEDIFF('minute', t.COMPLETE_BEFORE, t.COMPLETION_DETAILS_TIME) < 60 THEN '30-60 min late'
      ELSE '> 60 min late'
    END AS lateness_bucket
  FROM TASKS t
  WHERE t._FIVETRAN_DELETED = FALSE
    AND t.COMPLETION_DETAILS_TIME IS NOT NULL
),
bucket_counts AS (
  SELECT
    lateness_bucket,
    COUNT(*) AS task_count
  FROM completed_tasks
  GROUP BY 1
),
total_tasks AS (
  SELECT COUNT(*) AS total_count
  FROM completed_tasks
)
SELECT
  bc.lateness_bucket,
  bc.task_count,
  bc.task_count::FLOAT / NULLIF(tt.total_count, 0) AS percentage_of_total
FROM bucket_counts bc
CROSS JOIN total_tasks tt
ORDER BY
  CASE bc.lateness_bucket
    WHEN 'On time' THEN 1
    WHEN '< 10 min late' THEN 2
    WHEN '10-30 min late' THEN 3
    WHEN '30-60 min late' THEN 4
    WHEN '> 60 min late' THEN 5
  END;