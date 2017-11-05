package Side7::Schema::Result::UserMail;

use strict;
use warnings;

# Third Party modules
use base 'DBIx::Class::Core';
our $VERSION = '1.0';


=head1 NAME

Side7::Schema::Result::UserMail


=head1 AUTHOR

Jason Lamey L<email:jasonlamey@gmail.com>


=head1 SYNOPSIS AND USAGE

This library represents the UserMail objects, and access to the C<user_mail> table;

=cut

__PACKAGE__->table( 'user_mail' );
__PACKAGE__->add_columns(
  id =>
  {
    data_type         => 'integer',
    size              => 20,
    is_nullable       => 0,
    is_auto_increment => 1,
  },
  sender_id =>
  {
    data_type         => 'integer',
    size              => 20,
    is_nullable       => 0,
  },
  recipient_id =>
  {
    data_type         => 'integer',
    size              => 20,
    is_nullable       => 0,
  },
  timestamp =>
  {
    data_type         => 'datetime',
    is_nullable       => 0,
    default_value     => DateTime->now( time_zone => 'UTC' )->datetime,
  },
  subject =>
  {
    data_type         => 'varchar',
    size              => 255,
    is_nullable       => 1,
    default_value     => undef,
  },
  body =>
  {
    data_type         => 'text',
    is_nullable       => 0,
  },
  is_read =>
  {
    data_type         => 'boolean',
    is_nullable       => 0,
    default_value     => 0,
  },
  is_replied_to =>
  {
    data_type         => 'boolean',
    is_nullable       => 0,
    default_value     => 0,
  },
  is_deleted =>
  {
    data_type         => 'boolean',
    is_nullable       => 0,
    default_value     => 0,
  },
);

__PACKAGE__->set_primary_key( 'id' );

__PACKAGE__->belongs_to( 'sender'    => 'Side7::Schema::Result::User', 'sender_id' );
__PACKAGE__->belongs_to( 'recipient' => 'Side7::Schema::Result::User', 'recipient_id' );


=head1 METHODS


=head2 method_name()

This is a description of the method and what it does.

=over 4

=item Input: A description of what the method expects.

=item Output: A description of what the method returns.

=back

  $var = Side7::PackageName->method_name();

=cut

sub method_name
{
}


=head1 COPYRIGHT & LICENSE

Copyright 2017, Jason Lamey
All rights reserved.

=cut

1;
