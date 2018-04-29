package Side7::Util::Image;

use strict;
use warnings;

use Dancer2 appname => 'Side7';

use Side7::Util::File;
use Image::Magick;

use version; our $VERSION = qv( '0.1.0' );


=head1 NAME

Side7::Util::Image;


=head1 DESCRIPTION

Supplies tools and functionality for manipulating images.


=head1 FUNCTIONS


=head2 create_thumbnail()

Creates a square thumbnail from an original image. Returns a hashref containing success and message.

Parameters:

=over 4

=item Input:

=over 4

=item C<source> string containing the path to the source file.

=item C<thumbnail> string containing the path and filename of the thumbnail to be created.

=item C<size> integer indicating the size in pixels of each side (assumes a square thumbnail). Defaults to '200';

=back

=item Output:

=over 4

=item hashref containing C<success> (boolean) and C<message> (string).

=back

=back

  $result = Side7::Util::Image::create_thumbnail( source => $spath, thumbnail => $tpath, size => 100 );

=cut

sub create_thumbnail
{
  my %params = @_;
  my $source    = delete $params{'source'}    // undef;
  my $thumbnail = delete $params{'thumbnail'} // undef;
  my $size      = delete $params{'size'}      // 200;

  return { success => 0, message => 'No source path provided.' }    if ! defined $source;
  return { success => 0, message => 'No thumbnail path provided.' } if ! defined $thumbnail;

  my $img = new Image::Magick;
  $img->Read( $source );

  # Get attributes
  my ( $height, $width, $mime ) = $img->Get( 'height', 'width', 'mime' );

  # Scale so that the smallest size = the thumbnail size.
  if ( $height < $width )
  {
    $img->Resize( geometry => "x$size" );
  }
  else
  {
    $img->Resize( geometry => $size );
  }

  # Crop the image to a square.
  $img->Set( Gravity => 'Center' );
  $img->Crop( geometry => $size.'x'.$size );
  $img->Set( size => $size.'x'.$size );
  $img->Write( filename => $thumbnail );

  if ( ! -e $thumbnail )
  {
    return { success => 0, message => 'Failed to write thumbnail file to filesystem.' };
  }

  return { success => 1 };
}


=head2 crop_image()

Creates a square image from an original image. Returns a hashref containing success and message.

Parameters:

=over 4

=item Input:

=over 4

=item C<source> string containing the path to the source file.

=item C<size> integer indicating the size in pixels of each side (assumes a square thumbnail). Defaults to '200';

=back

=item Output:

=over 4

=item hashref containing C<success> (boolean) and C<message> (string).

=back

=back

  $result = Side7::Util::Image::crop_image( source => $spath );

=cut

sub crop_image
{
  my %params = @_;
  my $source = delete $params{'source'} // undef;

  return { success => 0, message => 'No source path provided.' } if ! defined $source;

  my $img = new Image::Magick;
  $img->Read( $source );

  # Get attributes
  my ( $height, $width, $mime ) = $img->Get( 'height', 'width', 'mime' );

  # Scale so that the smallest size = the side of the square.
  my $size = ( $height < $width ) ? $height : $width;

  # Crop the image to a square.
  $img->Set( Gravity => 'Center' );
  $img->Crop( geometry => $size.'x'.$size );
  $img->Write( filename => $source );

  if ( ! -e $source )
  {
    return { success => 0, message => 'Failed to write cropped image file to filesystem.' };
  }

  return { success => 1 };
}


=head1 COPYRIGHT

All code is Copyright (C) Side 7 1992 - 2018

=cut

1;
