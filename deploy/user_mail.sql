-- Deploy side7v5:user_mail to mysql
-- requires: users
-- requires: appuser

BEGIN;

CREATE TABLE `user_mail` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `sender_id` bigint(20) unsigned NOT NULL,
  `recipient_id` bigint(20) unsigned NOT NULL,
  `timestamp` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `subject` varchar(255) DEFAULT NULL,
  `body` text NOT NULL,
  `is_read` TINYINT(1) NOT NULL DEFAULT 0,
  `is_replied_to` TINYINT(1) NOT NULL DEFAULT 0,
  `is_deleted` TINYINT(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `sender_id` (`sender_id`),
  KEY `recipient_id` (`recipient_id`),
  KEY `timestamp` (`timestamp`),
  KEY `is_read` (`is_read`),
  KEY `is_replied_to` (`is_replied_to`),
  KEY `is_deleted` (`is_deleted`)
) ENGINE=MyISAM AUTO_INCREMENT=1 DEFAULT CHARSET=latin1 COMMENT='User Mail';

COMMIT;
