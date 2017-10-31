-- Deploy side7v5:credit_values to mysql
-- requires: appuser

BEGIN;

CREATE TABLE credit_values
(
  id INT(10) UNSIGNED NOT NULL PRIMARY KEY AUTO_INCREMENT,
  name VARCHAR(255) NOT NULL,
  description VARCHAR(255) NOT NULL,
  value INT(5) NOT NULL DEFAULT 0,
  message VARCHAR(255) DEFAULT NULL,
  KEY name (`name`)
);

COMMIT;
