-- Verify side7v5:upload_categories on mysql

BEGIN;

SELECT id, category
  FROM upload_categories
 WHERE 0;

ROLLBACK;
