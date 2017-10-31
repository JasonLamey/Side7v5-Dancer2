-- Revert side7v5:populate_credit_values from mysql

BEGIN;

DELETE FROM credit_values;

COMMIT;
