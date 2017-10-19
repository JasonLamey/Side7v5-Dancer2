-- Revert side7v5:appuser_grant from mysql

BEGIN;

REVOKE ALL PRIVILEGES ON side7_v5.* FROM 'side7'@'localhost';

COMMIT;
