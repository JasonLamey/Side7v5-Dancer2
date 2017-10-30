-- Revert side7v5:user_login_ip from mysql

BEGIN;

ALTER TABLE user DROP COLUMN lastlogin_ip;

COMMIT;
