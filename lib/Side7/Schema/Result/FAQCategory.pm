package Side7::Schema::Result::FAQCategory;

use strict;
use warnings;

# Third Party modules
use base 'DBIx::Class::Core';
use DateTime;
our $VERSION = '1.0';


=head1 NAME

Side7::Schema::Result::FAQCategory


=head1 AUTHOR

Jason Lamey L<email:jasonlamey@gmail.com>


=head1 SYNOPSIS AND USAGE

This module represents an FAQ Category object in the web app, as well as the interface to the C<faq_categories> table in the database.

=cut

__PACKAGE__->table( 'faq_categories' );
__PACKAGE__->add_columns(
                          id =>
                            {
                              data_type         => 'integer',
                              size              => 10,
                              is_nullable       => 0,
                              is_auto_increment => 1,
                            },
                          category =>
                            {
                              data_type         => 'varchar',
                              size              => 255,
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

__PACKAGE__->has_many( 'entries' => 'Side7::Schema::Result::FAQEntry', 'faq_category_id' );


=head1 METHODS


=head2 article_count()

Returns an integer indicating how many articles are associated with the current category.

=over 4

=item Input: None

=item Output: Integer

=back

  $count = $faq_category->article_count();

=cut

sub article_count
{
  my $self = shift;

  my $count = $self->search_related( 'entries', {} )->count();

  return $count;
}


=head1 COPYRIGHT & LICENSE

Copyright 2017, Side 7 L<http://www.side7.com>
All rights reserved.

=cut

1;
