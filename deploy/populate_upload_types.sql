-- Deploy side7v5:populate_upload_types to mysql
-- requires: upload_types
-- requires: appuser

BEGIN;

INSERT INTO upload_types ( type, mime_types, max_size )
VALUES
  ( 'Image', 'image/jpeg,image/gif,image/png', '10485760' ),
  ( 'Audio', 'audio/mpeg3,audio/x-mpeg-3,audio/ogg,audio/mpeg,audio/midi,audio/x-mid,audio/x-midi,audio/wav', '10485760' ),
  ( 'Literature', 'application/pdf', '10485760' );

COMMIT;
