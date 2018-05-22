-- Deploy side7v5:forum_posts to mysql
-- requires: appuser
-- requires: forum_threads

BEGIN;

CREATE TABLE `forum_posts` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `forum_thread_id` bigint(20) unsigned NOT NULL DEFAULT '0' REFERENCES forum_threads(id),
  `user_id` bigint(20) unsigned NOT NULL DEFAULT '0' REFERENCES users(id),
  `subject` varchar(255) DEFAULT NULL,
  `body` text NOT NULL,
  `show_signature` int(1) NOT NULL DEFAULT 1,
  `timestamp` datetime NOT NULL DEFAULT NOW(),
  `last_modified_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `modified_count` bigint(20) NOT NULL DEFAULT '0',
  `ip_address` varchar(255) DEFAULT NULL,
  `original_forum_thread_id` bigint(20) unsigned DEFAULT NULL REFERENCES forum_threads(id),
  PRIMARY KEY (`id`),
  KEY `forum_thread_id` (`forum_thread_id`),
  KEY `user_id` (`user_id`),
  KEY `timestamp` (`timestamp`),
  KEY `original_forum_thread_id` (`original_forum_thread_id`),
  INDEX `time_thread_idx` (`timestamp`, `forum_thread_id`)
) ENGINE=MyISAM AUTO_INCREMENT=1 DEFAULT CHARSET=latin1 COMMENT='Forum Posts - Created by users';

COMMIT;
