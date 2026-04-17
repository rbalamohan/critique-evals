UNSATISFACTORY
Reason: The JOIN uses `t.CREATOR_ID` which doesn't exist in the schema; it should be `t.EXECUTOR_ID` to link TASKS to ORGANIZATIONS.