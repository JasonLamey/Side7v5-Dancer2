package Side7::Schema::Result::FAQEntry;

use strict;
use warnings;

# Third Party modules
use base 'DBIx::Class::Core';
use DateTime;
our $VERSION = '1.0';


=head1 NAME

Side7::Schema::Result::FAQEntry


=head1 AUTHOR

Jason Lamey L<email:jasonlamey@gmail.com>


=head1 SYNOPSIS AND USAGE

This module represents an FAQ Entry object in the web app, as well as the interface to the C<faq_entries> table in the database.

=cut

__PACKAGE__->table( 'faq_entries' );
__PACKAGE__->add_columns(
                          id =>
                            {
                              data_type         => 'integer',
                              size              => 10,
                              is_nullable       => 0,
                              is_auto_increment => 1,
                            },
                          faq_category_id =>
                            {
                              data_type         => 'integer',
                              size              => 10,
                              is_nullable       => 0,
                            },
                          question =>
                            {
                              data_type         => 'text',
                              is_nullable       => 0,
                            },
                          answer =>
                            {
                              data_type         => 'text',
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

__PACKAGE__->belongs_to( 'category' => 'Side7::Schema::Result::FAQCategory', 'faq_category_id' );


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
