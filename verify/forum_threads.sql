-- Verify side7v5:forum_threads on mysql

BEGIN;

SELECT id, name
FROM forum_threads
WHERE 0;

ROLLBACK;
