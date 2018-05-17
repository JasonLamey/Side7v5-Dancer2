package Side7::Schema::Result::ForumGroupNewView;

use strict;
use warnings;

use base qw/DBIx::Class::Core/;
# extends 'Side7::Schema::Result::ForumGroup';

__PACKAGE__->table_class('DBIx::Class::ResultSource::View');

__PACKAGE__->table( 'forum_group_new_view' );

__PACKAGE__->add_columns(
  new_posts =>
  {
    data_type         => 'integer',
    is_auto_increment => 0,
  },
);

__PACKAGE__->result_source_instance->is_virtual(1);
#
__PACKAGE__->result_source_instance->view_definition(
  q[
    SELECT CASE WHEN (forum_posts.timestamp > forum_last_viewed.timestamp) THEN 1
                WHEN forum_last_viewed.timestamp IS NULL THEN 1
                ELSE 0 END as new_posts
    FROM forum_threads
    LEFT JOIN forum_posts
           ON forum_posts.forum_thread_id = forum_threads.id
    LEFT JOIN forum_last_viewed
           ON forum_last_viewed.forum_thread_id = forum_posts.forum_thread_id AND
              forum_last_viewed.user_id = ?
    WHERE forum_threads.forum_group_id = ?
    GROUP BY forum_posts.forum_thread_id DESC
    ORDER BY forum_posts.timestamp
  ]
);
