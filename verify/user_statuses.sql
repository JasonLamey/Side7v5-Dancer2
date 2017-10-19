-- Verify side7v5:user_statuses on mysql

BEGIN;

SELECT id, status
  FROM user_statuses
 WHERE 0;

ROLLBACK;
