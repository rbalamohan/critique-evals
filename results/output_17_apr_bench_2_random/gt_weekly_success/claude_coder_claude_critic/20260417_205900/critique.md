UNSATISFACTORY
Reason: The upper bound `< CURRENT_DATE()` should be `< DATE_TRUNC('week', CURRENT_DATE())` to exclude the incomplete current week and align with the 8-week lookback window.