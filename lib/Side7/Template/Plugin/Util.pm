package Side7::Template::Plugin::Util;

use strict;
use warnings;

use base qw( Template::Plugin );

use Template::Plugin;

use Side7::Util;
use Side7::Util::Text;


=head1 NAME

Side7::Template::Plugin::Util


=head1 DESCRIPTION

Provides Template::Toolkit access to the Side7::Util library's methods.


=head1 METHODS


=head2 new

Instantiates the appropriate object for Template::Toolkit.

=cut


sub new
{
  my ( $class, $context, @params ) = @_;
  bless
  {
    _CONTEXT => $context,
  }, $class;
}


=head2 load()

Used by Template::Toolkit to load the plugin.

=cut

sub load
{
  my ( $class, $context ) = @_;

  return $class;
}


=head2 commify

Adds commas for a visually displayed number.

=cut

sub commify
{
  my ( $self, $integer ) = @_;

  return Side7::Util->commify( $integer );
}


=head2 parse_bbcode

Returns the provided text, having translated any BBCode into HTML.

=cut

sub parse_bbcode
{
  my ( $self, $text ) = @_;

  return Side7::Util::Text::parse_bbcode_markup( $text );
}

1;
