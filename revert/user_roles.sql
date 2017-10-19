-- Revert side7v5:user_roles from mysql

BEGIN;

DROP TABLE user_roles;

COMMIT;
