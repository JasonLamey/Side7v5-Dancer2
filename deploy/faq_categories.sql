-- Deploy side7v5:faq_categories to mysql
-- requires: appuser

BEGIN;

CREATE TABLE faq_categories
(
  id INT(10) UNSIGNED NOT NULL PRIMARY KEY AUTO_INCREMENT,
  category VARCHAR(255) NOT NULL,
  sort_order INT(3) UNSIGNED
);

COMMIT;
