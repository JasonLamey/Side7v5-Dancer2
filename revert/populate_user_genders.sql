-- Revert side7v5:populate_user_genders from mysql

BEGIN;

DELETE FROM user_genders;

COMMIT;
