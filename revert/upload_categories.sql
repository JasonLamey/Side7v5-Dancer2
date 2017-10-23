-- Revert side7v5:upload_categories from mysql

BEGIN;

DROP TABLE upload_categories;

COMMIT;
