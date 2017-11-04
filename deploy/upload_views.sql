-- Deploy side7v5:upload_views to mysql
-- requires: user_uploads
-- requires: appuser

BEGIN;

CREATE TABLE `upload_views` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `upload_id` bigint(20) unsigned NOT NULL,
  `views` bigint(20) unsigned NOT NULL,
  `date` date NOT NULL,
  PRIMARY KEY (`id`),
  KEY `upload_id` (`upload_id`),
  KEY `view_date` (`date`),
  KEY `upload_id_date` (`upload_id`,`date`)
) ENGINE=MyISAM AUTO_INCREMENT=1 DEFAULT CHARSET=latin1 COMMENT='Upload view counts';

COMMIT;
