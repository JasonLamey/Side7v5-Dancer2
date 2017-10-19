-- Deploy side7v5:populate_user_statuses to mysql
-- requires: user_statuses
-- requires: users
-- requires: appuser

BEGIN;

INSERT INTO user_statuses
  ( status )
VALUES ( 'Pending' ), ( 'Active' ), ( 'Suspended' ), ( 'Disabled' );

COMMIT;
