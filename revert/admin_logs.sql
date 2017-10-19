-- Revert side7v5:admin_logs from mysql

BEGIN;

DROP TABLE admin_logs;

COMMIT;
