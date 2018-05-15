package Side7::Schema::Result::ForumThreadView;

use base 'DBIx::Class::Core';

use strict;
use warnings;

use DateTime;
use version; our $VERSION = qv( "v0.1.0" );


=head1 NAME

Side7::Schema::Result::ForumThreadView


=head1 DESCRIPTION AND USAGE

Database object representing ForumThreadView entries within the web app.

=cut


__PACKAGE__->table( 'forum_thread_views' );
__PACKAGE__->add_columns(
                            id =>
                                {
                                    accessor          => 'thread_id',
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
                            view_count =>
                                {
                                    data_type         => 'integer',
                                    size              => 20,
                                    is_nullable       => 0,
                                },
                            last_viewed =>
                                {
                                    data_type         => 'timestamp',
                                    is_nullable       => 0,
                                    default_value     => DateTime->now( time_zone => 'UTC' )->datetime,
                                },
                        );

__PACKAGE__->set_primary_key( 'id' );
__PACKAGE__->add_unique_constraint( forum_thread_id => [ 'forum_thread_id' ] );

__PACKAGE__->belongs_to( 'thread', 'Side7::Schema::Result::ForumThread', 'forum_thread_id' );


=head1 AUTHOR

Jason Lamey E<lt>jasonlamey@gmail.comE<gt>


=head1 COPYRIGHT AND LICENSE

Copyright 2018 by Jason Lamey

This library is for use by Side7. It is not intended for redistribution
or use by other parties without express written permission.

=cut

1;
