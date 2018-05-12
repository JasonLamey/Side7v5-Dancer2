-- Revert side7v5:populate_forum_groups from mysql

BEGIN;

TRUNCATE forum_groups;

COMMIT;
