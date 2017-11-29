-- Verify side7v5:upload_comments on mysql

BEGIN;

SELECT id, user_id, username
  FROM upload_comments
 WHERE 0;

ROLLBACK;
