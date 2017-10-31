package Side7::Schema::Result::CreditValue;

use strict;
use warnings;

# Third Party modules
use base 'DBIx::Class::Core';
use DateTime;
our $VERSION = '1.0';


=head1 NAME

Side7::Schema::Result::CreditValue


=head1 AUTHOR

Jason Lamey L<email:jasonlamey@gmail.com>


=head1 SYNOPSIS AND USAGE

This module represents an CreditValue object in the web app, as well as the interface to the C<credit_values> table in the database.

=cut

__PACKAGE__->table( 'credit_values' );
__PACKAGE__->add_columns(
                          id =>
                            {
                              data_type         => 'integer',
                              size              => 10,
                              is_nullable       => 0,
                              is_auto_increment => 1,
                            },
                          name =>
                            {
                              data_type         => 'varchar',
                              size              => 255,
                              is_nullable       => 0,
                            },
                          description =>
                            {
                              data_type         => 'varchar',
                              size              => 255,
                              is_nullable       => 0,
                            },
                          value =>
                            {
                              data_type         => 'integer',
                              size              => 5,
                              is_nullable       => 0,
                              default_value     => 0,
                            },
                          message =>
                            {
                              data_type         => 'varchar',
                              size              => 255,
                              is_nullable       => 1,
                              default_value     => undef,
                            }
                        );

__PACKAGE__->set_primary_key( 'id' );


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

Copyright 2016, Infinite Monkeys Games L<http://www.infinitemonkeysgames.com>
All rights reserved.

=cut

1;
