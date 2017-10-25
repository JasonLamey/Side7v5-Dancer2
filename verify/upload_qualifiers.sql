-- Verify side7v5:upload_qualifiers on mysql

BEGIN;

SELECT id, qualifier
  FROM upload_qualifiers
 WHERE 0;

ROLLBACK;
