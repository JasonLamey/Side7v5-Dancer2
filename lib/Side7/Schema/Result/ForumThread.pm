package Side7::Schema::Result::ForumThread;

use base 'DBIx::Class::Core';

use strict;
use warnings;

use DateTime;
use version; our $VERSION = qv( "v0.1.0" );


=head1 NAME

Side7::Schema::Result::ForumThread


=head1 DESCRIPTION AND USAGE

Database object representing ForumThread entries within the web app.

=cut


__PACKAGE__->table( 'forum_threads' );
__PACKAGE__->add_columns(
                            id =>
                                {
                                    accessor          => 'thread_id',
                                    data_type         => 'integer',
                                    size              => 20,
                                    is_nullable       => 0,
                                    is_auto_increment => 1,
                                },
                            forum_group_id =>
                                {
                                    data_type         => 'integer',
                                    size              => 20,
                                    is_nullable       => 0,
                                },
                            name =>
                                {
                                    data_type         => 'varchar',
                                    size              => 20,
                                    is_nullable       => 0,
                                },
                            thread_status_id =>
                                {
                                    data_type         => 'integer',
                                    size              => 20,
                                    is_nullable       => 0,
                                    default_value     => 1,
                                },
                            start_date =>
                                {
                                    data_type         => 'datetime',
                                    is_nullable       => 0,
                                    default_value     => DateTime->now( time_zone => 'UTC' )->datetime,
                                },
                            user_id =>
                                {
                                    data_type         => 'integer',
                                    size              => 20,
                                    is_nullable       => 0,
                                },
                            thread_type_id =>
                                {
                                    data_type         => 'integer',
                                    size              => 20,
                                    is_nullable       => 0,
                                    default_value     => 1,
                                },
                            original_forum_group_id =>
                                {
                                    data_type         => 'integer',
                                    size              => 20,
                                    is_nullable       => 0,
                                },
                        );

__PACKAGE__->set_primary_key( 'id' );

__PACKAGE__->belongs_to( 'group',          'Side7::Schema::Result::ForumGroup', 'forum_group_id' );
__PACKAGE__->belongs_to( 'original_group', 'Side7::Schema::Result::ForumGroup', 'original_forum_group_id' );
__PACKAGE__->belongs_to( 'user',           'Side7::Schema::Result::User',       'user_id' );

__PACKAGE__->has_many( 'posts',       'Side7::Schema::Result::ForumPost', { 'foreign.forum_thread_id'          => 'self.id' } );
__PACKAGE__->has_many( 'moved_posts', 'Side7::Schema::Result::ForumPost', { 'foreign.original_forum_thread_id' => 'self.id' } );


=head1 METHODS

=head2 most_recent_post()

Returns the most recently made ForumPost object in the thread.

=over 4

=item Input: None.

=item Output: ForumPost object.

=back

  my $mrp = $thread->most_recent_post();

=cut

sub most_recent_post
{
  my $self = shift;

  my $post = $self->search_related( 'posts', {}, { order_by => { -desc => 'timestamp' } } )->first;

  return $post;
}


=head1 AUTHOR

Jason Lamey E<lt>jasonlamey@gmail.comE<gt>


=head1 COPYRIGHT AND LICENSE

Copyright 2018 by Jason Lamey

This library is for use by Side7. It is not intended for redistribution
or use by other parties without express written permission.

=cut

1;
