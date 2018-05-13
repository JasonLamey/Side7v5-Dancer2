-- Revert side7v5:forum_posts from mysql

BEGIN;

DROP TABLE forum_posts;

COMMIT;
