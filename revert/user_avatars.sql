-- Revert side7v5:user_avatars from mysql

BEGIN;

DROP TABLE user_avatars;

COMMIT;
