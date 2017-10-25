-- Revert side7v5:upload_qualifiers from mysql

BEGIN;

DROP TABLE upload_qualifiers;

COMMIT;
