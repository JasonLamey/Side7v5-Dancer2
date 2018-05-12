-- Revert side7v5:forum_categories from mysql

BEGIN;

DROP TABLE forum_categories;

COMMIT;
