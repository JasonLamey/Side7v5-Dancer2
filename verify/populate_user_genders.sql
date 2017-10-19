-- Verify side7v5:populate_user_genders on mysql

BEGIN;

SELECT id FROM user_genders WHERE gender = 'Unspecified';

ROLLBACK;
