-- Revert side7v5:populate_forum_posts from mysql

BEGIN;

TRUNCATE forum_posts;

COMMIT;
