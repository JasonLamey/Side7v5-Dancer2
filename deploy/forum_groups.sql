-- Deploy side7v5:forum_groups to mysql
-- requires: appuser
-- requires: forum_categories

BEGIN;

CREATE TABLE `forum_groups` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `forum_category_id` bigint(20) unsigned NOT NULL DEFAULT '0',
  `name` varchar(255) NOT NULL DEFAULT '',
  `description` text,
  `sort_order` bigint(20) unsigned NOT NULL DEFAULT '0',
  `view_access` enum('Any','Registered','User Group','Moderator','Admin') NOT NULL DEFAULT 'Any',
  `read_access` enum('Any','Registered','User Group','Moderator','Admin') NOT NULL DEFAULT 'Any',
  `post_access` enum('Any','Registered','User Group','Moderator','Admin') NOT NULL DEFAULT 'Registered',
  `reply_access` enum('Any','Registered','User Group','Moderator','Admin') NOT NULL DEFAULT 'Registered',
  `edit_access` enum('Any','Registered','User Group','Moderator','Admin') NOT NULL DEFAULT 'Registered',
  `poll_access` enum('Any','Registered','User Group','Moderator','Admin') NOT NULL DEFAULT 'Registered',
  `attach_access` enum('Any','Registered','User Group','Moderator','Admin') NOT NULL DEFAULT 'Registered',
  PRIMARY KEY (`id`),
  KEY `forum_category_id` (`forum_category_id`),
  KEY `sort_order` (`sort_order`)
) ENGINE=MyISAM AUTO_INCREMENT=1 DEFAULT CHARSET=latin1 COMMENT='Forums Groups - Contains Threads';

COMMIT;
