UNSATISFACTORY
Reason: The JOIN uses `t.CREATOR_ID` which doesn't exist in the schema; the correct column is `t.EXECUTOR_ID` linking to `ORGANIZATIONS.ID`.