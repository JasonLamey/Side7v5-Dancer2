package Side7::Schema::Result::UploadRating;

use strict;
use warnings;

# Third Party modules
use base 'DBIx::Class::Core';
use DateTime;
our $VERSION = '1.0';


=head1 NAME

Side7::Schema::Result::UploadRating


=head1 AUTHOR

Jason Lamey L<email:jasonlamey@gmail.com>


=head1 SYNOPSIS AND USAGE

This module represents the UploadRating object in the web app, as well as the interface to the C<upload_categories> table in the database.

=cut

__PACKAGE__->table( 'upload_ratings' );
__PACKAGE__->add_columns(
                          id =>
                            {
                              data_type         => 'integer',
                              size              => 3,
                              is_nullable       => 0,
                              is_auto_increment => 1,
                            },
                          rating =>
                            {
                              data_type         => 'varchar',
                              size              => 255,
                              is_nullable       => 0,
                            },
                          shorthand =>
                            {
                              data_type         => 'varchar',
                              size              => 3,
                              is_nullable       => 0,
                            },
                          description =>
                            {
                              data_type         => 'text',
                              is_nullable       => 1,
                              default_value     => undef,
                            },
                          require_qualifier =>
                            {
                              data_type         => 'boolean',
                              size              => 1,
                              is_nullable       => 0,
                              default_value     => 0,
                            },
                          upload_type_id =>
                            {
                              data_type         => 'integer',
                              size              => 3,
                              is_nullable       => 0,
                            },
                          sort_order =>
                            {
                              data_type         => 'integer',
                              size              => 3,
                              is_nullable       => 0,
                            },
                        );

__PACKAGE__->set_primary_key( 'id' );

__PACKAGE__->belongs_to( 'upload_type' => 'Side7::Schema::Result::UploadType', 'upload_type_id' );

__PACKAGE__->has_many( 'uploads' => 'Side7::Schema::Result::UserUpload', 'upload_rating_id' );


=head1 METHODS


=head2 method()

TODO: method description

=over 4

=item Input: None.

=item Output: None.

=back

  $result = $object->method;

=cut

sub method
{
  my ( $self ) = @_;

}


=head1 COPYRIGHT & LICENSE

Copyright 2017, Side 7 L<http://www.side7.com>
All rights reserved.

=cut

1;
