-- Verify side7v5:user_settings on mysql

BEGIN;

SELECT id, user_id
  FROM user_uploads
 WHERE 0;

ROLLBACK;
