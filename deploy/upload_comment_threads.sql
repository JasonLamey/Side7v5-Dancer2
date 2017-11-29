-- Deploy side7v5:upload_comment_threads to mysql
-- requires: user_uploads
-- requires: users
-- requires: appuser

BEGIN;

CREATE TABLE `upload_comment_threads` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `upload_id` bigint(20) unsigned NOT NULL,
  `creator_id` bigint(20) unsigned NOT NULL,
  `created_on` datetime NOT NULL DEFAULT NOW(),
  PRIMARY KEY (`id`),
  KEY `upload_id` (`upload_id`),
  KEY `creator_id` (`creator_id`),
  KEY `created_on` (`created_on`)
) ENGINE=MyISAM AUTO_INCREMENT=1 DEFAULT CHARSET=latin1 COMMENT='Comment Threads On User Uploads';

COMMIT;
