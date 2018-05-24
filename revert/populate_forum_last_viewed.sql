-- Revert side7v5:populate_forum_last_viewed from mysql

BEGIN;

TRUNCATE forum_last_viewed;

COMMIT;
