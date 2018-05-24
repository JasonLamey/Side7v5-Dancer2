package Side7::Schema::Result::ForumLastViewed;

use base 'DBIx::Class::Core';

use strict;
use warnings;

use DateTime;
use version; our $VERSION = qv( "v0.1.0" );


=head1 NAME

Side7::Schema::Result::ForumLastViewed


=head1 DESCRIPTION AND USAGE

Database object representing ForumLastViewed entries within the web app.

=cut


__PACKAGE__->table( 'forum_last_viewed' );
__PACKAGE__->add_columns(
                            id =>
                                {
                                    accessor          => 'last_viewed_id',
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
                            timestamp =>
                                {
                                    data_type         => 'datetime',
                                    is_nullable       => 0,
                                    default_value     => DateTime->now( time_zone => 'UTC' )->datetime,
                                },
                            updates =>
                                {
                                    data_type         => 'integer',
                                    size              => 20,
                                    is_nullable       => 0,
                                    default_value     => 0,
                                },
                        );

__PACKAGE__->set_primary_key( 'id' );

__PACKAGE__->belongs_to( 'thread',          'Side7::Schema::Result::ForumThread', { 'foreign.id' => 'self.forum_thread_id' } );
__PACKAGE__->belongs_to( 'user',            'Side7::Schema::Result::User',        { 'foreign.id' => 'self.user_id' } );


=head1 AUTHOR

Jason Lamey E<lt>jasonlamey@gmail.comE<gt>


=head1 COPYRIGHT AND LICENSE

Copyright 2018 by Jason Lamey

This library is for use by Side7. It is not intended for redistribution
or use by other parties without express written permission.

=cut

1;
