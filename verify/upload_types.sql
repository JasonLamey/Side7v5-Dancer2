-- Verify side7v5:upload_types on mysql

BEGIN;

SELECT id, type
  FROM upload_types
 WHERE 0;

ROLLBACK;
