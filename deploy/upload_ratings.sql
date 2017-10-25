-- Deploy side7v5:upload_ratings to mysql
-- requires: appuser

BEGIN;

CREATE TABLE upload_ratings
(
  id INT(3) UNSIGNED NOT NULL PRIMARY KEY AUTO_INCREMENT,
  rating VARCHAR(255) NOT NULL,
  shorthand VARCHAR(3) NOT NULL,
  description TEXT,
  requires_qualifier INT(1) UNSIGNED NOT NULL DEFAULT 0,
  upload_type_id INT(3) UNSIGNED NOT NULL,
  sort_order INT(3) UNSIGNED NOT NULL
);

COMMIT;
