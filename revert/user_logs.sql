-- Revert side7v5:user_logs from mysql

BEGIN;

DROP TABLE user_logs;

COMMIT;
