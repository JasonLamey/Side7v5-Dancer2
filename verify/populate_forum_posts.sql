-- Verify side7v5:populate_forum_posts on mysql

BEGIN;

SELECT id, user_id
FROM forum_posts
WHERE user_id = 2;

ROLLBACK;
