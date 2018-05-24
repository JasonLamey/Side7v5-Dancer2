package Side7::Schema::Result::ForumPostsLatestView;

use strict;
use warnings;

use base qw/DBIx::Class::Core/;

__PACKAGE__->table_class('DBIx::Class::ResultSource::View');

__PACKAGE__->table( 'forum_posts_latest_view' );

__PACKAGE__->result_source_instance->is_virtual(1);

__PACKAGE__->result_source_instance->view_definition(
  q[
    SELECT t.id AS thread_id, t.name, p.timestamp, p.id AS post_id, u.username, 0 AS last_page
    FROM forum_threads t
    LEFT JOIN forum_posts p
    ON p.id = (
                SELECT id
                FROM forum_posts pi
                WHERE pi.forum_thread_id = t.id
                ORDER BY timestamp DESC LIMIT 1
              )
    LEFT JOIN users u
    ON u.id = p.user_id
    ORDER BY p.timestamp DESC
    LIMIT 5
  ]
);

__PACKAGE__->add_columns(
                            thread_id =>
                                {
                                    accessor          => 'thread_id',
                                    data_type         => 'integer',
                                    size              => 20,
                                    is_nullable       => 0,
                                    is_auto_increment => 0,
                                },
                            post_id =>
                                {
                                    data_type         => 'integer',
                                    size              => 20,
                                    is_nullable       => 0,
                                },
                            name =>
                                {
                                    data_type         => 'varchar',
                                    size              => 255,
                                    is_nullable       => 0,
                                },
                            username =>
                                {
                                    data_type         => 'varchar',
                                    size              => 255,
                                    is_nullable       => 0,
                                },
                            timestamp =>
                                {
                                    data_type         => 'datetime',
                                    is_nullable       => 0,
                                    default_value     => DateTime->now( time_zone => 'UTC' )->datetime,
                                },
                            last_page =>
                                {
                                    data_type         => 'integer',
                                    size              => 3,
                                    is_nullable       => 1,
                                    default_value     => 0,
                                },
);

__PACKAGE__->set_primary_key( 'thread_id' );
