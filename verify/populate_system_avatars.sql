-- Verify side7v5:populate_system_avatars on mysql

BEGIN;

SELECT id, filename FROM system_avatars WHERE id = 1;

ROLLBACK;
