-- Deploy side7v5:upload_comments to mysql
-- requires: upload_comment_threads
-- requires: users
-- requires: appuser

BEGIN;

CREATE TABLE `upload_comments` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `upload_comment_thread_id` bigint(20) unsigned NOT NULL,
  `user_id` bigint(20) unsigned DEFAULT NULL,
  `username` varchar(255) DEFAULT NULL,
  `comment` text NOT NULL,
  `private` tinyint(1) UNSIGNED NOT NULL DEFAULT 0,
  `rating` int(1) unsigned NOT NULL DEFAULT 0,
  `ip_address` varchar(50) NOT NULL DEFAULT 'Unknown',
  `timestamp` datetime NOT NULL DEFAULT NOW(),
  PRIMARY KEY (`id`),
  KEY `upload_comment_thread_id` (`upload_comment_thread_id`),
  KEY `user_id` (`user_id`),
  KEY `private` (`private`)
) ENGINE=MyISAM AUTO_INCREMENT=1 DEFAULT CHARSET=latin1 COMMENT='Upload comments & critiques';

COMMIT;
