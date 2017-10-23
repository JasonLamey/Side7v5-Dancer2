-- Revert side7v5:upload_types from mysql

BEGIN;

DROP TABLE upload_types;

COMMIT;
