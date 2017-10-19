-- Verify side7v5:users on mysql

BEGIN;

SELECT username, password, created_at
  FROM users
 WHERE 0;

ROLLBACK;
