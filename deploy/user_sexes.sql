-- Deploy side7v5:user_sexes to mysql
-- requires: users
-- requires: appuser

BEGIN;

CREATE TABLE `user_genders` (
  `id` int(1) unsigned NOT NULL AUTO_INCREMENT,
  `gender` varchar(45) CHARACTER SET latin1 NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci COMMENT='User gender lookup table';

COMMIT;
