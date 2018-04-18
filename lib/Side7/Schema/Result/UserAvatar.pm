package Side7::Schema::Result::UserAvatar;

use strict;
use warnings;

# Third Party modules
use base 'DBIx::Class::Core';
use DateTime;
our $VERSION = '1.0';


=head1 NAME

Side7::Schema::Result::UserAvatar


=head1 AUTHOR

Jason Lamey L<email:jasonlamey@gmail.com>


=head1 SYNOPSIS AND USAGE

This module represents the UserAvatar object in the web app, as well as the interface to the C<user_avatars> table in the database.

=cut

__PACKAGE__->table( 'user_avatars' );
__PACKAGE__->add_columns(
                          id =>
                            {
                              data_type         => 'integer',
                              size              => 20,
                              is_nullable       => 0,
                              is_auto_increment => 1,
                            },
                          user_id =>
                            {
                              data_type         => 'integer',
                              size              => 20,
                              is_nullable       => 0,
                            },
                          filename =>
                            {
                              data_type         => 'varchar',
                              size              => 255,
                              is_nullable       => 0,
                            },
                          title =>
                            {
                              data_type         => 'varchar',
                              size              => 255,
                              is_nullable       => 1,
                              default_value     => undef,
                            },
                          created_at =>
                            {
                              data_type         => 'datetime',
                              is_nullable       => 0,
                              default_value     => DateTime->now( time_zone => 'UTC' )->datetime,
                            },
                          updated_at =>
                            {
                              data_type         => 'datetime',
                              is_nullable       => 0,
                              default_value     => DateTime->now( time_zone => 'UTC' )->datetime,
                            },
                        );

__PACKAGE__->set_primary_key( 'id' );

__PACKAGE__->belongs_to( 'user' => 'Side7::Schema::Result::User', 'user_id' );


=head1 METHODS


=head2 uri_path()

Returns the URI path to the location of the avatar image.

=over 4

=item Input: None.

=item Output: String: avatar URI.

=back

  $path = $avatar->uri_path;

=cut

sub uri_path
{
  my ( $self ) = @_;

  return sprintf( '%s/avatars/%s', $self->user->dirpath, $self->filename );
}


=head1 COPYRIGHT & LICENSE

Copyright 2018, Side 7 L<http://www.side7.com>
All rights reserved.

=cut

1;
