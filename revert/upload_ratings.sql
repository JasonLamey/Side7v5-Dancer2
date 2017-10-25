-- Revert side7v5:upload_ratings from mysql

BEGIN;

DROP TABLE upload_ratings;

COMMIT;
