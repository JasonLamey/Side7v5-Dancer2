-- Verify side7v5:forum_thread_views on mysql

BEGIN;

SELECT id, forum_thread_id
FROM forum_thread_views
WHERE 0;

ROLLBACK;
