-- Deploy side7v5:news to mysql
-- requires: users
-- requires: appuser

BEGIN;

CREATE TABLE `news` (
  `id` smallint(5) unsigned NOT NULL AUTO_INCREMENT,
  `posted_on` datetime DEFAULT NULL,
  `expires_on` date DEFAULT NULL,
  `title` varchar(255) NOT NULL DEFAULT '',
  `article` text,
  `news_type` enum('Standard','Announcement') NOT NULL DEFAULT 'Standard',
  `user_id` bigint(20) unsigned NOT NULL DEFAULT '0',
  `views` int(10) unsigned DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `posted_on` (`posted_on`),
  KEY `expires_on` (`expires_on`),
  KEY `news_type` (`news_type`)
) ENGINE=MyISAM AUTO_INCREMENT=1 DEFAULT CHARSET=latin1 COMMENT='Site news, including title and full article.';

COMMIT;
