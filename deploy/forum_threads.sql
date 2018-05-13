-- Deploy side7v5:forum_threads to mysql
-- requires: appuser
-- requires: forum_groups

BEGIN;

CREATE TABLE `forum_threads` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `forum_group_id` bigint(20) unsigned NOT NULL DEFAULT '0',
  `name` varchar(255) NOT NULL DEFAULT '',
  `thread_status_id` bigint(20) unsigned NOT NULL DEFAULT '1',
  `start_date` datetime NOT NULL DEFAULT NOW(),
  `user_id` bigint(20) unsigned NOT NULL DEFAULT '0',
  `thread_type_id` bigint(20) unsigned NOT NULL DEFAULT '1',
  `original_forum_group_id` bigint(20) unsigned DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `forum_group_id` (`forum_group_id`),
  KEY `user_id` (`user_id`),
  KEY `thread_type_id` (`thread_type_id`),
  KEY `thread_status_id` (`thread_status_id`),
  KEY `original_forum_group_id` (`original_forum_group_id`)
) ENGINE=MyISAM AUTO_INCREMENT=1 DEFAULT CHARSET=latin1 COMMENT='Forums Threads - Groups Posts';

COMMIT;
