-- Revert side7v5:populate_forum_categories from mysql

BEGIN;

TRUNCATE forum_categories;

COMMIT;
