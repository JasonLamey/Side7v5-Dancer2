-- Deploy side7v5:admin_logs to mysql
-- requires: appuser

BEGIN;

CREATE TABLE `admin_logs` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `admin` varchar(255) NOT NULL DEFAULT 'Unknown',
  `ip_address` varchar(255) NOT NULL DEFAULT 'Unknown',
  `log_level` enum('Info','Warning','Error','Debug') NOT NULL DEFAULT 'Info',
  `log_message` text NOT NULL,
  `created_on` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=latin1;

COMMIT;
