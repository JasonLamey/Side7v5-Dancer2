-- Deploy side7v5:user_statuses to mysql
-- requires: users
-- requires: appuser

BEGIN;

CREATE TABLE `user_statuses` (
  `id` int(1) unsigned NOT NULL AUTO_INCREMENT,
  `status` varchar(45) CHARACTER SET latin1 NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci COMMENT='User account status lookup table';

COMMIT;
