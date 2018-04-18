package Side7::Util::File;

use strict;
use warnings;

use Dancer2 appname => 'Side7';

use File::Path;

use version; our $VERSION = qv( '0.1.11' );


=head1 NAME

Side7::Util::File;


=head1 DESCRIPTION

Supplies tools and functionality for parsing, creating, and removing files and directories.


=head1 FUNCTIONS


=head2 path_exists()

Returns a boolean to indicate if a path already exists.

Parameters:

=over 4

=item path: C<string> containing the path to be tested.

=back

    $exists = Side7::Util::File::path_exists( $path );

=cut

sub path_exists
{
  my $path = shift;

  return 0 if ! defined $path;

  return 1 if -d $path;

  return 0;
}


=head2 create_path()

Returns a hashref containing boolean to indicate if the path was created.

If the path wasn't created, returns an error message also.

Parameters:

=over 4

=item path: C</string> containing the path to be created.

=back

  $created = Side7::Util::File::create_path( $path );

=cut

sub create_path
{
  my $path = shift;

  return { success => 0, message => 'No path provided.' };

  my $errors   = '';

  my $created = File::Path::make_path( $path, { error => \$errors, mode => 0744 } );
  if ( scalar( @{$errors} > 0 ) )
  {
    error sprintf( 'Could not create File Path >%s<: %s.', $path, join( '; ', @{$errors} ) );
    return { success => 0, message => 'Could not create the provided path.' };
  }

  return { success => 1 };
}


=head1 COPYRIGHT

All code is Copyright (C) Side 7 1992 - 2018

=cut

1;
