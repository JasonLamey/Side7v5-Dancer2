package Side7::Schema::Result::UserSetting;

use strict;
use warnings;

# Third Party modules
use base 'DBIx::Class::Core';
our $VERSION = '1.0';
use DateTime;


=head1 NAME

Side7::Schema::Result::UserSetting


=head1 AUTHOR

Jason Lamey L<email:jasonlamey@gmail.com>


=head1 SYNOPSIS AND USAGE

This library represents the User settings.

=cut


__PACKAGE__->table( 'user_settings' );
__PACKAGE__->add_columns(
                          id =>
                            {
                              data_type         => 'integer',
                              size              => 20,
                              is_nullable       => 0,
                              is_auto_increment => 1,
                            },
                          user_id =>
                            {
                              data_type         => 'integer',
                              size              => 20,
                              is_nullable       => 0,
                            },
                          show_online_status =>
                            {
                              data_type         => 'boolean',
                              size              => 1,
                              is_nullable       => 0,
                              default_value     => 1,
                            },
                          allow_museum_adds =>
                            {
                              data_type         => 'boolean',
                              size              => 1,
                              is_nullable       => 0,
                              default_value     => 1,
                            },
                          allow_friend_requests =>
                            {
                              data_type         => 'boolean',
                              size              => 1,
                              is_nullable       => 0,
                              default_value     => 1,
                            },
                          allow_user_contact =>
                            {
                              data_type         => 'boolean',
                              size              => 1,
                              is_nullable       => 0,
                              default_value     => 1,
                            },
                          allow_add_to_favorites =>
                            {
                              data_type         => 'boolean',
                              size              => 1,
                              is_nullable       => 0,
                              default_value     => 1,
                            },
                          show_social_links =>
                            {
                              data_type         => 'boolean',
                              size              => 1,
                              is_nullable       => 0,
                              default_value     => 1,
                            },
                          filter_categories =>
                            {
                              data_type         => 'varchar',
                              size              => 255,
                              is_nullable       => 1,
                              default_value     => undef,
                            },
                          filter_ratings =>
                            {
                              data_type         => 'varchar',
                              size              => 255,
                              is_nullable       => 1,
                              default_value     => undef,
                            },
                          show_m_thumbnails =>
                            {
                              data_type         => 'boolean',
                              size              => 1,
                              is_nullable       => 0,
                              default_value     => 0,
                            },
                          show_adult_content =>
                            {
                              data_type         => 'boolean',
                              size              => 1,
                              is_nullable       => 0,
                              default_value     => 0,
                            },
                          email_notifications =>
                            {
                              data_type         => 'boolean',
                              size              => 1,
                              is_nullable       => 0,
                              default_value     => 1,
                            },
                          notify_on_pm =>
                            {
                              data_type         => 'boolean',
                              size              => 1,
                              is_nullable       => 0,
                              default_value     => 1,
                            },
                          notify_on_comment =>
                            {
                              data_type         => 'boolean',
                              size              => 1,
                              is_nullable       => 0,
                              default_value     => 1,
                            },
                          notify_on_friend_request =>
                            {
                              data_type         => 'boolean',
                              size              => 1,
                              is_nullable       => 0,
                              default_value     => 1,
                            },
                          notify_on_mention =>
                            {
                              data_type         => 'boolean',
                              size              => 1,
                              is_nullable       => 0,
                              default_value     => 1,
                            },
                          notify_on_favorite =>
                            {
                              data_type         => 'boolean',
                              size              => 1,
                              is_nullable       => 0,
                              default_value     => 1,
                            },
                          notify_on_museum_add =>
                            {
                              data_type         => 'boolean',
                              size              => 1,
                              is_nullable       => 0,
                              default_value     => 1,
                            },
                          updated_on =>
                            {
                              data_type         => 'datetime',
                              is_nullable       => 0,
                              default_value     => DateTime->now( time_zone => 'UTC' )->datetime,
                            },
                        );

__PACKAGE__->set_primary_key( 'id' );

__PACKAGE__->belongs_to( 'user' => 'Side7::Schema::Result::User', 'user_id' );


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

Copyright 2018, Jason Lamey
All rights reserved.

=cut

1;
