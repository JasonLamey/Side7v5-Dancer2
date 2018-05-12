-- Deploy side7v5:forum_categories to mysql
-- requires: appuser

BEGIN;

CREATE TABLE `forum_categories` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL DEFAULT '',
  `sort_order` bigint(20) unsigned NOT NULL DEFAULT '0',
  `view_access` enum('Any','Registered','User Group','Moderator','Admin') NOT NULL DEFAULT 'Any',
  `read_access` enum('Any','Registered','User Group','Moderator','Admin') NOT NULL DEFAULT 'Any',
  PRIMARY KEY (`id`),
  KEY `sort_order` (`sort_order`),
  KEY `view_access` (`view_access`)
) ENGINE=MyISAM AUTO_INCREMENT=1 DEFAULT CHARSET=latin1 COMMENT='Forum Categories - Contains Groups';

COMMIT;
