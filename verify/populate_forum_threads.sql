-- Verify side7v5:populate_forum_threads on mysql

BEGIN;

SELECT id, name FROM forum_threads;

ROLLBACK;
