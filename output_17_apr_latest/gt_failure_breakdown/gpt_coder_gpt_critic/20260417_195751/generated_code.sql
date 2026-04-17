WITH org_tasks AS (
  SELECT
    t.COMPLETION_DETAILS_FAILURE_REASON
  FROM TASKS t
  JOIN ORGANIZATIONS o
    ON t.CREATOR_ID = o.ID
  WHERE o._FIVETRAN_DELETED = FALSE
    AND t._FIVETRAN_DELETED = FALSE
    AND o.NAME ILIKE '%Acme%'
    AND t.COMPLETION_DETAILS_TIME >= DATEADD('month', -3, CURRENT_DATE())
    AND t.COMPLETION_DETAILS_SUCCESS = FALSE
),
failure_totals AS (
  SELECT COUNT(*) AS total_failures
  FROM org_tasks
)
SELECT
  COALESCE(COMPLETION_DETAILS_FAILURE_REASON, 'No reason recorded') AS failure_reason,
  COUNT(*) AS failure_count,
  COUNT(*)::FLOAT / NULLIF(MAX(ft.total_failures), 0) AS failure_percentage
FROM org_tasks ot
CROSS JOIN failure_totals ft
GROUP BY COALESCE(COMPLETION_DETAILS_FAILURE_REASON, 'No reason recorded')
ORDER BY failure_count DESC;