-- Verify side7v5:forum_last_viewed on mysql

BEGIN;

SELECT id, user_id
FROM forum_last_viewed
WHERE 0;

ROLLBACK;
