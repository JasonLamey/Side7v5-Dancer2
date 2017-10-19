-- Verify side7v5:populate_countries on mysql

BEGIN;

SELECT id
  FROM countries
 WHERE id = 1;

ROLLBACK;
