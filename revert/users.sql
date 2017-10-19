-- Revert side7v5:users from mysql

BEGIN;

DROP TABLE users;

COMMIT;
