-- Verify side7v5:populate_upload_categories on mysql

BEGIN;

SELECT id
  FROM upload_categories
 WHERE category = 'Image';

ROLLBACK;
