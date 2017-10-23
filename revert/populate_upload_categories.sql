-- Revert side7v5:populate_upload_categories from mysql

BEGIN;

DELETE FROM upload_categories;

COMMIT;
