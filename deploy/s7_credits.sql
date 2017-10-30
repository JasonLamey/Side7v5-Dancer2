-- Deploy side7v5:s7_credits to mysql
-- requires: users
-- requires: appuser

BEGIN;

CREATE TABLE `s7_credits` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `timestamp` datetime NOT NULL DEFAULT NOW(),
  `user_id` bigint(20) unsigned NOT NULL,
  `amount` int(10) NOT NULL DEFAULT '0',
  `description` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `timestamp` (`timestamp`),
  KEY `user_id` (`user_id`)
) ENGINE=MyISAM AUTO_INCREMENT=1 DEFAULT CHARSET=latin1 COMMENT='Account Credit Transaction Records';

COMMIT;
