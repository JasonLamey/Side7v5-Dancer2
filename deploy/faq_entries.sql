-- Deploy side7v5:faq_entries to mysql
-- requires: faq_categories
-- requires: appuser

BEGIN;

CREATE TABLE faq_entries
(
  id INT(10) UNSIGNED NOT NULL PRIMARY KEY AUTO_INCREMENT,
  faq_category_id INT(10) UNSIGNED NOT NULL,
  question TEXT NOT NULL,
  answer TEXT NOT NULL,
  sort_order INT(3) UNSIGNED NOT NULL
);

COMMIT;
