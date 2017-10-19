-- Revert side7v5:user_sexes from mysql

BEGIN;

DROP TABLE user_genders;

COMMIT;
