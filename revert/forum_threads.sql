-- Revert side7v5:forum_threads from mysql

BEGIN;

DROP TABLE forum_threads;

COMMIT;
