-- Revert side7v5:forum_groups from mysql

BEGIN;

DROP TABLE forum_groups;

COMMIT;
