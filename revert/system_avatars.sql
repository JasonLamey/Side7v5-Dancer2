-- Revert side7v5:system_avatars from mysql

BEGIN;

DROP TABLE system_avatars;

COMMIT;
