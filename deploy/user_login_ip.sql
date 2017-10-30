-- Deploy side7v5:user_login_ip to mysql
-- requires: users
-- requires: appuser

BEGIN;

ALTER TABLE users ADD COLUMN lastlogin_ip VARCHAR(255) DEFAULT NULL AFTER lastlogin;

COMMIT;
