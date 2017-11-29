package Side7::Schema::Result::UploadCommentThread;

use strict;
use warnings;

# Third Party modules
use base 'DBIx::Class::Core';
use DateTime;
our $VERSION = '1.0';


=head1 NAME

Side7::Schema::Result::UploadCommentThread


=head1 AUTHOR

Jason Lamey L<email:jasonlamey@gmail.com>


=head1 SYNOPSIS AND USAGE

This module represents the Upload Comment Thread object in the web app, as well as the interface to the C<upload_comment_threads> table in the database.

=cut

__PACKAGE__->table( 'upload_comment_threads' );
__PACKAGE__->add_columns(
                          id =>
                            {
                              data_type         => 'integer',
                              size              => 20,
                              is_nullable       => 0,
                              is_auto_increment => 1,
                            },
                          upload_id =>
                            {
                              data_type         => 'integer',
                              size              => 20,
                              is_nullable       => 0,
                            },
                          creator_id =>
                            {
                              data_type         => 'integer',
                              size              => 20,
                              is_nullable       => 0,
                            },
                          created_on =>
                            {
                              data_type         => 'datetime',
                              is_nullable       => 0,
                              default_value     => DateTime->now( 'time_zone' => 'UTC' )->datetime,
                            },
                        );

__PACKAGE__->set_primary_key( 'id' );

__PACKAGE__->belongs_to( 'upload' => 'Side7::Schema::Result::UserUpload', 'upload_id' );
__PACKAGE__->belongs_to( 'user'   => 'Side7::Schema::Result::User',       'creator_id' );

__PACKAGE__->has_many( 'comments' => 'Side7::Schema::Result::UploadComment', 'upload_comment_thread_id', { order_by => 'timestamp' } );


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
