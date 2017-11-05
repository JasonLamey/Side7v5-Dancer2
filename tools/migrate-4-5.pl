#!/usr/bin/env perl

use strict;
use warnings;

$|++;

use FindBin;
use lib "$FindBin::Bin/../lib";

use DateTime;
use DateTime::Duration;
use DBI;
use DBIx::Class;
use Const::Fast;
use Getopt::Long;
Getopt::Long::Configure ( "bundling", "ignorecase_always" );
use version; our $VERSION = version->declare("v2.0.0");
use Term::ProgressBar;

use Side7::Schema;

const my $SCHEMA => Side7::Schema->db_connect();
const my $DBH5   => $SCHEMA->storage->dbh;
const my $DBH    => DBI->connect(
                      "dbi:mysql:database=side7_v4;host=localhost", "webowner", "s7web",
                      {
                        RaiseError => 1,
                        PrintError => 1
                      }
                    );
const my $TODAY  => DateTime->today( time_zone => 'UTC' );


=head1 NAME

Side 7 Migration Script - v4 to v5


=head1 DESCRIPTION

This script pulls data from the v4 database, and reformats it to conform to the v5 database. It then inserts it into the new database.
This script only moves items that are dynamic, and does not include lookup tables. Lookup tables are handled by sqitch deploys.


=head2 Execution

  ./migrate-4-5.pl [-v|--verbose] [-d|--dryrun] [-i|--interactive] [-h|--help]

  -v|--verbose     => Verbose logging to the console
  -d|--dryrun      => Run through the process, but do not commit to the new database
  -i|--interactive => Confirm each table migration before processing it
  -h|--help        => Display this help message

=cut

#########################################################
# Main
#########################################################

our $verbose     = 0;
our $dryrun      = 0;
our $interactive = 0;
our $help        = 0;

GetOptions(
  'verbose|v'     => \$verbose,
  'dryrun|d'      => \$dryrun,
  'interactive|i' => \$interactive,
  'help|h'        => \$help,
);

if ( $help )
{
  show_help();
  exit;
}

print "\nSide 7 DB Migration tool -- Version $VERSION\n";
print "Verbose is ON\n"    if $verbose;
print "Dry Run is ON\n"    if $dryrun;
print "Interactive mode\n" if $interactive;
print "\n";

######################################

migrate_news();
migrate_faq_categories();
migrate_faq_entries();

migrate_users();
migrate_images();
update_upload_view_totals();
migrate_upload_views();
migrate_credits();

######################################

print "Shutting down.\n\n";
$DBH->disconnect;


#########################################################
# Support subroutines
#########################################################

sub show_help
{
  print "\nSide 7 DB Migration tool -- Version $VERSION\n\n";
  print "Migrates and normalizes v4 data to v5 format, and populates the v5 database.\n\n";
  print "Usage:\n";
  print "./$0 [-v|--verbose] [-d|--dryrun] [-i|--interactive] [-h|--help]\n\n";
  print "\t-v|--verbose     => Verbose logging to the console\n";
  print "\t-d|--dryrun      => Run through the process, but do not commit to the new database\n";
  print "\t-i|--interactive => Confirm each table migration before processing it\n";
  print "\t-h|--help        => Display this help message\n\n";
}

sub confirm_table
{
  my $table = shift;

  printf "- Migrate table '%s' [Y/n]: ", $table;
  my $confirm = <STDIN>;

  chomp $confirm;

  if ( $confirm eq '' || $confirm eq 'Y' )
  {
    printf "-- Migrating\n";
    return 1;
  }
  else
  {
    printf "-- Skipping\n";
    return 0;
  }
}

sub truncate_table
{
  my $table = shift;
  $DBH5->do( 'SET FOREIGN_KEY_CHECKS = 0;' );
  $DBH5->do( sprintf( 'TRUNCATE TABLE %s;', $table ) );
  $DBH5->do( 'SET FOREIGN_KEY_CHECKS = 1;' );
  return;
}

sub migrate_users
{
  print "Users Table\n" if $verbose;
  if ( $interactive )
  {
    if ( ! confirm_table( 'users' ) )
    {
      return;
    }
  }

  # Cleanup the v5 tables from any previous migration attempts
  print "- Truncating v5 table\n" if $verbose;
  truncate_table( 'users' ) if ! $dryrun;

  # v4 data pull
  my $sth = $DBH->prepare(
    'SELECT ua.*, uapi.biography, uapi.sex, uapi.birthdate, uapi.birthdate_mode, uapi.state, uapi.country
       FROM user_accounts ua
  LEFT JOIN user_account_personal_info uapi ON uapi.user_account_id = ua.id
   ORDER BY id'
  );
  $sth->execute();
  my $rv = $sth->fetchall_hashref( 'id' );

  my $num_rows = scalar( keys ( %{$rv} ) );
  printf "- v4 Rows found: %d\n", $num_rows if $verbose;

  # Normalize Values
  my %statuses = ( 'Pending' => 1, 'Active' => 2, 'Suspended' => 3, 'Disabled' => 4 );
  my %genders  = ( 'Unspecified' => 1, 'Male' => 25, 'Female' => 16, 'Neither' => 28, 'Other' => 31 );
  my %bday_vis = ( 'Full' => 'Public', 'No Year' => 'Hide Year', 'Hidden' => 'Private' );

  # Import
  print "- Importing rows\n" if $verbose;

  # Set Up Progress Bar
  my $progress = Term::ProgressBar->new(
    {
      name  => 'Users Table',
      count => $num_rows,
      ETA   => 'linear',
    }
  );
  $progress->max_update_rate(1);
  my $next_update = 0; my $i = 0;

  foreach my $key ( sort keys ( %{$rv} ) )
  {
    my $row = $rv->{$key};

    # Normalize birthdate
    my $birthday = $TODAY->ymd;
    if ( defined $row->{'birthdate'} )
    {
      my ( $year, $mon, $day ) = split( /-/, $row->{'birthdate'} );

      if ( $year eq '0000' ) { $year = $TODAY->year; }
      if ( $mon eq '00' )    { $mon  = $TODAY->mon; $day = '01'; }
      if ( $day eq '00' )    { $day  = '01' }

      $birthday = join( '-', $year, $mon, $day );
    }

    # Insert new record
    if ( ! $dryrun )
    {
      my $new_user = $SCHEMA->resultset( 'User' )->create(
        {
          id                  => $row->{'id'},
          username            => $row->{'username'},
          password            => $row->{'password'},
          email_address       => $row->{'email_address'},
          first_name          => $row->{'first_name'},
          last_name           => $row->{'last_name'},
          birthday            => $birthday,
          birthday_visibility => $bday_vis{$row->{'birthdate_mode'}},
          user_status_id      => $statuses{$row->{'status'}},
          gender_id           => $genders{$row->{'sex'}},
          biography           => $row->{'biography'},
          state               => $row->{'state'},
          country_id          => 1, # Set to Undefined
          confirmed           => ( ( uc($row->{'status'}) eq 'PENDING' ) ? 0 : 1 ),
          confirm_code        => $row->{'email_confirmation_code'},
          created_at          => $row->{'join_date'} . ' 00:00:00',
        }
      );
    }

    $next_update = $progress->update( $i ) if $i > $next_update;
    $i++;
  }
  $progress->update( $num_rows ) if $num_rows >= $next_update;

  $sth->finish;
  print "\n\n";
}

sub migrate_credits
{
  print "S7 Credits Table\n" if $verbose;
  if ( $interactive )
  {
    if ( ! confirm_table( 's7_credits' ) )
    {
      return;
    }
  }

  # Cleanup the v5 tables from any previous migration attempts
  print "- Truncating v5 table\n" if $verbose;
  truncate_table( 's7_credits' ) if ! $dryrun;

  # v4 data pull
  my $sth = $DBH->prepare(
    'SELECT *
       FROM account_credit_transactions
   ORDER BY id'
  );
  $sth->execute();
  my $rv = $sth->fetchall_hashref( 'id' );

  my $num_rows = scalar( keys ( %{$rv} ) );
  printf "- v4 Rows found: %d\n", $num_rows if $verbose;

  # Import
  print "- Importing rows\n" if $verbose;

  # Set Up Progress Bar
  my $progress = Term::ProgressBar->new(
    {
      name  => 'S7 Credits Table',
      count => $num_rows,
      ETA   => 'linear',
    }
  );
  $progress->max_update_rate(1);
  my $next_update = 0; my $i = 0;

  foreach my $key ( sort keys ( %{$rv} ) )
  {
    my $row = $rv->{$key};

    # Insert new record
    if ( ! $dryrun )
    {
      my $new_user = $SCHEMA->resultset( 'S7Credit' )->create(
        {
          id          => $row->{'id'},
          user_id     => $row->{'user_account_id'},
          timestamp   => $row->{'timestamp'},
          amount      => $row->{'amount'},
          description => $row->{'description'},
        }
      );
    }

    $next_update = $progress->update( $i ) if $i > $next_update;
    $i++;
  }
  $progress->update( $num_rows ) if $num_rows >= $next_update;

  $sth->finish;
  print "\n\n";
}

sub migrate_news
{
  print "News Table\n" if $verbose;
  if ( $interactive )
  {
    if ( ! confirm_table( 'news' ) )
    {
      return;
    }
  }

  # Cleanup the v5 tables from any previous migration attempts
  print "- Truncating v5 table\n" if $verbose;
  truncate_table( 'news' ) if ! $dryrun;

  my $sth = $DBH->prepare(
    'SELECT *
       FROM news
   ORDER BY id'
  );
  $sth->execute();
  my $rv = $sth->fetchall_hashref( 'id' );

  my $num_rows = scalar( keys ( %{$rv} ) );
  printf "- v4 Rows found: %d\n", $num_rows if $verbose;

  # Import
  print "- Importing rows\n" if $verbose;

  # Set Up Progress Bar
  my $progress = Term::ProgressBar->new(
    {
      name  => 'News Table',
      count => $num_rows,
      ETA   => 'linear',
    }
  );
  $progress->max_update_rate(1);
  my $next_update = 0; my $i = 0;

  foreach my $key ( sort keys ( %{$rv} ) )
  {
    my $row = $rv->{$key};

    # Normalize values
    my $news_type = 'Standard';
    if ( $row->{'static'} ) { $news_type = 'Announcement'; }

    # Insert new record
    if ( ! $dryrun )
    {
      my $new_user = $SCHEMA->resultset( 'News' )->create(
        {
          id         => $row->{'id'},
          user_id    => $row->{'user_account_id'},
          title      => $row->{'title'},
          article    => $row->{'article'},
          news_type  => $news_type,
          posted_on  => $row->{'timestamp'},
          expires_on => $row->{'expires'},
          views      => 0,
        }
      );
    }

    $next_update = $progress->update( $i ) if $i > $next_update;
    $i++;
  }
  $progress->update( $num_rows ) if $num_rows >= $next_update;

  $sth->finish;
  print "\n\n";
}

sub migrate_images
{
  print "Images Table\n" if $verbose;
  if ( $interactive )
  {
    if ( ! confirm_table( 'images' ) )
    {
      return;
    }
  }

  # Cleanup the v5 tables from any previous migration attempts
  print "- Truncating v5 table\n" if $verbose;
  truncate_table( 'user_uploads' ) if ! $dryrun;

  # v4 data pull
  my $sth = $DBH->prepare(
    'SELECT i.*
       FROM images i
   ORDER BY id'
  );
  $sth->execute();
  my $rv = $sth->fetchall_hashref( 'id' );

  my $num_rows = scalar( keys ( %{$rv} ) );
  printf "- v4 Rows found: %d\n", $num_rows if $verbose;

  # Import
  print "- Importing rows\n" if $verbose;

  # Set Up Progress Bar
  my $progress = Term::ProgressBar->new(
    {
      name  => 'Images Table',
      count => $num_rows,
      ETA   => 'linear',
    }
  );
  $progress->max_update_rate(1);
  my $next_update = 0; my $i = 0;

  foreach my $key ( sort keys ( %{$rv} ) )
  {
    my $row = $rv->{$key};

    # Insert new record
    if ( ! $dryrun )
    {
      my $new_user = $SCHEMA->resultset( 'UserUpload' )->create(
        {
          id                  => $row->{'id'},
          user_id             => $row->{'user_account_id'},
          filename            => $row->{'filename'},
          filesize            => $row->{'filesize'},
          upload_type_id      => 1,
          upload_category_id  => $row->{'image_category_id'},
          upload_rating_id    => $row->{'image_rating_id'},
          upload_class_id     => $row->{'image_class_id'},
          title               => $row->{'title'},
          description         => $row->{'description'},
          views               => $row->{'image_views'},
          uploaded_on         => $row->{'uploaded_date'},
        }
      );
    }

    $next_update = $progress->update( $i ) if $i > $next_update;
    $i++;
  }
  $progress->update( $num_rows ) if $num_rows >= $next_update;

  $sth->finish;
  print "\n\n";
}

sub update_upload_view_totals
{
  print "Update Upload Views\n" if $verbose;
  if ( $interactive )
  {
    if ( ! confirm_table( 'update_image_views' ) )
    {
      return;
    }
  }

  # v4 data pull
  my $sth = $DBH->prepare(
    'SELECT image_id, SUM(`count`) AS total
       FROM image_views
   GROUP BY image_id
   ORDER BY image_id'
  );
  $sth->execute();
  my $rv = $sth->fetchall_hashref( 'image_id' );

  my $num_rows = scalar( keys ( %{$rv} ) );
  printf "- v4 Rows found: %d\n", $num_rows if $verbose;

  # Import
  print "- Importing rows\n" if $verbose;

  # Set Up Progress Bar
  my $progress = Term::ProgressBar->new(
    {
      name  => 'Update Uploads Table',
      count => $num_rows,
      ETA   => 'linear',
    }
  );
  $progress->max_update_rate(1);
  my $next_update = 0; my $i = 0;

  foreach my $key ( sort keys ( %{$rv} ) )
  {
    my $row = $rv->{$key};

    # Insert new record
    if ( ! $dryrun )
    {
      my $upload = $SCHEMA->resultset( 'UserUpload' )->find( $row->{'image_id'} );

      if ( ! defined $upload or ref( $upload ) ne 'Side7::Schema::Result::UserUpload' )
      {
        $next_update = $progress->update( $i ) if $i > $next_update;
        $i++;
        next;
      }

      $upload->views( $row->{'total'} );
      $upload->update;
    }

    $next_update = $progress->update( $i ) if $i > $next_update;
    $i++;
  }
  $progress->update( $num_rows ) if $num_rows >= $next_update;

  $sth->finish;
  print "\n\n";
}

sub migrate_upload_views
{
  print "Upload Views Table\n" if $verbose;
  if ( $interactive )
  {
    if ( ! confirm_table( 'image_views' ) )
    {
      return;
    }
  }

  # Cleanup the v5 tables from any previous migration attempts
  print "- Truncating v5 table\n" if $verbose;
  truncate_table( 'upload_views' ) if ! $dryrun;

  # v4 data pull

  # Only pulling view data from up to 1 year ago.
  my $today    = DateTime->today;
  my $old_date = $today->subtract( years => 1 );
  print "- Only pulling records from " . $old_date->ymd . " or newer.\n" if $verbose;

  my $rowcount = $DBH->selectrow_hashref(
    "SELECT COUNT(*) AS num_records
       FROM image_views
      WHERE date >= '$old_date->ymd'"
  );
  printf "- v4 Rows found: %d\n", $rowcount->{'num_records'} if $verbose;

  my $rvs = {};

  for ( my $i = 0; $i <= $rowcount->{'num_records'}; $i += 1000 )
  {
    printf "-- Selecting %s-%s\n", $i, $i+999 if $verbose;
    my $sth = $DBH->prepare(
      "SELECT /*+ MAX_EXECUTION_TIME(300000) */ *
         FROM image_views
        WHERE date >= '$old_date->ymd'
     ORDER BY id
        LIMIT $i, 1000"
    );
    $sth->execute();
    my $rv = $sth->fetchall_hashref( 'id' );
    foreach my $key ( sort keys ( %{$rv} ) )
    {
      $rvs->{$key} = $rv->{$key};
    }
    $sth->finish;

    if ( $i != 0 && $i % 2000 == 0 )
    {
      # Import
      print "- Importing rows\n" if $verbose;
      my $num_rows = scalar( keys( %{$rvs} ) );

      # Set Up Progress Bar
      my $progress = Term::ProgressBar->new(
        {
          name  => 'Upload Views Table',
          count => $num_rows,
          ETA   => 'linear',
        }
      );
      $progress->max_update_rate(1);
      my $next_update = 0; my $j = 0;

      foreach my $key ( sort keys ( %{$rvs} ) )
      {
        my $row = $rvs->{$key};

        # Insert new record
        if ( ! $dryrun )
        {
          my $new_user = $SCHEMA->resultset( 'UploadView' )->create(
            {
              id                  => $row->{'id'},
              upload_id           => $row->{'image_id'},
              views               => $row->{'count'},
              date                => $row->{'date'},
            }
          );
        }

        $next_update = $progress->update( $j ) if $j > $next_update;
        $j++;
      }
      $progress->update( $num_rows ) if $num_rows >= $next_update;
      $rvs = {};
      print "\n";
    }
  }
  print "\n";
}

sub migrate_faq_categories
{
  print "FAQ Categories Table\n" if $verbose;
  if ( $interactive )
  {
    if ( ! confirm_table( 'faq_categories' ) )
    {
      return;
    }
  }

  # Cleanup the v5 tables from any previous migration attempts
  print "- Truncating v5 table\n" if $verbose;
  truncate_table( 'faq_categories' ) if ! $dryrun;

  my $sth = $DBH->prepare(
    'SELECT *
       FROM faq_categories
   ORDER BY id'
  );
  $sth->execute();
  my $rv = $sth->fetchall_hashref( 'id' );

  my $num_rows = scalar( keys ( %{$rv} ) );
  printf "- v4 Rows found: %d\n", $num_rows if $verbose;

  # Import
  print "- Importing rows\n" if $verbose;

  # Set Up Progress Bar
  my $progress = Term::ProgressBar->new(
    {
      name  => 'FAQ Categories Table',
      count => $num_rows,
      ETA   => 'linear',
    }
  );
  $progress->max_update_rate(1);
  my $next_update = 0; my $i = 0;

  foreach my $key ( sort keys ( %{$rv} ) )
  {
    my $row = $rv->{$key};

    # Insert new record
    if ( ! $dryrun )
    {
      my $new_user = $SCHEMA->resultset( 'FAQCategory' )->create(
        {
          id         => $row->{'id'},
          category   => $row->{'name'},
          sort_order => $row->{'priority'},
        }
      );
    }

    $next_update = $progress->update( $i ) if $i > $next_update;
    $i++;
  }
  $progress->update( $num_rows ) if $num_rows >= $next_update;

  $sth->finish;
  print "\n\n";
}

sub migrate_faq_entries
{
  print "FAQ Entries Table\n" if $verbose;
  if ( $interactive )
  {
    if ( ! confirm_table( 'faq_entries' ) )
    {
      return;
    }
  }

  # Cleanup the v5 tables from any previous migration attempts
  print "- Truncating v5 table\n" if $verbose;
  truncate_table( 'faq_entries' ) if ! $dryrun;

  my $sth = $DBH->prepare(
    'SELECT *
       FROM faq_entries
   ORDER BY id'
  );
  $sth->execute();
  my $rv = $sth->fetchall_hashref( 'id' );

  my $num_rows = scalar( keys ( %{$rv} ) );
  printf "- v4 Rows found: %d\n", $num_rows if $verbose;

  # Import
  print "- Importing rows\n" if $verbose;

  # Set Up Progress Bar
  my $progress = Term::ProgressBar->new(
    {
      name  => 'FAQ Entries Table',
      count => $num_rows,
      ETA   => 'linear',
    }
  );
  $progress->max_update_rate(1);
  my $next_update = 0; my $i = 0;

  foreach my $key ( sort keys ( %{$rv} ) )
  {
    my $row = $rv->{$key};

    # Insert new record
    if ( ! $dryrun )
    {
      my $new_user = $SCHEMA->resultset( 'FAQEntry' )->create(
        {
          id              => $row->{'id'},
          faq_category_id => $row->{'faq_category_id'},
          question        => $row->{'question'},
          answer          => $row->{'answer'},
          sort_order      => $row->{'priority'},
        }
      );
    }

    $next_update = $progress->update( $i ) if $i > $next_update;
    $i++;
  }
  $progress->update( $num_rows ) if $num_rows >= $next_update;

  $sth->finish;
  print "\n\n";
}
