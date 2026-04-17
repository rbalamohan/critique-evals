UNSATISFACTORY
Reason: Grouping by `COALESCE(w.NAME, 'Unknown')` instead of `w.ID` risks merging distinct workers who share the same name under a single leaderboard entry.