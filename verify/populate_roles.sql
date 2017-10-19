-- Verify side7v5:populate_roles on mysql

BEGIN;

SELECT id FROM roles WHERE role = 'User';

ROLLBACK;
