-- Verify side7v5:populate_credit_values on mysql

BEGIN;

SELECT id, name
  FROM credit_values
 WHERE value = 25;

ROLLBACK;
