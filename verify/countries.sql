-- Verify side7v5:countries on mysql

BEGIN;

SELECT id
  FROM countries
 WHERE 0;

ROLLBACK;
