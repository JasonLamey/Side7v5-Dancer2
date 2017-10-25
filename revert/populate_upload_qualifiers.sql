-- Revert side7v5:populate_upload_qualifiers from mysql

BEGIN;

DELETE FROM upload_qualifiers;

COMMIT;
