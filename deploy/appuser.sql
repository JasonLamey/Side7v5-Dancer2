-- Deploy side7v5:appuser to mysql

BEGIN;

CREATE USER 'side7'@'localhost';
SET PASSWORD for 'side7'@'localhost' = 'ArtIsLife';

COMMIT;
