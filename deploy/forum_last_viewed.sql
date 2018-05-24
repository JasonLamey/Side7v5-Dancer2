-- Deploy side7v5:forum_last_viewed to mysql
-- requires: appuser
-- requires: users
-- requires: forum_threads

BEGIN;

CREATE TABLE `forum_last_viewed` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `forum_thread_id` bigint(20) unsigned NOT NULL DEFAULT '0' REFERENCES forum_threads(id),
  `user_id` bigint(20) unsigned NOT NULL DEFAULT '0' REFERENCES users(id),
  `timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `updates` bigint(20) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `thread_user_idx` (`forum_thread_id`, `user_id`),
  KEY `forum_thread_id` (`forum_thread_id`),
  KEY `user_id` (`user_id`)
) ENGINE=MyISAM AUTO_INCREMENT=1 DEFAULT CHARSET=latin1 COMMENT='User last viewed dates for threads';

COMMIT;
