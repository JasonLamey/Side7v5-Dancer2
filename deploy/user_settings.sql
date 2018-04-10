-- Deploy side7v5:user_settings to mysql
-- requires: appuser
-- requires: users

BEGIN;

CREATE TABLE user_settings
(
  id                       BIGINT(20) UNSIGNED NOT NULL PRIMARY KEY AUTO_INCREMENT,
  user_id                  BIGINT(20) UNSIGNED NOT NULL,
  show_online_status       TINYINT(1) UNSIGNED NOT NULL DEFAULT 1,
  allow_museum_adds        TINYINT(1) UNSIGNED NOT NULL DEFAULT 1,
  allow_friend_requests    TINYINT(1) UNSIGNED NOT NULL DEFAULT 1,
  allow_user_contact       TINYINT(1) UNSIGNED NOT NULL DEFAULT 1,
  allow_add_to_favorites   TINYINT(1) UNSIGNED NOT NULL DEFAULT 1,
  show_social_links        TINYINT(1) UNSIGNED NOT NULL DEFAULT 1,
  filter_categories        varchar(255) NULL DEFAULT NULL,
  filter_ratings           varchar(255) NULL DEFAULT NULL,
  show_m_thumbnails        TINYINT(1) UNSIGNED NOT NULL DEFAULT 0,
  show_adult_content       TINYINT(1) UNSIGNED NOT NULL DEFAULT 0,
  email_notifications      TINYINT(1) UNSIGNED NOT NULL DEFAULT 1,
  notify_on_pm             TINYINT(1) UNSIGNED NOT NULL DEFAULT 1,
  notify_on_comment        TINYINT(1) UNSIGNED NOT NULL DEFAULT 1,
  notify_on_friend_request TINYINT(1) UNSIGNED NOT NULL DEFAULT 1,
  notify_on_mention        TINYINT(1) UNSIGNED NOT NULL DEFAULT 1,
  notify_on_favorite       TINYINT(1) UNSIGNED NOT NULL DEFAULT 1,
  notify_on_museum_add     TINYINT(1) UNSIGNED NOT NULL DEFAULT 1,
  updated_on DATETIME NOT NULL DEFAULT NOW()
);

COMMIT;
