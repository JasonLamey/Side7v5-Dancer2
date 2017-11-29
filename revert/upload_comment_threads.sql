-- Revert side7v5:upload_comment_threads from mysql

BEGIN;

DROP TABLE upload_comment_threads;

COMMIT;
