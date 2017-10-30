-- Verify side7v5:user_login_ip on mysql

BEGIN;

SELECT lastlogin_ip
  FROM users
 WHERE 0;

ROLLBACK;
