-- Verify side7v5:populate_upload_ratings on mysql

BEGIN;

SELECT id, rating
  FROM upload_ratings
 WHERE upload_type_id = 1 AND sort_order = 1;

ROLLBACK;
