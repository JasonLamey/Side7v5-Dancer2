-- Revert side7v5:user_settings from mysql

BEGIN;

DROP TABLE user_settings;

COMMIT;
