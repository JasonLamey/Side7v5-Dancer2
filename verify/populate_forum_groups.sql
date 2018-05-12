-- Verify side7v5:populate_forum_groups on mysql

BEGIN;

SELECT id, name
FROM forum_groups
WHERE 0;

ROLLBACK;
