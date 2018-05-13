package Side7::Schema::Result::ForumPost;

use base 'DBIx::Class::Core';

use strict;
use warnings;

use DateTime;
use version; our $VERSION = qv( "v0.1.0" );


=head1 NAME

Side7::Schema::Result::ForumPost


=head1 DESCRIPTION AND USAGE

Database object representing ForumPost entries within the web app.

=cut



__PACKAGE__->table( 'forum_posts' );
__PACKAGE__->add_columns(
                            id =>
                                {
                                    accessor          => 'post_id',
                                    data_type         => 'integer',
                                    size              => 20,
                                    is_nullable       => 0,
                                    is_auto_increment => 1,
                                },
                            forum_thread_id =>
                                {
                                    data_type         => 'integer',
                                    size              => 20,
                                    is_nullable       => 0,
                                },
                            user_id =>
                                {
                                    data_type         => 'integer',
                                    size              => 20,
                                    is_nullable       => 0,
                                },
                            subject =>
                                {
                                    data_type         => 'varchar',
                                    size              => 255,
                                    is_nullable       => 0,
                                },
                            body =>
                                {
                                    data_type         => 'text',
                                    is_nullable       => 0,
                                },
                            show_signature =>
                                {
                                    data_type         => 'boolean',
                                    is_nullable       => 0,
                                    default_value     => 1,
                                },
                            timestamp =>
                                {
                                    data_type         => 'datetime',
                                    is_nullable       => 0,
                                    default_value     => DateTime->now( time_zone => 'UTC' )->datetime,
                                },
                             last_modified_date =>
                                {
                                    data_type         => 'timestampe',
                                    is_nullable       => 1,
                                    default_value     => DateTime->now( time_zone => 'UTC' )->datetime,
                                },
                            modified_count =>
                                {
                                    data_type         => 'integer',
                                    size              => 20,
                                    is_nullable       => 0,
                                    default_value     => 0,
                                },
                            ip_address =>
                                {
                                    data_type         => 'varchar',
                                    size              => 255,
                                    is_nullable       => 0,
                                },
                            original_forum_thread_id =>
                                {
                                    data_type         => 'integer',
                                    size              => 20,
                                    is_nullable       => 0,
                                },
                        );

__PACKAGE__->set_primary_key( 'id' );

__PACKAGE__->belongs_to( 'thread', 'Side7::Schema::Result::ForumThread', 'forum_thread_id' );
__PACKAGE__->belongs_to( 'thread', 'Side7::Schema::Result::ForumThread', 'original_forum_thread_id' );
__PACKAGE__->belongs_to( 'user',   'Side7::Schema::Result::User',        'user_id' );


=head1 AUTHOR

Jason Lamey E<lt>jasonlamey@gmail.comE<gt>


=head1 COPYRIGHT AND LICENSE

Copyright 2018 by Jason Lamey

This library is for use by Side7. It is not intended for redistribution
or use by other parties without express written permission.

=cut

1;
