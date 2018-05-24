-- Revert side7v5:forum_last_viewed from mysql

BEGIN;

DROP forum_last_viewed;

COMMIT;
