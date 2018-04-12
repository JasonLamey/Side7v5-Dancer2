-- Revert side7v5:populate_system_avatars from mysql

BEGIN;

DELETE FROM system_avatars;

COMMIT;
