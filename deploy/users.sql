-- Deploy side7v5:users to mysql
-- requires: appuser

BEGIN;

CREATE TABLE `users` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `username` varchar(45) CHARACTER SET latin1 NOT NULL,
  `email_address` varchar(255) CHARACTER SET latin1 NOT NULL DEFAULT 'no set',
  `password` varchar(150) CHARACTER SET latin1,
  `referred_by` varchar(45) COLLATE utf8_unicode_ci DEFAULT NULL,
  `first_name` varchar(45) COLLATE utf8_unicode_ci DEFAULT NULL,
  `last_name` varchar(45) COLLATE utf8_unicode_ci DEFAULT NULL,
  `user_status_id` int(1) unsigned NOT NULL DEFAULT '1',
  `biography` text COLLATE utf8_unicode_ci,
  `gender_id` int(3) unsigned NOT NULL DEFAULT '1',
  `birthday` date,
  `birthday_visibility` enum('Private','Hide Year','Public') NOT NULL DEFAULT 'Private',
  `state` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `country_id` int(3) unsigned NOT NULL DEFAULT '1',
  `avatar_type` enum('None','System','Image','Gravatar') COLLATE utf8_unicode_ci NOT NULL DEFAULT 'None',
  `avatar_id` bigint(20) unsigned DEFAULT NULL,
  `confirmed` tinyint(1) unsigned NOT NULL DEFAULT '0',
  `confirm_code` varchar(40) DEFAULT NULL,
  `lastlogin` datetime DEFAULT NULL,
  `pw_changed` datetime DEFAULT NULL,
  `pw_reset_code` varchar(255) DEFAULT NULL,
  `user_type_expires_on` date DEFAULT NULL,
  `reinstate_on` date DEFAULT NULL,
  `delete_on` date DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT NOW(),
  `updated_at` timestamp DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `username` (`username`),
  UNIQUE KEY `email_address` (`email_address`),
  KEY `user_status_id` (`user_status_id`),
  KEY `gender_id` (`gender_id`),
  KEY `country_id` (`country_id`),
  KEY `confirm_code` (`confirm_code`),
  KEY `referred_by` (`referred_by`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci COMMENT='User accounts';

COMMIT;
