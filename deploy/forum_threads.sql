-- Deploy side7v5:forum_threads to mysql
-- requires: appuser
-- requires: forum_groups

BEGIN;

CREATE TABLE `forum_threads` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `forum_group_id` bigint(20) unsigned NOT NULL DEFAULT '0' REFERENCES forum_groups(id),
  `name` varchar(255) NOT NULL DEFAULT '',
  `thread_status_id` bigint(20) unsigned NOT NULL DEFAULT '1' REFERENCES forum_thread_statuses(id),
  `start_date` datetime NOT NULL DEFAULT NOW(),
  `user_id` bigint(20) unsigned NOT NULL DEFAULT '0' REFERENCES users(id),
  `thread_type_id` bigint(20) unsigned NOT NULL DEFAULT '1' REFERENCES forum_thread_types(id),
  `original_forum_group_id` bigint(20) unsigned DEFAULT NULL REFERENCES forum_groups(id),
  PRIMARY KEY (`id`),
  KEY `forum_group_id` (`forum_group_id`),
  KEY `user_id` (`user_id`),
  KEY `thread_type_id` (`thread_type_id`),
  KEY `thread_status_id` (`thread_status_id`),
  KEY `original_forum_group_id` (`original_forum_group_id`),
  INDEX `thread_type_status_idx` (`id`, `thread_type_id`, `thread_status_id`)
) ENGINE=MyISAM AUTO_INCREMENT=1 DEFAULT CHARSET=latin1 COMMENT='Forums Threads - Groups Posts';

COMMIT;
