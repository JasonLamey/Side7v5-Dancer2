-- Verify side7v5:system_avatars on mysql

BEGIN;

SELECT id, filename
  FROM system_avatars
 WHERE 0;

ROLLBACK;
