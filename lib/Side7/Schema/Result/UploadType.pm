package Side7::Schema::Result::UploadType;

use strict;
use warnings;

# Third Party modules
use base 'DBIx::Class::Core';
use DateTime;
our $VERSION = '1.0';


=head1 NAME

Side7::Schema::Result::UploadType


=head1 AUTHOR

Jason Lamey L<email:jasonlamey@gmail.com>


=head1 SYNOPSIS AND USAGE

This module represents the UploadType object in the web app, as well as the interface to the C<upload_type> table in the database.

  id INT(3) UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  type VARCHAR(255) NOT NULL,
  mime_types VARCHAR(255) NOT NULL,
  max_size INT(10) UNSIGNED NOT NULL

=cut

__PACKAGE__->table( 'upload_types' );
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

__PACKAGE__->has_many( 'uploads'           => 'Side7::Schema::Result::UserUpload',     'upload_type_id' );
__PACKAGE__->has_many( 'upload_categories' => 'Side7::Schema::Result::UploadCategory', 'upload_type_id' );


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
