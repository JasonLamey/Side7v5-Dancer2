-- Revert side7v5:user_uploads from mysql

BEGIN;

DROP TABLE user_uploads;

COMMIT;
