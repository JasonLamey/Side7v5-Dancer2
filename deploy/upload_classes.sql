-- Deploy side7v5:upload_classes to mysql
-- requires: appuser

BEGIN;

CREATE TABLE upload_classes
(
  id INT(3) UNSIGNED NOT NULL PRIMARY KEY AUTO_INCREMENT,
  class VARCHAR(255) NOT NULL,
  description TEXT,
  sort_order INT(3) UNSIGNED NOT NULL
);

COMMIT;
