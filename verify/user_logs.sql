-- Verify side7v5:user_logs on mysql

BEGIN;

SELECT id
  FROM user_logs
 WHERE 0;

ROLLBACK;
