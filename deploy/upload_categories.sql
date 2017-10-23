-- Deploy side7v5:upload_categories to mysql
-- requires: appuser

BEGIN;

CREATE TABLE upload_categories (
  id INT(10) UNSIGNED NOT NULL PRIMARY KEY AUTO_INCREMENT,
  category VARCHAR(255) NOT NULL,
  upload_type_id INT(3) UNSIGNED NOT NULL,
  sort_order INT(3) UNSIGNED NOT NULL
);

COMMIT;
