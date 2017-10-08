-- Deploy side7v5:appuser_grant to mysql
-- requires: appuser

BEGIN;

GRANT ALL PRIVILEGES ON side7_v5.* TO side7;

COMMIT;
