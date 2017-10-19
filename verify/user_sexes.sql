-- Verify side7v5:user_sexes on mysql

BEGIN;

SELECT id, gender
  FROM user_genders
 WHERE 0;

ROLLBACK;
