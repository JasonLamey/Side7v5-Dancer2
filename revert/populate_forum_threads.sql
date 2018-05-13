-- Revert side7v5:populate_forum_threads from mysql

BEGIN;

TRUNCATE forum_threads;

COMMIT;
