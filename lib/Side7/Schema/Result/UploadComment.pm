package Side7::Schema::Result::UploadComment;

use strict;
use warnings;

# Third Party modules
use base 'DBIx::Class::Core';
use DateTime;
our $VERSION = '1.0';


=head1 NAME

Side7::Schema::Result::UploadComment


=head1 AUTHOR

Jason Lamey L<email:jasonlamey@gmail.com>


=head1 SYNOPSIS AND USAGE

This module represents the Upload Comment object in the web app, as well as the interface to the C<upload_comments> table in the database.

=cut

__PACKAGE__->table( 'upload_comments' );
__PACKAGE__->add_columns(
                          id =>
                            {
                              data_type         => 'integer',
                              size              => 20,
                              is_nullable       => 0,
                              is_auto_increment => 1,
                            },
                          upload_comment_thread_id =>
                            {
                              data_type         => 'integer',
                              size              => 20,
                              is_nullable       => 0,
                            },
                          user_id =>
                            {
                              data_type         => 'integer',
                              size              => 20,
                              is_nullable       => 0,
                            },
                          username =>
                            {
                              data_type         => 'varchar',
                              size              => 255,
                              is_nullable       => 0,
                              default_value     => undef,
                            },
                          comment =>
                            {
                              data_type         => 'text',
                              is_nullable       => 0,
                            },
                          private =>
                            {
                              data_type         => 'boolean',
                              is_nullable       => 0,
                              default_value     => 0,
                            },
                          rating =>
                            {
                              data_type         => 'integer',
                              size              => 1,
                              is_nullable       => 0,
                              default_value     => 0,
                            },
                          ip_address =>
                            {
                              data_type         => 'varchar',
                              size              => 50,
                              is_nullable       => 0,
                              default_value     => 'Unknown',
                            },
                          timestamp =>
                            {
                              data_type         => 'datetime',
                              is_nullable       => 0,
                              default_value     => DateTime->now( 'time_zone' => 'UTC' )->datetime,
                            },
                        );

__PACKAGE__->set_primary_key( 'id' );

__PACKAGE__->belongs_to( 'thread' => 'Side7::Schema::Result::UploadCommentThread', 'upload_comment_thread_id' );
__PACKAGE__->belongs_to( 'user'   => 'Side7::Schema::Result::User',                'user_id' );


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
