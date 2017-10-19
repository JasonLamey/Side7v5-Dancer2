-- Revert side7v5:populate_roles from mysql

BEGIN;

DELETE FROM roles;

COMMIT;
