-- Revert side7v5:user_mail from mysql

BEGIN;

DROP TABLE user_mail;

COMMIT;
