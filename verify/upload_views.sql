-- Verify side7v5:upload_views on mysql

BEGIN;

SELECT id, views
  FROM upload_views
 WHERE 0;

ROLLBACK;
