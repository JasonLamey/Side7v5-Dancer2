-- Deploy side7v5:upload_qualifiers to mysql
-- requires: appuser

BEGIN;

CREATE TABLE upload_qualifiers
(
  id INT(3) UNSIGNED NOT NULL PRIMARY KEY AUTO_INCREMENT,
  qualifier VARCHAR(255) NOT NULL,
  shorthand CHAR(1) NOT NULL,
  description TEXT,
  sort_order INT(3) UNSIGNED NOT NULL
);

COMMIT;
