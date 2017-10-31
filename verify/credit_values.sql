-- Verify side7v5:credit_values on mysql

BEGIN;

SELECT id, name
  FROM credit_values
 WHERE 0;

ROLLBACK;
