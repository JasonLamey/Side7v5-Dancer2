-- Revert side7v5:forum_thread_views from mysql

BEGIN;

DROP TABLE forum_thread_views;

COMMIT;
