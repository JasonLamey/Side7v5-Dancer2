package Side7::Schema::Result::News;

use base qw/DBIx::Class::Core/;

__PACKAGE__->table( 'news' );

__PACKAGE__->add_columns(
                          id =>
                          {
                            data_type         => 'integer',
                            size              => 20,
                            is_nullable       => 0,
                            is_auto_increment => 1,
                          },
                          posted_on =>
                          {
                            data_type         => 'datetime',
                            is_nullable       => 1,
                            default_value     => undef,
                          },
                          expires_on =>
                          {
                            data_type         => 'date',
                            is_nullable       => 1,
                            default_value     => undef,
                          },
                          title =>
                          {
                            data_type         => 'varchar',
                            size              => 255,
                            is_nullable       => 0,
                          },
                          article =>
                          {
                            data_type         => 'text',
                            is_nullable       => 1,
                            default_value     => undef,
                          },
                          news_type =>
                          {
                            data_type         => 'enum',
                            is_nullable       => 0,
                            default_value     => 'Standard',
                            is_enum           => 1,
                            extra =>
                            {
                              list => [ qw/Stadard Announcement/ ]
                            },
                          },
                          user_id =>
                          {
                            datatype          => 'integer',
                            size              => 20,
                            is_nullable       => 0,
                          },
                          views =>
                          {
                            datatype          => 'integer',
                            size              => 10,
                            is_nullable       => 0,
                            default_value     => 0,
                          },
                        );

__PACKAGE__->set_primary_key( 'id' );

__PACKAGE__->belongs_to( 'user' => 'Side7::Schema::Result::User', 'user_id' );

1;
