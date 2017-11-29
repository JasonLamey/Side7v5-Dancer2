-- Verify side7v5:upload_comment_threads on mysql

BEGIN;

SELECT id, creator_id
  FROM upload_comment_threads
 WHERE 0;

ROLLBACK;
