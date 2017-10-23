-- Verify side7v5:populate_upload_types on mysql

BEGIN;

SELECT id, type
  FROM upload_types
 WHERE type = 'Image';

ROLLBACK;
