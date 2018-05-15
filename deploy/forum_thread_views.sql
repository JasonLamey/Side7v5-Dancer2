-- Deploy side7v5:forum_thread_views to mysql
-- requires: appuser
-- requires: forum_threads

BEGIN;

CREATE TABLE `forum_thread_views` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `forum_thread_id` bigint(20) unsigned NOT NULL DEFAULT '0',
  `view_count` bigint(20) unsigned NOT NULL DEFAULT '0',
  `last_viewed` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `forum_thread_id` (`forum_thread_id`),
  KEY `view_count` (`view_count`),
  KEY `last_viewed` (`last_viewed`)
) ENGINE=MyISAM AUTO_INCREMENT=1 DEFAULT CHARSET=latin1 COMMENT='View counter for the forum threads.';

COMMIT;
