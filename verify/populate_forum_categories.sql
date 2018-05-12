-- Verify side7v5:populate_forum_categories on mysql

BEGIN;

SELECT id FROM forum_categories WHERE id = 1;

ROLLBACK;
