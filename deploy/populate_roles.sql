-- Deploy side7v5:populate_roles to mysql
-- requires: roles
-- requires: appuser

BEGIN;

INSERT INTO roles ( role, created_on )
     VALUES ( 'New Signup', NOW() ), ( 'User', NOW() ), ( 'Subscriber', NOW() ), ( 'Moderator', NOW() ), ( 'Admin', NOW() ), ( 'Owner', NOW() );

COMMIT;
