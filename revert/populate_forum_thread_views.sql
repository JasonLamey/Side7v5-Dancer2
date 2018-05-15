-- Revert side7v5:populate_forum_thread_views from mysql

BEGIN;

TRUNCATE forum_thread_views;

COMMIT;
