package Side7::Crypt;

use strict;
use warnings;

use Dancer2 appname => 'Side7';
use Dancer2::Plugin::Passphrase;

# Side7 modules
use Side7::Schema;

use Digest::SHA1 qw(sha1);
use Digest::MD5;

use version; our $VERSION = qv( '0.1.2' );

=pod


=head1 NAME

Side7::Crypt


=head1 DESCRIPTION

This package has the appropriate functionality for hashing passwords, codes, and other items that need to be made more ambiguious.

=cut


=head1 FUNCTIONS


=head2 sha1_hex_encode

Returns a SHA1 hex encoded version of the provided string.

    $sha1_encoded_text = Side7::Crypt::sha1_hex_encode( $text );

=cut

sub sha1_hex_encode
{
  my ( $string ) = @_;

  return if ! defined $string;

  my $sha1 = Digest::SHA1->new;
  $sha1->add( $string );
  my $digest = $sha1->hexdigest // '';

  return $digest;
}


=head2 md5_hex_encode

Returns an MD5 hex encoded version of the provided string.

    $md5_encoded_text = Side7::Crypt::md5_hex_encode( $text );

=cut

sub md5_hex_encode
{
  my ( $string ) = @_;

  return if ! defined $string;

  my $md5 = Digest::MD5->new;
  $md5->add( $string );
  my $digest = $md5->hexdigest // '';

  return $digest;
}


=head2 old_side7_crypt

Returns an old-style Side 7 v2 crypt version of the provided string.

    $old_crypt = Side7::Crypt::old_side7_crypt( $text );

=cut

sub old_side7_crypt
{
  my ( $string ) = @_;

  return if ! defined $string;

  return crypt($string, 'S7');
}


=head2 old_mysql_password

Returns an old-style MySQL password version of the provided string.

    $db_pass = Side7::Crypt::old_mysql_password( $text );

=cut

sub old_mysql_password
{
  my ( $string ) = @_;

  return if ! defined $string;

  my $SCHEMA = Side7::Schema->db_connect();
  my $dbh = $SCHEMA->storage->dbh;
  my $sth = $dbh->prepare( 'SELECT PASSWORD(?) as enc_password' );
  my $rv  = $sth->execute( $string );

  my $db_pass = $sth->fetchrow_arrayref;

  return $db_pass->[0];
}


=head1 COPYRIGHT

All code is Copyright (C) Side 7 1992 - 2014
L<http://www.side7.com>

=cut

1;
