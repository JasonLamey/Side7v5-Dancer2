package Side7::Schema::ResultSet::ForumGroupsWithNewPostsView;

use strict;
use warnings;

use parent 'DBIx::Class::ResultSet';

sub has_unseen_posts_in_groups
{
  my ( $self, $user ) = @_;
  my @results = $self->search( {}, { bind => [ $user->id ] } );

  foreach my $result ( @results )
  {
    if ( $result->get_column( 'new_posts' ) > 0 )
    {
      warn 'FORUM GROUP '. $self->name .' HAS NEW POSTS.';
      return 1;
    }
  }

  warn 'FORUM GROUP '. $self->name .' HAS NO NEW POSTS.';
  return 0;
}

1;
