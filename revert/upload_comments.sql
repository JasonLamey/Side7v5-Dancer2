-- Revert side7v5:upload_comments from mysql

BEGIN;

DROP TABLE upload_comments;

COMMIT;
