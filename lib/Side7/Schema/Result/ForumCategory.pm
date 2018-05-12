package Side7::Schema::Result::ForumCategory;

use base 'DBIx::Class::Core';

use strict;
use warnings;

use DateTime;
use version; our $VERSION = qv( "v0.1.0" );


=head1 NAME

Side7::Schema::Result::ForumCategory


=head1 DESCRIPTION AND USAGE

Database object representing ForumCategory entries within the web app.

=cut

__PACKAGE__->table( 'forum_categories' );
__PACKAGE__->add_columns(
                            id =>
                                {
                                    accessor          => 'catgory_id',
                                    data_type         => 'integer',
                                    size              => 20,
                                    is_nullable       => 0,
                                    is_auto_increment => 1,
                                },
                            name =>
                                {
                                    data_type         => 'varchar',
                                    size              => 20,
                                    is_nullable       => 0,
                                },
                            sort_order =>
                                {
                                    data_type         => 'varchar',
                                    size              => 255,
                                    is_nullable       => 0,
                                },
                            view_access =>
                                {
                                    data_type         => 'enum',
                                    default_value     => 'Any',
                                    is_nullable       => 0,
                                    is_enum           => 1,
                                    extra =>
                                    {
                                      list => [ 'Any', 'Registered', 'User Group', 'Moderator', 'Admin' ]
                                    },
                                },
                            read_access =>
                                {
                                    data_type         => 'enum',
                                    default_value     => 'Any',
                                    is_nullable       => 0,
                                    is_enum           => 1,
                                    extra =>
                                    {
                                      list => [ 'Any', 'Registered', 'User Group', 'Moderator', 'Admin' ]
                                    },
                                },
                        );

__PACKAGE__->set_primary_key( 'id' );

__PACKAGE__->has_many( 'groups', 'Side7::Schema::Result::ForumGroup', 'forum_category_id' );


=head1 AUTHOR

Jason Lamey E<lt>jasonlamey@gmail.comE<gt>


=head1 COPYRIGHT AND LICENSE

Copyright 2018 by Jason Lamey

This library is for use by Side7. It is not intended for redistribution
or use by other parties without express written permission.

=cut

1;
