package Side7::Schema::Result::ForumThreadsWithNewPostsView;

use strict;
use warnings;

use base qw/DBIx::Class::Core/;

__PACKAGE__->table_class('DBIx::Class::ResultSource::View');

__PACKAGE__->table( 'forum_threads_new_posts_view' );

__PACKAGE__->result_source_instance->is_virtual(1);

__PACKAGE__->result_source_instance->view_definition(
  q[
    SELECT ft.id as thread_id, 
       ( CASE
          WHEN ( fp.timestamp > flv.timestamp) THEN 1
          WHEN flv.timestamp IS NULL THEN 1
          ELSE 0
       END ) as has_unread_posts
      FROM forum_threads ft
 LEFT JOIN forum_posts fp
        ON fp.forum_thread_id = ft.id
 LEFT JOIN forum_last_viewed flv
        ON flv.forum_thread_id = ft.id
     WHERE flv.user_id = ? AND
           ( fp.timestamp > flv.timestamp OR flv.timestamp IS NULL )
  GROUP BY ft.id, has_unread_posts
  ORDER BY has_unread_posts DESC, ft.id
  ]
);

__PACKAGE__->add_columns(
  thread_id =>
  {
    data_type         => 'integer',
    size              => 20,
    is_nullable       => 0,
  },
  has_unread_posts =>
  {
    data_type         => 'integer',
    size              => 1,
    is_nullable       => 0,
  },
);

__PACKAGE__->set_primary_key( 'has_unread_posts' );
