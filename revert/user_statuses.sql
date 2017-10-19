-- Revert side7v5:user_statuses from mysql

BEGIN;

DROP TABLE user_statuses;

COMMIT;
