-- Verify side7v5:populate_forum_last_viewed on mysql

BEGIN;

SELECT id, user_id FROM forum_last_viewed WHERE user_id = 2;

ROLLBACK;
