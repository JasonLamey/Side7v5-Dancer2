-- Verify side7v5:s7_credits on mysql

BEGIN;

SELECT id, user_id
  FROM s7_credits
 WHERE 0;

ROLLBACK;
