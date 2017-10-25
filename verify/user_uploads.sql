-- Verify side7v5:user_uploads on mysql

BEGIN;

SELECT id, title
  FROM user_uploads
 WHERE 0;

ROLLBACK;
