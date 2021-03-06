package Side7::Schema::Result::User;

use strict;
use warnings;

use Side7::Schema;
use Side7::Schema::Result::SystemAvatar;

# Third Party modules
use base 'DBIx::Class::Core';
use DateTime;
use File::Path;
use Gravatar::URL;
our $VERSION = '1.0';

our $SCHEMA = Side7::Schema->db_connect();


=head1 NAME

Side7::Schema::Result::User


=head1 AUTHOR

Jason Lamey L<email:jasonlamey@gmail.com>


=head1 SYNOPSIS AND USAGE

This module represents the User object in the web app, as well as the interface to the C<users> table in the database.

=cut

__PACKAGE__->table( 'users' );
__PACKAGE__->add_columns(
                          id =>
                            {
                              accessor          => 'user',
                              data_type         => 'integer',
                              size              => 20,
                              is_nullable       => 0,
                              is_auto_increment => 1,
                            },
                          username =>
                            {
                              data_type         => 'varchar',
                              size              => 45,
                              is_nullable       => 0,
                            },
                          first_name =>
                            {
                              data_type         => 'varchar',
                              size              => 45,
                              is_nullable       => 1,
                              default_value     => undef,
                            },
                          last_name =>
                            {
                              data_type         => 'varchar',
                              size              => 45,
                              is_nullable       => 1,
                              default_value     => undef,
                            },
                          password =>
                            {
                              data_type         => 'varchar',
                              size              => 150,
                              is_nullable       => 1,
                              default_value     => undef,
                            },
                          birthday =>
                            {
                              data_type         => 'date',
                              is_nullable       => 1,
                              default_value     => undef,
                            },
                          birthday_visibility =>
                            {
                              data_type         => 'enum',
                              is_nullable       => 0,
                              default_value     => 'Private',
                              is_enum           => 1,
                              extra             =>
                              {
                                list            => [ 'Private', 'Hide Year', 'Public' ],
                              },
                            },
                          email_address =>
                            {
                              data_type         => 'varchar',
                              size              => 255,
                              is_nullable       => 0,
                              default_value     => 'not set',
                            },
                          referred_by =>
                            {
                              data_type         => 'varchar',
                              size              => 45,
                              is_nullable       => 1,
                              default_value     => undef,
                            },
                          user_status_id =>
                            {
                              data_type         => 'integer',
                              size              => 1,
                              is_nullable       => 0,
                              default_value     => 1,
                            },
                          biography =>
                            {
                              data_type         => 'text',
                              is_nullable       => 1,
                              default_value     => undef,
                            },
                          gender_id =>
                            {
                              data_type         => 'integer',
                              size              => 1,
                              is_nullable       => 0,
                              default_value     => 1,
                            },
                          state =>
                            {
                              data_type         => 'varchar',
                              size              => 255,
                              is_nullable       => 1,
                              default_value     => undef,
                            },
                          country_id =>
                            {
                              data_type         => 'integer',
                              size              => 3,
                              is_nullable       => 0,
                              default_value     => 1,
                            },
                          avatar_type =>
                            {
                              data_type         => 'enum',
                              is_nullable       => 0,
                              default_value     => 'None',
                              is_enum           => 1,
                              extra             =>
                              {
                                list            => [ 'None', 'System', 'Image', 'Gravatar' ],
                              },
                            },
                          avatar_id =>
                            {
                              data_type         => 'integer',
                              size              => 20,
                              is_nullable       => 1,
                              default_value     => undef,
                            },
                          confirmed =>
                            {
                              data_type         => 'integer',
                              size              => 1,
                              is_nullable       => 0,
                              default_value     => 0,
                            },
                          confirm_code =>
                            {
                              data_type         => 'varchar',
                              size              => 40,
                              is_nullable       => 1,
                              default_value     => undef,
                            },
                          lastlogin =>
                            {
                              data_type         => 'DateTime',
                              is_nullable       => 1,
                              default_value     => undef,
                            },
                          lastlogin_ip =>
                            {
                              data_type         => 'varchar',
                              is_nullable       => 1,
                              default_value     => undef,
                            },
                          pw_changed =>
                            {
                              data_type         => 'DateTime',
                              is_nullable       => 1,
                              default_value     => undef,
                            },
                          pw_reset_code =>
                            {
                              data_type         => 'varchar',
                              size              => 255,
                              is_nullable       => 1,
                              default_value     => undef,
                            },
                          user_type_expires_on =>
                            {
                              data_type         => 'Date',
                              is_nullable       => 1,
                              default_value     => undef,
                            },
                          reinstate_on =>
                            {
                              data_type         => 'Date',
                              is_nullable       => 1,
                              default_value     => undef,
                            },
                          delete_on =>
                            {
                              data_type         => 'Date',
                              is_nullable       => 1,
                              default_value     => undef,
                            },
                          created_at =>
                            {
                              data_type         => 'DateTime',
                              is_nullable       => 0,
                              default_value     => DateTime->now( time_zone => 'UTC' )->datetime,
                            },
                          updated_at =>
                            {
                              data_type         => 'Timestamp',
                              is_nullable       => 0,
                              default_value     => DateTime->now( time_zone => 'UTC' )->datetime,
                            },
                        );

__PACKAGE__->set_primary_key( 'id' );

__PACKAGE__->might_have( 'news' => 'Side7::Schema::Result::News', 'user_id' );

__PACKAGE__->has_one( 'settings' => 'Side7::Schema::Result::UserSetting', 'user_id' );

__PACKAGE__->has_many( 'uploads'         => 'Side7::Schema::Result::UserUpload',          'user_id' );
__PACKAGE__->has_many( 'userroles'       => 'Side7::Schema::Result::UserRole',            'user_id' );
__PACKAGE__->has_many( 'credits'         => 'Side7::Schema::Result::S7Credit',            'user_id' );
__PACKAGE__->has_many( 'sent_mail'       => 'Side7::Schema::Result::UserMail',            'sender_id' );
__PACKAGE__->has_many( 'received_mail'   => 'Side7::Schema::Result::UserMail',            'recipient_id' );
__PACKAGE__->has_many( 'comment_threads' => 'Side7::Schema::Result::UploadCommentThread', 'creator_id' );
__PACKAGE__->has_many( 'avatars'         => 'Side7::Schema::Result::UserAvatar',          'user_id' );

__PACKAGE__->many_to_many( 'roles' => 'userroles', 'role' );

__PACKAGE__->belongs_to( 'gender'     => 'Side7::Schema::Result::UserGender',   'gender_id' );
__PACKAGE__->belongs_to( 'status'     => 'Side7::Schema::Result::UserStatus',   'user_status_id' );
__PACKAGE__->belongs_to( 'country'    => 'Side7::Schema::Result::Country',      'country_id' );
__PACKAGE__->belongs_to( 'sys_avatar' => 'Side7::Schema::Result::SystemAvatar', 'avatar_id' );


=head1 METHODS


=head2 full_name()

This method returns the user's first and last names as a concatonated string.

=over 4

=item Input: None.

=item Output: A string containing the concatenated values of the first and last names.

=back

  $fullname = $user->full_name;

=cut

sub full_name
{
  my ( $self ) = @_;

  return join( ' ', ( $self->first_name ? $self->first_name : '' ), ( $self->last_name ? $self->last_name : '' ) );
}


=head2 dirpath()

This method returns the user's directory path based on the user's ID.

=over 4

=item Input: None

=item Output: string containing the user's dirpath

=back

  my $dirpath = $user->dirpath();

=cut

sub dirpath
{
  my $self = shift;

  my $path = sprintf( '/%s/%s/%s', substr( $self->id, 0, 1 ), substr( $self->id, 0, 3 ), $self->id );
  my $fullpath = '/data/galleries' . $path;

  unless ( Side7::Util::File::path_exists( $fullpath ) )
  {
    my $created = Side7::Util::File::create_path( $fullpath );

    if ( $created->{'success'} < 1 )
    {
      warn sprintf( 'Error creating User Path >%s<: %s', $fullpath, $created->{'message'} );
      return '';
    }
  }

  return $path;
}


=head2 upload_thumb_path()

Returns a string containing the filepath to the user's thumbnails directory.

=over 4

=item Input: None

=item Output: string containing the user's thumbnail dirpath

=back

  my $dirpath = $user->dirpath();

=cut

sub upload_thumb_path
{
  my $self = shift;

  my $thumb_path = $self->dirpath() . '/thumbnails';
  my $fullpath = '/data/galleries' . $thumb_path;

  unless ( Side7::Util::File::path_exists( $fullpath ) )
  {
    my $created = Side7::Util::File::create_path( $fullpath );

    if ( $created->{'success'} < 1 )
    {
      warn sprintf( 'Error creating User Thumbnail Path >%s<: %s', $fullpath, $created->{'message'} );
      return '';
    }
  }

  return $thumb_path;
}


=head2 new_mail_count()

This method returns the user's count of new mail items.

=over 4

=item Input: None

=item Output: integer representing a count of the number of new mail items.

=back

  my $new_mail_count = $user->new_mail_count();

=cut

sub new_mail_count
{
  my ( $self ) = @_;

  return $self->search_related( 'received_mail', { is_read => 0, is_deleted => 0 } )->count;
}


=head2 avatar()

Returns the uri for the appropriate avatar.

=over 4

=item Input: None

=item Output: String containing the URI to the appropriate avatar.

=back

  my $avatar = $user->avatar();

=cut

sub avatar
{
  my $self = shift;

  if ( uc($self->avatar_type) eq 'NONE' )
  {
    return '/images/defaults/medium/default_avatar.png';
  }

  if ( uc($self->avatar_type) eq 'GRAVATAR' )
  {
    my $url = Gravatar::URL::gravatar_url(
      email   => $self->email_address,
      size    => 100,
      rating  => 'r',
      default => 'identicon',
    );
    return $url;
  }

  if ( uc($self->avatar_type) eq 'SYSTEM' )
  {
    my $avatar = $self->sys_avatar;
    return sprintf( '/images/avatars/%s', $avatar->filename );
  }

  if ( uc($self->avatar_type) eq 'IMAGE' )
  {
    my $avatar = $self->search_related( 'avatars', { id => $self->avatar_id } )->single;
    if ( ! defined $avatar )
    {
      return '/images/defaults/medium/default_avatar.png';
    }
    return sprintf( '/galleries%s/avatars/%s', $self->dirpath, $avatar->filename );
  }
}


=head2 upload_count()

Returns a count of all uploads submitted by this user.

=over 4

=item Input: None

=item Output: integer representing a count of the number of uploaded items.

=back

  my $new_mail_count = $user->new_mail_count();

=cut

sub upload_count
{
  my $self = shift;

  return $self->search_related( 'uploads', {} )->count;
}


=head1 COPYRIGHT & LICENSE

Copyright 2017, Side 7 L<http://www.side7.com>
All rights reserved.

=cut

1;
