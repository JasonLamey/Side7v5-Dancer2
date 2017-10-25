-- Verify side7v5:populate_upload_qualifiers on mysql

BEGIN;

SELECT id, qualifier
  FROM upload_qualifiers
 WHERE shorthand = 'D';

ROLLBACK;
