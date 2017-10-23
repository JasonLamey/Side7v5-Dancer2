-- Revert side7v5:populate_upload_types from mysql

BEGIN;

DELETE FROM upload_types;

COMMIT;
