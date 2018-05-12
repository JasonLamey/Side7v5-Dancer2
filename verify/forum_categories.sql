-- Verify side7v5:forum_categories on mysql

BEGIN;

SELECT id, name
FROM forum_categories
WHERE 0;

ROLLBACK;
