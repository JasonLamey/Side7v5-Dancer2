-- Verify side7v5:user_roles on mysql

BEGIN;

SELECT user_id, role_id
  FROM user_roles
 WHERE 0;

ROLLBACK;
