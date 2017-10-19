-- Revert side7v5:populate_user_statuses from mysql

BEGIN;

DELETE FROM user_statuses;

COMMIT;
