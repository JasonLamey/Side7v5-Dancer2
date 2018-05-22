package Side7::Schema::ResultSet::ForumPostsLatestView;

use strict;
use warnings;

use parent 'DBIx::Class::ResultSet';

use Const::Fast;

const my $MAX_POSTS => 5;

sub get_latest_posts
{
  my ( $self, $user ) = @_;
  my @posts = $self->search( {}, { bind => [ $MAX_POSTS ] } );

  return @posts;
}

1;
