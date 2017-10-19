-- Revert side7v5:populate_countries from mysql

BEGIN;

DELETE FROM countries;

COMMIT;
