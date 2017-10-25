-- Verify side7v5:upload_ratings on mysql

BEGIN;

SELECT id, rating
  FROM upload_ratings
 WHERE 0;

ROLLBACK;
