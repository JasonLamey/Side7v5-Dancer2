-- Deploy side7v5:upload_types to mysql
-- requires: appuser

BEGIN;

CREATE TABLE upload_types (
  id INT(3) UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  type VARCHAR(255) NOT NULL,
  mime_types VARCHAR(255) NOT NULL,
  max_size INT(10) UNSIGNED NOT NULL
);

COMMIT;
