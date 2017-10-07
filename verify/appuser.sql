-- Verify side7v5:appuser on mysql

BEGIN;

SELECT sqitch.checkit(COUNT(*), 'User "side7" does not exist')
  FROM mysql.user WHERE user = 'side7';

ROLLBACK;
