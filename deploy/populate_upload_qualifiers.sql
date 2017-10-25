-- Deploy side7v5:populate_upload_qualifiers to mysql
-- requires: upload_qualifiers
-- requires: appuser

BEGIN;

INSERT INTO upload_qualifiers
  ( qualifier, shorthand, sort_order )
VALUES
  ( 'Drugs / Alcohol / Illicit Substances', 'D', 1 ),
  ( 'Language / Profanity', 'L', 2 ),
  ( 'Nudity', 'N', 3 ),
  ( 'Suggestive / Erotic Themes', 'S', 4 ),
  ( 'Violence', 'V', 5 ),
  ( 'Other', 'O', 6 );

COMMIT;
