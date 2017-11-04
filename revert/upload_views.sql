-- Revert side7v5:upload_views from mysql

BEGIN;

DROP TABLE upload_views;

COMMIT;
