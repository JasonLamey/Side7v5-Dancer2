-- Revert side7v5:populate_upload_ratings from mysql

BEGIN;

DELETE FROM upload_ratings;

COMMIT;
