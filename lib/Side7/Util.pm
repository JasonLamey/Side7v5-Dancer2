package Side7::Util;

use Dancer2 appname => 'Side7';
use Dancer2::Plugin::Passphrase;

use strict;
use warnings;

# Side7 modules

# Third Party modules
use version; our $VERSION = qv( 'v0.1.0' );


=head1 NAME

Side7::Util


=head1 AUTHOR

Jason Lamey L<email:jasonlamey@gmail.com>


=head1 SYNOPSIS AND USAGE

This module provides helper utilities for the Side7 webapp.


=head1 METHODS


=head2 generate_random_string()

Generates a new random string for use with a new account or for a password reset, or as confirmation code tokens.

=over 4

=item Input: none required; can take a hash of the following for customization: C<string_length> and C<char_set>. String length defines the length of the random password; defaults to 32. Char set defines the particular characters to be used, and is an arrayref, e.g. C<['a'..'z', 'A'..'Z']>, defaults to C<['a'..'z', 'A'..'Z', 0..9]>.

=item Output: A string of randomized chracters

=back

    my $rand_pass = Side7::Util->generate_random_string();
    my $rand_pass = Side7::Util->generate_random_string( string_length => 32, char_set => ['a'..'z', 'A'..'Z'] );

=cut

sub generate_random_string
{
  my ( $self, %params ) = @_;

  my $string_length = delete $params{'string_length'} // 32;
  my $char_set      = delete $params{'char_set'}      // ['a'..'z', 'A'..'Z', 0..9];

  return passphrase->generate_random( { length => $string_length, charset => $char_set } );
}


=head2 get_allowed_html_rules()

Returns a hashref of rules for HTML::Restrict for public form-based input.

=over 4

=item Input: None

=item Output: Hashref containing all the necessary rules.

=back

  my $html_rules = Side7::Util->get_allowed_html_rules();

=cut

sub get_allowed_html_rules
{
  my ( $self ) = @_;

  my %rules =
  (
    a       => [ qw( href target ) ],
    b       => [],
    br      => [],
    caption => [],
    center  => [],
    code    => [],
    div     => [ qw( style ) ],
    em      => [],
    h1      => [],
    h2      => [],
    h3      => [],
    h4      => [],
    h5      => [],
    h6      => [],
    hr      => [],
    i       => [],
    li      => [],
    ol      => [],
    p       => [ qw( style ) ],
    pre     => [],
    span    => [ qw( style ) ],
    strong  => [],
    sub     => [],
    sup     => [],
    table   => [ qw( style border cellspacing cellpadding align ) ],
    thead   => [],
    tbody   => [],
    td      => [],
    th      => [],
    tr      => [],
    u       => [],
    ul      => [],
  );

  return \%rules;
}


=head2 permission_denied_page_handler

Routine to display the 'permission_denied' screen when a User doesn't have the proper role.

=cut

sub permission_denied_page_handler
{
  template 'views/permission_denied.tt';
}


=head2 commify

Routine to add commas to displayed numbers.

=over

=item INPUT: integer

=item OUTPUT: string containing the number with commas.

=back

  my $number = Side7::Util->commify( $num_w_no_commas );

=cut

sub commify
{
  my ( $self, $number ) = @_;

  my $text = reverse $number;

  $text =~ s/(\d\d\d)(?=\d)(?!\d*\.)/$1,/g;

  return scalar reverse $text;
}


=head1 COPYRIGHT & LICENSE

Copyright 2017, Side 7 L<http://www.side7.com>
All rights reserved.

=cut

1;
