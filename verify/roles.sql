-- Verify side7v5:roles on mysql

BEGIN;

SELECT id
  FROM roles
 WHERE 0;

ROLLBACK;
