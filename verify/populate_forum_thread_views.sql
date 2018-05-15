-- Verify side7v5:populate_forum_thread_views on mysql

BEGIN;

SELECT id, forum_thread_id
FROM forum_thread_views
WHERE id = 1;

ROLLBACK;
