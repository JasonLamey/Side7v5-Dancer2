-- Verify side7v5:upload_classes on mysql

BEGIN;

SELECT id, class
  FROM upload_classes
 WHERE 0;

ROLLBACK;
