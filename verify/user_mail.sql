-- Verify side7v5:user_mail on mysql

BEGIN;

SELECT id, sender_id
  FROM user_mail
 WHERE 0;

ROLLBACK;
