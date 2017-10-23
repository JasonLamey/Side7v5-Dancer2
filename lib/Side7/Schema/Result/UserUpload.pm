package Side7::Schema::Result::UserUpload;

use strict;
use warnings;

# Third Party modules
use base 'DBIx::Class::Core';
use DateTime;
our $VERSION = '1.0';


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
                              size              => 3,
                              is_nullable       => 0,
                              is_auto_increment => 1,
                            },
                          type =>
                            {
                              data_type         => 'varchar',
                              size              => 255,
                              is_nullable       => 0,
                            },
                          mime_types =>
                            {
                              data_type         => 'varchar',
                              size              => 255,
                              is_nullable       => 0,
                            },
                          max_size =>
                            {
                              data_type         => 'integer',
                              size              => 10,
                              is_nullable       => 0,
                            },
                        );

__PACKAGE__->set_primary_key( 'id' );

__PACKAGE__->has_many( 'uploads' => 'Side7::Schema::Result::UserUpload', 'upload_type_id' );


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
