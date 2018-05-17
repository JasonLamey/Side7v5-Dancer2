package Side7::Schema::Result::ForumGroup;

use base 'DBIx::Class::Core';

use strict;
use warnings;

use Dancer2 appname => 'Side7';

use DateTime;
use version; our $VERSION = qv( "v0.1.0" );


=head1 NAME

Side7::Schema::Result::ForumGroup


=head1 DESCRIPTION AND USAGE

Database object representing ForumGroup entries within the web app.

=cut

__PACKAGE__->table( 'forum_groups' );
__PACKAGE__->add_columns(
                            id =>
                                {
                                    accessor          => 'group_id',
                                    data_type         => 'integer',
                                    size              => 20,
                                    is_nullable       => 0,
                                    is_auto_increment => 1,
                                },
                            forum_category_id =>
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
                            sort_order =>
                                {
                                    data_type         => 'varchar',
                                    size              => 255,
                                    is_nullable       => 0,
                                },
                            description =>
                                {
                                    data_type         => 'text',
                                    is_nullable       => 1,
                                },
                            view_access =>
                                {
                                    data_type         => 'enum',
                                    default_value     => 'Any',
                                    is_nullable       => 0,
                                    is_enum           => 1,
                                    extra =>
                                    {
                                      list => [ 'Any', 'Registered', 'User Group', 'Moderator', 'Admin' ]
                                    },
                                },
                            read_access =>
                                {
                                    data_type         => 'enum',
                                    default_value     => 'Any',
                                    is_nullable       => 0,
                                    is_enum           => 1,
                                    extra =>
                                    {
                                      list => [ 'Any', 'Registered', 'User Group', 'Moderator', 'Admin' ]
                                    },
                                },
                            post_access =>
                                {
                                    data_type         => 'enum',
                                    default_value     => 'Any',
                                    is_nullable       => 0,
                                    is_enum           => 1,
                                    extra =>
                                    {
                                      list => [ 'Any', 'Registered', 'User Group', 'Moderator', 'Admin' ]
                                    },
                                },
                            reply_access =>
                                {
                                    data_type         => 'enum',
                                    default_value     => 'Any',
                                    is_nullable       => 0,
                                    is_enum           => 1,
                                    extra =>
                                    {
                                      list => [ 'Any', 'Registered', 'User Group', 'Moderator', 'Admin' ]
                                    },
                                },
                            edit_access =>
                                {
                                    data_type         => 'enum',
                                    default_value     => 'Any',
                                    is_nullable       => 0,
                                    is_enum           => 1,
                                    extra =>
                                    {
                                      list => [ 'Any', 'Registered', 'User Group', 'Moderator', 'Admin' ]
                                    },
                                },
                            poll_access =>
                                {
                                    data_type         => 'enum',
                                    default_value     => 'Any',
                                    is_nullable       => 0,
                                    is_enum           => 1,
                                    extra =>
                                    {
                                      list => [ 'Any', 'Registered', 'User Group', 'Moderator', 'Admin' ]
                                    },
                                },
                            attach_access =>
                                {
                                    data_type         => 'enum',
                                    default_value     => 'Any',
                                    is_nullable       => 0,
                                    is_enum           => 1,
                                    extra =>
                                    {
                                      list => [ 'Any', 'Registered', 'User Group', 'Moderator', 'Admin' ]
                                    },
                                },
                        );

__PACKAGE__->set_primary_key( 'id' );

__PACKAGE__->belongs_to( 'category', 'Side7::Schema::Result::ForumCategory', 'forum_category_id' );

__PACKAGE__->has_many( 'threads',       'Side7::Schema::Result::ForumThread', 'forum_group_id' );
__PACKAGE__->has_many( 'moved_threads', 'Side7::Schema::Result::ForumThread', 'original_forum_group_id' );


=head1 METHODS


=head2 most_recent_post()

Returns the most recent post object for a group.

=over4

=item Input: none.

=item Output: ForumPost object.

=back

  my $mrp = $group->most_recent_post();

=cut

sub most_recent_post
{
  my $self = shift;

  my $post = $self->threads->search_related( 'posts', {}, { order_by => { -desc => 'timestamp' } } )->first;

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
