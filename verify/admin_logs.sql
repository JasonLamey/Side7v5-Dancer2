-- Verify side7v5:admin_logs on mysql

BEGIN;

SELECT id
  FROM admin_logs
 WHERE 0;

ROLLBACK;
