-- Verify side7v5:populate_user_statuses on mysql

BEGIN;

SELECT id
  FROM user_statuses
 WHERE status = 'Pending';

ROLLBACK;
