-- Verify side7v5:user_avatars on mysql

BEGIN;

SELECT id, filename
  FROM user_avatars
 WHERE 0;

ROLLBACK;
