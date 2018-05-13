-- Verify side7v5:forum_posts on mysql

BEGIN;

SELECT id, user_id
FROM forum_posts
WHERE 0;

ROLLBACK;
