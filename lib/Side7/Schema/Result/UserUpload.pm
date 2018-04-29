package Side7::Schema::Result::UserUpload;

use strict;
use warnings;

# Third Party modules
use base 'DBIx::Class::Core';
use DateTime;
use Cwd;
use Date::Manip;
use Time::Duration;
our $VERSION = '1.5';


=head1 NAME

Side7::Schema::Result::UserUpload


=head1 AUTHOR

Jason Lamey L<email:jasonlamey@gmail.com>


=head1 SYNOPSIS AND USAGE

This module represents the UserUpload object in the web app, as well as the interface to the C<user_uploads> table in the database.

=cut

__PACKAGE__->table( 'user_uploads' );
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
                          upload_type_id =>
                            {
                              data_type         => 'integer',
                              size              => 3,
                              is_nullable       => 0,
                            },
                          filename =>
                            {
                              data_type         => 'varchar',
                              size              => 255,
                              is_nullable       => 0,
                            },
                          filesize =>
                            {
                              data_type         => 'integer',
                              size              => 10,
                              is_nullable       => 0,
                            },
                          upload_category_id =>
                            {
                              data_type         => 'integer',
                              size              => 10,
                              is_nullable       => 0,
                            },
                          upload_rating_id =>
                            {
                              data_type         => 'integer',
                              size              => 10,
                              is_nullable       => 0,
                            },
                          upload_class_id =>
                            {
                              data_type         => 'integer',
                              size              => 10,
                              is_nullable       => 0,
                            },
                          title =>
                            {
                              data_type         => 'varchar',
                              size              => 255,
                              is_nullable       => 0,
                            },
                          description =>
                            {
                              data_type         => 'text',
                              is_nullable       => 1,
                              default_value     => undef,
                            },
                          views =>
                            {
                              data_type         => 'integer',
                              size              => 10,
                              is_nullable       => 0,
                              default_value     => 0,
                            },
                          uploaded_on =>
                            {
                              data_type         => 'datetime',
                              is_nullable       => 0,
                              default_value     => DateTime->now( time_zone => 'UTC' )->datetime,
                            },
                        );

__PACKAGE__->set_primary_key( 'id' );

__PACKAGE__->belongs_to( 'user'            => 'Side7::Schema::Result::User',           'user_id' );
__PACKAGE__->belongs_to( 'upload_type'     => 'Side7::Schema::Result::UploadType',     'upload_type_id' );
__PACKAGE__->belongs_to( 'upload_category' => 'Side7::Schema::Result::UploadCategory', 'upload_category_id' );
__PACKAGE__->belongs_to( 'upload_rating'   => 'Side7::Schema::Result::UploadRating',   'upload_rating_id' );
__PACKAGE__->belongs_to( 'upload_class'    => 'Side7::Schema::Result::UploadClass',    'upload_class_id' );

__PACKAGE__->has_many( 'view_records'      => 'Side7::Schema::Result::UploadView',          'upload_id' );
__PACKAGE__->has_many( 'comment_threads'   => 'Side7::Schema::Result::UploadCommentThread', 'upload_id', { order_by => 'created_on' } );
__PACKAGE__->has_many( 'uploadqualifiers'  => 'Side7::Schema::Result::UploadQualifier',     'upload_id' );

__PACKAGE__->many_to_many( 'rating_qualifiers' => 'uploadqualifiers', 'upload' );

=head1 METHODS


=head2 filepath()

Returns the full filepath to the upload's file.

=over 4

=item Input: None.

=item Output: String containing the full filepath to the upload file.

=back

  my $filepath = $upload->filepath;

=cut

sub filepath
{
  my ( $self ) = @_;

  my $app_path  = Cwd::getcwd();

  return sprintf( '/data/galleries%s/%s', $self->user->dirpath, $self->filename );
}


=head2 uri()

Returns a string containing the URI path to the image.

=over 4

=item Input: None.

=item Output: String containing the URI.

=back

  my $uri = $upload->uri;

=cut

sub uri
{
  my $self = shift;

  return sprintf( '/galleries%s/%s', $self->user->dirpath, $self->filename );
}


=head2 thumbpath()

Returns a string to the upload's thumbnail filepath.

=over 4

=item Input: None.

=item Output: String containing the filepath.

=back

  my $uri = $upload->thumbpath;

=cut

sub thumbpath
{
  my $self = shift;

  return sprintf( '/data/galleries%s/%s', $self->user->upload_thumb_path, $self->filename );
}


=head2 thumburi()

Returns a string to the upload's thumbnail URI.

=over 4

=item Input: None.

=item Output: String containing the URI to the thumbnail.

=back

  my $uri = $upload->thumburi;

=cut

sub thumburi
{
  my $self = shift;

  return sprintf( '/galleries%s/%s', $self->user->upload_thumb_path, $self->filename );
}


=head2 check_thumbnail()

Checks for the existence of the thumbnail. If one doesn't exist, it attempts to make one, if needed.

=over 4

=item Input: None.

=item Output: Boolean indicating if the thumbnail exists or not.

=back

  my $is_good = $upload->check_thumbnail();

=cut

sub check_thumbnail
{
  my $self = shift;

  if ( $self->upload_type->type eq 'Image' )
  {
    if ( ! -e $self->thumbpath )
    {
      warn sprintf( 'Need to make image thumbnail for %s by %s.', $self->title, $self->user->username );
      my $created = Side7::Util::Image::create_thumbnail( source => $self->filepath, thumbnail => $self->thumbpath );
      if ( $created->{'success'} < 1 )
      {
        warn sprintf('Could not create thumbnail file: %s >%s<', $self->thumbpath, $created->{'message'} );
        return 0;
      }
    }

    return 1;
  }
}


=head2 age()

Returns the age of a submission in years, months, days, hours, minutes, colloquially.

=over 4

=item Input: None.

=item Output: String containing the age of the submission.

=back

  my $age = $upload->age;

=cut

sub age
{
  my ( $self ) = @_;

  my $now = DateTime->now( time_zone => 'UTC' )->datetime;

  my @seconds = map Date::Manip::UnixDate( $_, '%s'), $now, $self->uploaded_on;
  my $delta = ( $seconds[0] - $seconds[1] );

  return Time::Duration::ago( $delta, 2 );
}


=head1 COPYRIGHT & LICENSE

Copyright 2017-2018, Side 7 L<http://www.side7.com>
All rights reserved.

=cut

1;
