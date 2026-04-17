SELECT
    CASE
        WHEN t.COMPLETE_BEFORE IS NULL
          OR t.COMPLETION_DETAILS_TIME <= t.COMPLETE_BEFORE             THEN 'On time'
        WHEN DATEDIFF('second', t.COMPLETE_BEFORE, t.COMPLETION_DETAILS_TIME) <= 600
                                                                         THEN '< 10 min late'
        WHEN DATEDIFF('second', t.COMPLETE_BEFORE, t.COMPLETION_DETAILS_TIME) <= 1800
                                                                         THEN '10-30 min late'
        WHEN DATEDIFF('second', t.COMPLETE_BEFORE, t.COMPLETION_DETAILS_TIME) <= 3600
                                                                         THEN '30-60 min late'
        ELSE                                                                  '> 60 min late'
    END AS delay_category,
    COUNT(*) AS task_count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS pct
FROM TASKS t
WHERE t._FIVETRAN_DELETED = FALSE
  AND t.COMPLETION_DETAILS_TIME IS NOT NULL
GROUP BY 1
ORDER BY MIN(
    CASE
        WHEN t.COMPLETE_BEFORE IS NULL
          OR t.COMPLETION_DETAILS_TIME <= t.COMPLETE_BEFORE             THEN 0
        WHEN DATEDIFF('second', t.COMPLETE_BEFORE, t.COMPLETION_DETAILS_TIME) <= 600  THEN 1
        WHEN DATEDIFF('second', t.COMPLETE_BEFORE, t.COMPLETION_DETAILS_TIME) <= 1800 THEN 2
        WHEN DATEDIFF('second', t.COMPLETE_BEFORE, t.COMPLETION_DETAILS_TIME) <= 3600 THEN 3
        ELSE 4
    END
);