-- Deploy side7v5:user_uploads to mysql
-- requires: users
-- requires: upload_categories
-- requires: upload_classes
-- requires: upload_qualifiers
-- requires: upload_ratings
-- requires: upload_types
-- requires: appuser

BEGIN;

CREATE TABLE user_uploads
(
  id BIGINT(20) UNSIGNED NOT NULL PRIMARY KEY AUTO_INCREMENT,
  user_id BIGINT(20) UNSIGNED NOT NULL,
  upload_type_id INT(3) UNSIGNED NOT NULL,
  filename VARCHAR(255) NOT NULL,
  filesize INT(10) UNSIGNED NOT NULL,
  upload_category_id INT(10) UNSIGNED NOT NULL,
  upload_rating_id INT(3) UNSIGNED NOT NULL,
  upload_class_id INT(3) UNSIGNED NOT NULL,
  title VARCHAR(255) NOT NULL,
  description TEXT DEFAULT NULL,
  views INT(10) UNSIGNED NOT NULL DEFAULT 0,
  uploaded_on DATETIME NOT NULL DEFAULT NOW()
);

COMMIT;
