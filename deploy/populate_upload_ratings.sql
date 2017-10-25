-- Deploy side7v5:populate_upload_ratings to mysql
-- requires: upload_ratings
-- requires: appuser

BEGIN;

INSERT INTO upload_ratings ( rating, shorthand, requires_qualifier, upload_type_id, sort_order )
VALUES
  ( 'Everyone', 'E', 0, 1, 1 ),
  ( 'Teen', 'T', 1, 1, 2 ),
  ( 'Mature', 'M', 1, 1, 3 ),
  ( 'Adult Only', 'AO', 1, 1, 4 ),
  ( 'Everyone', 'E', 0, 2, 1 ),
  ( 'Teen', 'T', 1, 2, 2 ),
  ( 'Mature', 'M', 1, 2, 3 ),
  ( 'Explicit', 'EX', 1, 2, 4 ),
  ( 'Everyone', 'E', 0, 3, 1 ),
  ( 'Teen', 'T', 1, 3, 2 ),
  ( 'Mature', 'M', 1, 3, 3 ),
  ( 'Adult', 'A', 1, 3, 4 );

COMMIT;
