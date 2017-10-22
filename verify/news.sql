-- Verify side7v5:news on mysql

BEGIN;

SELECT id
  FROM news
 WHERE 0;

ROLLBACK;
