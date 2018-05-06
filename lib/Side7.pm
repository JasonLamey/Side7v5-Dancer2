package Side7;

use strict;
use warnings;

# Dancer2 and Plugins/Modules
use Dancer2;
use Dancer2::Session::Cookie;
use Dancer2::Plugin::Auth::Extensible;
use Dancer2::Plugin::Flash;
use Dancer2::Plugin::Ajax;
use Dancer2::Plugin::DBIC;

# Third-party modules
use DBICx::Sugar;
use DateTime;
use Const::Fast;
use Data::Dumper;
use URL::Encode;
use Digest::SHA;
use File::Basename;

# Side 7 modules
use Side7::Schema;
use Side7::Util;
use Side7::Util::Text;
use Side7::Util::File;
use Side7::Util::Image;
use Side7::Mail;
use Side7::Log;
use Side7::Crypt;

our $VERSION = '5.0';

const my $DOMAIN_ROOT               => 'http://www.side7.com';
const my $GALLERIES_ROOT            => '/public/galleries';
const my $GALLERIES_FILEROOT        => '/data/galleries';
const my $SCHEMA                    => Side7::Schema->db_connect();
const my $USER_SESSION_EXPIRE_TIME  => 172800; # 48 hours in seconds.
const my $ADMIN_SESSION_EXPIRE_TIME => 600;    # 10 minutes in seconds.
const my $DPAE_REALM                => 'site'; # Dancer2::Plugin::Auth::Extensible realm
const my %DEFAULT_SETTINGS          => (
  show_online_status       => 1,
  allow_museum_adds        => 1,
  allow_friend_requests    => 1,
  allow_user_contact       => 1,
  allow_add_to_favorites   => 1,
  show_social_links        => 1,
  filter_categories        => undef,
  filter_ratings           => undef,
  show_m_thmbnails         => 0,
  show_adult_content       => 0,
  email_notifications      => 1,
  notify_on_pm             => 1,
  notify_on_comment        => 1,
  notify_on_friend_request => 1,
  notify_on_mention        => 1,
  notify_on_favorite       => 1,
  notify_on_museum_add     => 1,
);
const my @PROFILE_FIELDS            => (
  qw/ first_name last_name gender_id birthday_visibility state country_id biography /
);


$SCHEMA->storage->debug(1); # Turns on DB debuging. Turn off for production.


=head1 NAME

Side7


=head1 DESCRIPTION

Primary library and route handler for the Side 7 web app.


=head1 HOOKS


=head3 before

Hooks to run before executing each route.

=cut

hook before => sub
{
  if ( logged_in_user )
  {
    my $user =  $SCHEMA->resultset( 'User' )->find( logged_in_user->id );
    var user => $user;
  }
};


=head3 before_template_render

Hooks to execute before template renders

=cut

hook before_template_render => sub
{
  my $tokens = shift;
  $tokens->{domain_root}           = $DOMAIN_ROOT;
  $tokens->{datetime_format_short} = config->{datetime_format_short};
  $tokens->{datetime_format_long}  = config->{datetime_format_long};
  $tokens->{date_format_short}     = config->{date_format_short};
  $tokens->{date_format_long}      = config->{date_format_long};
  if ( logged_in_user )
  {
    my $user = $SCHEMA->resultset( 'User' )->find( logged_in_user->id );
    $tokens->{new_mail_count} = $user->new_mail_count // 0;
  }
};


=head3 after_authenticate_user

Hooks to execute after a user is authenticated.

=cut

hook after_authenticate_user => sub
{
  my ( $params ) = @_;
  my $username = $params->{'username'} // undef;
  my $password = $params->{'password'} // undef;
  my $realm    = $params->{'realm'}    // undef;
  my $errors   = $params->{'errors'}   // undef;
  my $success  = $params->{'success'}  // undef;

  if ( ! $success )
  {
    my $user = $SCHEMA->resultset( 'User' )->search( { username => $username } )->single();
    if ( defined $user and ref( $user ) eq 'Side7::Schema::Result::User' )
    {
      # See if its an old-style password
      if ( Side7::Crypt::old_side7_crypt( $password ) eq $user->password )
      {
        user_password( username => $username, new_password => $password );
        authenticate_user( $username, $password );
      }
    }

    flash( error => '<strong>Trying to pull a fast one, eh?</strong><br>Could not log you in as either your username or your password is invalid.' );
    warning sprintf( 'Invalid login attempt - Username: >%s<, Password: >%s<', $username, $password );

    my $logged = Side7::Log->user_log
    (
      user        => 'Unknown',
      ip_address  => ( request->header('X-Forwarded-For') // 'Unknown' ),
      log_level   => 'Warning',
      log_message => sprintf( 'Invalid login attempt: UN: &gt;%s&lt;, Password: &gt;%s&lt;',
                               $username, $password ),
    );
    redirect '/login';
  }

  # change session ID if we have a new enough D2 version with support
  # (security best practice on privilege level change)
  app->change_session_id if app->can('change_session_id');

  session 'logged_in_user'       => body_parameters->get( 'username' );
  session 'logged_in_user_realm' => $DPAE_REALM;
  session 'logged_in_user_ip'    => ( request->header('X-Forwarded-For') // 'Unknown' );
  session->expires( $USER_SESSION_EXPIRE_TIME );

  my $user = $SCHEMA->resultset( 'User' )->find( logged_in_user->id );
  $user->lastlogin_ip( (request->header('X-Forwarded-For') // 'Unknown' ) );
  $user->update;

  flash( success => sprintf( 'Welcome back, <strong>%s</strong>!', $username ) );
  info sprintf( 'User %s successfully logged in.', $username );
  my $logged = Side7::Log->user_log
  (
    user        => sprintf( '%s (ID:%s)', logged_in_user->username, logged_in_user->id ),
    ip_address  => ( request->header('X-Forwarded-For') // 'Unknown' ),
    log_level   => 'Info',
    log_message => 'Successful login.',
  );
};


=head1 ROUTES


=head2 Redirection Routes


=head3 GET C</image.cgim?image_id=nnnnnn>

Old route to view an image.

=cut

get '/image.cgim' => sub
{
  my $image_id = query_parameters->get( 'image_id' );

  redirect sprintf( '/content/%d', $image_id );
};


=head2 General Routes


=head3 GET C</boilerplate>

Route for styles boilerplate. To be removed before deployment.

=cut

get '/boilerplate' => sub
{
  user_password( username => 'badkarma', new_password => 'Vengence');

  template 'boilerplate';
};


=head3 GET C</>

Route for index page.

=cut

get '/' => sub
{
  my $today = DateTime->today;

  my %stats = ();

  $stats{active_users} = Side7::Util->commify( $SCHEMA->resultset( 'User' )->search(
    { user_status_id => 2 },
  )->count );

  $stats{submissions}  = Side7::Util->commify( $SCHEMA->resultset( 'UserUpload' )->search(
    {}
  )->count );

  my @recents = $SCHEMA->resultset( 'UserUpload' )->search(
    {
      upload_rating_id => { 'not in' => [ 4, 8, 12 ] },
    },
    {
      preload  => [ 'upload_rating', 'upload_category' ],
      order_by => { -desc => 'uploaded_on' },
      rows     => 12,
    }
  );

  my @news = $SCHEMA->resultset( 'News' )->search(
    {
      news_type => 'Standard',
    },
    {
      order_by => { -desc => 'posted_on' },
      rows     => 5
    }
  );

  my @announcements = $SCHEMA->resultset( 'News' )->search(
    {
      news_type => 'Announcement',
      expires_on => { '>' => $today->ymd },
    },
    {
      order_by => { -desc => [ 'posted_on' ] },
    }
  );

  foreach my $upload ( @recents )
  {
    $upload->check_thumbnail();
  }

  template 'index',
  {
    data =>
    {
      announcements => \@announcements,
      news          => \@news,
      recents       => \@recents,
      stats         => \%stats,
      user          => vars->{user},
    }
  };
};


=head3 GET C</news/:page>

Route to the news listing page.

=cut

get '/news/?:page?' => sub
{
  my $page  = route_parameters->get( 'page' ) // 1;
  my $today = DateTime->today;

  my @news = $SCHEMA->resultset( 'News' )->search(
    {
      news_type => 'Standard',
    },
    {
      rows     => 10,
      page     => $page,
      order_by => { -desc => 'posted_on' },
    }
  );

  my @announcements = $SCHEMA->resultset( 'News' )->search(
    {
      news_type => 'Announcement',
      expires_on => { '>' => $today->ymd },
    },
    {
      order_by => { -desc => [ 'posted_on' ] },
    }
  );

  template 'news',
  {
    data =>
    {
      page          => $page,
      news          => \@news,
      announcements => \@announcements,
      user          => vars->{user},
    },
    title => 'News',
    breadcrumbs =>
    [
      { name => 'News', current => 1 },
    ],
  };
};


=head3 GET C</news/item/:news_id>

Route for pulling up a specific news item.

=cut

get '/news/item/:news_id' => sub
{
  my $news_id = route_parameters->get( 'news_id' );

  if
  (
    ! defined $news_id
    or
    $news_id < 1
    or
    $news_id !~ m/^\d+$/
  )
  {
    flash( error => "<strong>Who moved my stuff!?</strong><br>Could not find the news item you requested." );
    warning sprintf( 'Invalid or missing news id provided - ID: >%s<', $news_id );
    my $logged = Side7::Log->admin_log
    (
      user        => ( ( logged_in_user ) ? sprintf( '%s (ID:%s)', logged_in_user->username, logged_in_user->id ) : 'Unknown' ),
      ip_address  => ( request->header('X-Forwarded-For') // 'Unknown' ),
      log_level   => 'Warning',
      log_message => sprintf( 'Invalid or missing news_id provided for /news/:news_id - &quot;%s&quot;', $news_id ),
    );
  }

  my $news = $SCHEMA->resultset( 'News' )->find( $news_id );

  if
  (
    ! defined $news
    or
    ref( $news ) ne 'Side7::Schema::Result::News'
  )
  {
    flash( error => "<strong>Who moved my stuff!?</strong><br>Could not find the news item you requested." );
    warning sprintf( 'Bad news ID - Could not retrieve news item - ID: >%s<', $news_id );
    my $logged = Side7::Log->admin_log
    (
      user        => ( ( logged_in_user ) ? sprintf( '%s (ID:%s)', logged_in_user->username, logged_in_user->id ) : 'Unknown' ),
      ip_address  => ( request->header('X-Forwarded-For') // 'Unknown' ),
      log_level   => 'Warning',
      log_message => sprintf( 'Invalid news_id provided for /news/:news_id - &quot;%s&quot;', $news_id ),
    );
  }

  template 'news_item',
  {
    data =>
    {
      item => $news,
      user => vars->{user},
    },
    title => $news->title,
    breadcrumbs =>
    [
      { name => 'News', link => '/news' },
      { name => $news->title, current => 1 },
    ],
  };

};


=head3 GET C</faq>

Route to get the FAQ page.

=cut

get '/faq' => sub
{
  my @categories = $SCHEMA->resultset( 'FAQCategory' )->search(
    {},
    {
      order_by => 'sort_order',
    }
  )->all;

  template 'faq',
  {
    data =>
    {
      categories => \@categories,
      user       => vars->{user},
    },
    title => 'Frequently Asked Questions',
    breadcrumbs =>
    [
      { name => 'FAQ', current => 1 },
    ]
  }
};


=head3 GET C</faq/:category_id>

Route to fetch all articles in a FAQ category.

=cut

get '/faq/:category_id' => sub
{
  my $category_id = route_parameters->get( 'category_id' );

  if ( ! defined $category_id or $category_id =~ m/\D/ )
  {
    flash( warning => '<strong>Say what?</strong><br>Not sure what FAQ category you were looking for.' );
    redirect '/faq';
  }

  my $category = $SCHEMA->resultset( 'FAQCategory' )->find( $category_id );

  if
  (
    ! defined $category
    or
    ref( $category ) ne 'Side7::Schema::Result::FAQCategory'
  )
  {
    flash( error => '<strong>Uh oh! Something went wrong!</strong><br>Could not find the FAQ category you were looking for.' );
    redirect '/faq';
  }

  my @entries = $category->search_related( 'entries', {}, { order_by => 'sort_order' } )->all;

  template 'faq_category',
  {
    data =>
    {
      category => $category,
      entries  => \@entries,
      user     => vars->{user},
    },
    title => sprintf( 'FAQ | %s', $category->category ),
    breadcrumbs =>
    [
      { name => 'FAQ', link => '/faq' },
      { name => $category->category, current => 1 },
    ]
  }

};


=head3 GET C</faq/:category_id/:entry_id>

Route to fetch a specific article in a FAQ category.

=cut

get '/faq/:category_id/:entry_id' => sub
{
  my $category_id = route_parameters->get( 'category_id' );
  my $entry_id    = route_parameters->get( 'entry_id' );

  if ( ! defined $category_id or $category_id =~ m/\D/ )
  {
    flash( warning => '<strong>Say what?</strong><br>Not sure what FAQ category you were looking for.' );
    redirect '/faq';
  }

  if ( ! defined $entry_id or $entry_id =~ m/\D/ )
  {
    flash( warning => '<strong>Say what?</strong><br>Not sure what FAQ entry you were looking for.' );
    redirect '/faq';
  }

  my $category = $SCHEMA->resultset( 'FAQCategory' )->find( $category_id );

  if
  (
    ! defined $category
    or
    ref( $category ) ne 'Side7::Schema::Result::FAQCategory'
  )
  {
    flash( error => '<strong>Uh oh! Something went wrong!</strong><br>Could not find the FAQ category you were looking for.' );
    redirect '/faq';
  }

  my $entry = $category->search_related( 'entries', { id => $entry_id } )->single;

  if
  (
    ! defined $entry
    or
    ref( $entry ) ne 'Side7::Schema::Result::FAQEntry'
  )
  {
    flash( error => '<strong>Uh oh! Something went wrong!</strong><br>Could not find the FAQ entry you were looking for.' );
    redirect sprintf( '/faq/%d', $category_id );
  }

  template 'faq_entry',
  {
    data =>
    {
      category => $category,
      entry    => $entry,
      user     => vars->{user},
    },
    title => sprintf( 'FAQ | %s', $entry->question ),
    breadcrumbs =>
    [
      { name => 'FAQ', link => '/faq' },
      { name => $category->category, link => sprintf( '/faq/%d', $category->id ) },
      { name => $entry->question, current => 1 },
    ]
  }
};


=head3 GET C</browse/directory/?:initial?>

Route to browse the user directory.

=cut

get '/browse/directory/?:initial?' => sub
{
  my $initial = route_parameters->get( 'initial' ) // 'A';

  my $initial_name = uc( $initial );
  if ( $initial eq '@' )
  {
    $initial = '[[:punct:]]';
    $initial_name = 'Non-alphanumeric';
  }

  my @users = $SCHEMA->resultset( 'User' )->search(
    { username => { like => $initial . '%' } }
  )->all;

  template 'user_directory',
  {
    data =>
    {
      current => $initial_name,
      user    => vars->{user},
      users   => \@users,
    },
    title => sprintf( 'User Directory | %s', $initial_name ),
    breadcrumbs =>
    [
      { name => 'Browse', link => '/browse' },
      { name => 'User Directory', link => '/browse/directory' },
      { name => $initial_name, current => 1 },
    ]
  }
};


=head3 GET C</browse/recents/?:page?>

Route to browse the user directory.

=cut

get '/browse/recents/?:page?' => sub
{
  my $page = route_parameters->get( 'page' ) // 1;
  my @recents = $SCHEMA->resultset( 'UserUpload' )->search(
    {},
    {
      rows     => 48,
      page     => $page,
      order_by => { -desc => 'uploaded_on' }
    }
  )->all;

  foreach my $recent ( @recents )
  {
    $recent->check_thumbnail();
  }

  my $template = ( $page > 1 ) ? 'recents_addl' : 'recents';
  my $layout   = ( $page > 1 ) ? 'ajax-modal'   : 'main';

  template $template,
  {
    data =>
    {
      user    => vars->{user},
      recents => \@recents,
    },
    title => 'Recent Submissions',
    breadcrumbs =>
    [
      { name => 'Browse', link => '/browse' },
      { name => 'Recent Submissions', current => 1 },
    ]
  },
  {
    layout => $layout
  }
};


=head3 GET C</content/:content_id>

Route to display user-uploaded content.

=cut

get '/content/:content_id' => sub
{
  my $content_id = route_parameters->get( 'content_id' );

  if ( ! defined $content_id or $content_id !~ /^\d+$/ )
  {
    warning sprintf( 'Invalid content_id provided for /content/:content_id : >%s<', $content_id );
    send_error( 'Content not found.', 404 );
  }

  my $upload = $SCHEMA->resultset( 'UserUpload' )->find(
    {
      id => $content_id
    },
    {
      prefetch =>
      {
        comment_threads => 'comments',
      }
    }
  );

  if
  (
    ! defined $upload
    or
    ref( $upload ) ne 'Side7::Schema::Result::UserUpload'
  )
  {
    send_error( 'Content not found.', 404 );
  }

  my $now = DateTime->today( time_zone => 'UTC' )->ymd;

  $upload->views( $upload->views + 1 );
  $upload->update;

  my $upload_views = $upload->search_related( 'view_records', {} );
  $upload_views->update_or_create(
    {
      date      => $now,
      views     => \'views + 1',
      upload_id => $content_id
    },
    { key => 'upload_views_upload_id_date' }
  );

  my $next_upload = $upload->user->search_related( 'uploads',
      { id => { '>' => $content_id } },
      { order_by => 'id', rows => 1 } )->single;
  my $prev_upload = $upload->user->search_related( 'uploads',
      { id => { '<' => $content_id } },
      { order_by => { -desc => 'id' }, rows => 1 } )->single;

  my @view_dates = ();
  if ( logged_in_user )
  {
    if ( logged_in_user->id == $upload->user->id )
    {
      my @last_30_days = $upload->search_related( 'view_records', {}, { order_by => { -desc => 'date' }, rows => 30 } );

      my $stop = DateTime->today;
      my $start = $stop->clone();
      $start->subtract( days => 31 );
      while ( $start->add( days => 1 ) < $stop )
      {
        my $found = 0;
        foreach my $date ( @last_30_days )
        {
          if ( $start->ymd('-') eq $date->date )
          {
            push @view_dates, { $start->strftime('%d %b') => $date->views };
            $found = 1;
            last;
          }
        }
        if ( $found == 0 )
        {
          push @view_dates, { $start->strftime('%d %b') => 0 };
        }
      }
    }
  }

  template 'user_upload_base.tt',
  {
    data =>
    {
      upload      => $upload,
      next_upload => $next_upload,
      prev_upload => $prev_upload,
      view_dates  => \@view_dates,
      user        => vars->{user},
    },
    og =>
    {
      url         => sprintf( '%s/content/%d', $DOMAIN_ROOT, $content_id ),
      description => $upload->description,
      image       => sprintf( '%s/galleries%s/%s', $DOMAIN_ROOT, $upload->user->dirpath, $upload->filename ),
    },
    title => sprintf( '%s By %s', $upload->title, $upload->user->full_name ),
  };
};

################################################
# ROUTES THAT USE AJAX
################################################


=head2 AJAX Routes


=head3 GET C</upload-tooltip/:upload_id>

Route to pull via AJAX the HTML contents for a thumbnail tooltip.

=cut

get '/upload-tooltip/:upload_id' => sub
{
  my $upload_id = route_parameters->get( 'upload_id' );

  my $upload = $SCHEMA->resultset( 'UserUpload' )->find( $upload_id );

  template 'upload_tooltip',
    {
      data =>
      {
        upload => $upload,
      },
    },
    {
      layout => undef
    };
};


################################################
# ROUTES REGARDING SIGNUP/LOGIN/LOGOUT
################################################


=head2 Routes Regarding Signup/Login/Logout

=cut


=head3 GET C</reset_password>

Route to reset a user's password.

=cut

get '/reset_password' => sub
{
  template 'reset_password_form', { title => 'Reset Password' };
};


=head3 POST C</reset_password>

Route for posting a username to the system to reset the password, and send out a reset code to the user.

=cut

post '/reset_password' => sub
{
  my $username = body_parameters->get( 'username' );

  my $sent = password_reset_send( username => $username, realm => $DPAE_REALM );

  if ( not defined $sent )
  {
    warning sprintf( 'Username >%s< found, but password reset email was not sent for some reason during resest_password.', $username );
  }
  elsif ( $sent == 0 )
  {
    warning sprintf( 'No record found for user >%s< during reset_password.', $username );
  }
  else
  {
    info sprintf( 'Successfully sent password_reset email to account >%s<.', $username );
  }

  flash( notify => 'A password reset email was sent to the email address associated with that account, if it exists.' );
  my $logged = Side7::Log->user_log
  (
    user        => 'Unknown',
    ip_address  => ( request->header('X-Forwarded-For') // 'Unknown' ),
    log_level   => 'Info',
    log_message => sprintf( 'Password Reset request for &quot;%s&quot;', $username ),
  );

  redirect '/login';
};


=head3 GET C</reset_my_password/:code>

Route to submit password reset request code and confirm the request.

=cut

get '/reset_my_password/?:code?' => sub
{
  my $code = route_parameters->get( 'code' ) // undef;

  if ( not defined $code )
  {
    return template '/reset_my_password_form',
    {
    };
  }

  my $username = user_password( code => $code );

  if ( not defined $username )
  {
    warning sprintf( 'Password Reset Code >%s< resulted in no user found.', $code );
    flash( error => 'Could not find your reset code. Password reset request was not fulfilled.' );
    redirect '/reset_my_password';
  }

  my $new_temp_pw = Side7::Util->generate_random_string( string_length => 8 );

  user_password( code => $code, new_password => $new_temp_pw );

  authenticate_user
  (
    $username, $new_temp_pw
  );

  flash( success => sprintf( 'Welcome back, %s!', $username ) );
  redirect sprintf( '/user/change_password/%s', $new_temp_pw );
};


=head3 GET C</signup>

Route to the sign-up form.

=cut

get '/signup' => sub
{
  template 'signup', { title => 'Sign Up For An Account' };
};


=head3 POST C</signup>

Process sign-up information, and error-check.

=cut

post '/signup' => sub
{
  my $user_check = $SCHEMA->resultset( 'User' )->find( { username => body_parameters->get( 'username' ) } );

  if (
      defined $user_check
      &&
      ref( $user_check ) eq 'Side7::Schema::Result::User'
      &&
      $user_check->username eq body_parameters->get( 'username' )
     )
  {
    flash( error => sprintf( 'Username <strong>%s</strong> is already in use.', body_parameters->get( 'username' ) ) );
    redirect '/signup';
  }

  my $email_check = $SCHEMA->resultset( 'User' )->find( { email_address => body_parameters->get( 'email_address' ) } );

  if (
      defined $email_check
      &&
      ref( $email_check ) eq 'Side7::Schema::Result::User'
      &&
      $email_check->email_address eq body_parameters->get( 'email_address' )
     )
  {
    flash( error => sprintf( 'There is already an account associated to the email address <strong>%s</strong>.', body_parameters->get( 'email_address' ) ) );
    redirect '/signup';
  }

  my $now = DateTime->now( time_zone => 'UTC' )->datetime;

  # Create the user, and send the welcome e-mail.
  my $new_user = create_user(
    username       => body_parameters->get( 'username' ),
    #password       => body_parameters->get( 'password' ),
    email_address  => body_parameters->get( 'email_address' ),
    birthday       => body_parameters->get( 'birthday' ),
    user_status_id => 1,
    gender_id      => 1,
    country_id     => 1,
    confirmed      => 0,
    confirm_code   => Side7::Util->generate_random_string(),
    created_at     => $now,
    realm          => $DPAE_REALM,
    email_welcome  => 1,
  );

  # Set the passord, encrypted.
  my $set_password = user_password( username => body_parameters->get( 'username' ), new_password => body_parameters->get( 'password' ) );

  # Set the initial user_role
  my $base_role = $SCHEMA->resultset( 'Role' )->find( { role => 'New Signup' } );

  my $user_role = $SCHEMA->resultset( 'UserRole' )->new(
                                                        {
                                                          user_id => $new_user->id,
                                                          role_id => $base_role->id,
                                                        }
                                                       );
  $SCHEMA->txn_do(
                  sub
                  {
                    $user_role->insert;
                  }
  );

  # Set initial user_settings.
  $new_user->create_related( 'settings',
    (
      %DEFAULT_SETTINGS,
      { updated_on         => $now, },
    )
  );

  info sprintf( 'Created new user >%s<, ID: >%s<, on %s', body_parameters->get( 'username' ), $new_user->id, $now );

  flash( success => sprintf("Thanks for signing up, %s! You have been logged in.", body_parameters->get( 'username' ) ) );
  my $logged = Side7::Log->user_log
  (
    user        => sprintf( '%s (ID:%s)', $new_user->username, $new_user->id ),
    ip_address  => ( request->header('X-Forwarded-For') // 'Unknown' ),
    log_level   => 'Info',
    log_message => 'New User Sign Up',
  );

  # change session ID if we have a new enough D2 version with support
  # (security best practice on privilege level change)
  app->change_session_id if app->can('change_session_id');

  session 'logged_in_user' => body_parameters->get( 'username' );
  session 'logged_in_user_realm' => $DPAE_REALM;
  session->expires( $USER_SESSION_EXPIRE_TIME );

  redirect '/signed_up';
};


=head3 GET C</signed_up>

Successful sign-up page, with next-step instructions for account confirmation.

=cut

get '/signed_up' => require_login sub
{
  if ( ! session( 'logged_in_user' ) )
  {
    info 'An anonymous (not logged in) user attempted to access /signed_up.';
    flash( error => 'You need to be logged in to access that page.' );
    redirect '/login';
  }

  my $user = $SCHEMA->resultset( 'User' )->find( { username => logged_in_user->username } );

  if ( ref( $user ) ne 'Side7::Schema::Result::User' )
  {
    warning sprintf( 'A user (%s) attempted to reach /signed_up, but the account could not be confirmed to exist.', session( 'user' ) );
    flash( error => 'You need to be logged in to access that page.' );
    redirect '/login';
  }

  template 'signed_up_success',
    {
      data =>
      {
        user         => $user,
        from_address => config->{mailer_address},
      },
      title => 'Thanks for Signing Up!',
    };
};


=head3 GET C</resend_confirmation>

Route for a User to request that their confirmation e-mail be resent to them.

=cut

get '/resend_confirmation' => sub
{
  # If the user is logged in, use that information and redirect.
  if ( defined logged_in_user )
  {
    my $sent = Side7::Mail::send_welcome_email
    (
      undef,
      user  => { username => logged_in_user->username }, # Expects a hashref for the user. Only needs username
      email => logged_in_user->email_address,
    );
    if ( $sent->{'success'} )
    {
      flash( success => sprintf( 'We have resent the confirmation email to your account at &quot;<strong>%s</strong>&quot;.', logged_in_user->email_address ) );
      info sprintf( "Resent confirmation email at user's request to >%s<.", logged_in_user->email_address );
      my $logged = Side7::Log->user_log
      (
        user        => sprintf( '%s (ID:%s)', logged_in_user->username, logged_in_user->id ),
        ip_address  => ( request->header('X-Forwarded-For') // 'Unknown' ),
        log_level   => 'Info',
        log_message => 'Resent confirmation email.',
      );
      redirect '/user';
    }
    else
    {
      flash( error => 'An error has occurred and we could not resend the confirmation email. Please try again in a few minutes.' );
      error sprintf( "Error occurred when trying to resend the confirmation code to >%s<: %s", logged_in_user->email_address, $sent->{'error'} );
      my $logged = Side7::Log->user_log
      (
        user        => sprintf( '%s (ID:%s)', logged_in_user->username, logged_in_user->id ),
        ip_address  => ( request->header('X-Forwarded-For') // 'Unknown' ),
        log_level   => 'Error',
        log_message => sprintf( 'Confirmation Email Resend failed to &gt;%s&lt;: %s', logged_in_user->email_address, $sent->{'error'} ),
      );
      redirect '/user';
    }
  }

  # If the user is not logged in, request an e-mail address and username.
  template 'resend_confirmation',
    {
      breadcrumbs =>
      [
        { name => 'Sign Up', link => '/login' },
        { name => 'Resend Confirmation Email', current => 1 },
      ],
    };
};


=head3 POST C</resend_confirmation>

Route to submit credentials for resending confirmation e-mails.

=cut

post '/resend_confirmation' => sub
{
  my $username = body_parameters->get( 'username ' ) // undef;
  my $email    = body_parameters->get( 'email' )     // undef;

  if
  (
    not defined $username
    or
    not defined $email
  )
  {
    flash( error => 'Both your username and your email address are required.' );
    redirect '/resend_confirmation';
  }

  my $user = $SCHEMA->resultset( 'User' )->find
  (
    {
      username      => $username,
      email_address => $email,
    }
  );

  if
  (
    not defined $user
    or
    ref( $user ) ne 'Side7::Schema::Result::User'
  )
  {
    error sprintf( 'Invalid user credentials on resend confirmation: user - >%s< / email - >%s<', $username, $email );
    flash( error => 'An error occurred in trying to locate your account.<br>Some or all of the information you have provided is incorrect.' );
    my $logged = Side7::Log->user_log
    (
      user        => 'Unknown',
      ip_address  => ( request->header('X-Forwarded-For') // 'Unknown' ),
      log_level   => 'Error',
      log_message => sprintf( 'Resend Confirmation Failed: Invalid credentials - &gt;%s&lt; &gt;%s&lt;', $username, $email ),
    );
    redirect '/resend_confirmation';
  }

  my $sent = Side7::Mail::send_welcome_email
  (
    user  => $user->username,
    email => $user->email_address,
  );
  if ( $sent->{'success'} )
  {
    flash( success => sprintf( 'We have resent the confirmation email to your account at &quot;<strong>%s</strong>%quot;.', $user->email_address ) );
    info sprintf( "Resent confirmation email at user's request to >%s<.", $user->email_address );
    my $logged = Side7::Log->user_log
    (
      user        => 'Unknown',
      ip_address  => ( request->header('X-Forwarded-For') // 'Unknown' ),
      log_level   => 'Info',
      log_message => sprintf( 'Confirmation Email Resent: &gt;%s&lt;', $user->email_address ),
    );
    redirect '/';
  }
  else
  {
    flash( error => 'An error has occurred and we could not resend the confirmation email. Please try again in a few minutes.' );
    error sprintf( "Error occurred when trying to resend the confirmation code to >%s<: %s", $user->email_address, $sent->{'error'} );
    my $logged = Side7::Log->user_log
    (
      user        => 'Unknown',
      ip_address  => ( request->header('X-Forwarded-For') // 'Unknown' ),
      log_level   => 'Error',
      log_message => sprintf( 'Resend Confirmation Failed: Email send failed - &gt;%s&lt;: &gt;%s&lt;', $user->email_address, $sent->{'error'} ),
    );
    redirect '/resend_confirmation';
  }
};


=head3 GET C</login>

Login page for redirection, login errors, reattempt, etc.

=cut

get '/login' => sub
{
  my $return_url = query_parameters->get( 'return_url' ) // body_parameters->get( 'return_url' );

  if ( defined logged_in_user )
  {
    redirect '/user';
  }

  template 'login',
    {
      data =>
      {
        return_url => $return_url
      },
      title => 'Login to Your Account',
    };
};


=head3 POST C</login>

Authenticates user, and logs them in.  Otherwise, redirects them to the login page.

=cut

post '/login' => sub
{
  my $username = body_parameters->get( 'username' );
  my $password = body_parameters->get( 'password' );
  my $return_url = body_parameters->get( 'return_url' ) // '/user';

  warning sprintf( 'About to run authenticate_user on %s/%s with a return_url to %s', $username, $password, $return_url );

  authenticate_user( $username, $password );

  redirect $return_url;

};


=head3 ANY C</logout>

Logout route, for killing user sessions, and redirecting to the index page.

=cut

any '/logout' => sub
{
  app->destroy_session;
  flash( notify => 'You are logged out. Come back soon!' );
};


=head3 ANY C</login/denied>

User denied access route for authentication failures.

=cut

any '/login/denied' => sub
{
  template 'login_denied';
};


=head3 GET C</account_confirmation>

GET route for confirmation code submission from welcome e-mails.

=cut

get '/account_confirmation/:ccode' => sub
{
  my $ccode = route_parameters->get( 'ccode' );

  my $user = $SCHEMA->resultset( 'User' )->find( { confirm_code => $ccode } );

  if ( ! defined $user || ref( $user ) ne 'Side7::Schema::Result::User' )
  {
    info sprintf( 'Confirmation Code submitted >%s< matched no user.', $ccode );
    return template 'account_confirmation', {
                                              data =>
                                              {
                                                ccode => $ccode,
                                              },
                                            };
  }

  update_user( $user->username, realm => $DPAE_REALM, confirm_code => undef, confirmed => 1 );

  # Set the user_role to Confirmed
  my $unconfirmed_role = $SCHEMA->resultset( 'Role' )->find( { role => 'Unconfirmed' } );
  my $role_to_delete   = $SCHEMA->resultset( 'UserRole' )->find( { user_id => $user->id, role_id => $unconfirmed_role->id } );
  $role_to_delete->delete();

  my $confirmed_role = $SCHEMA->resultset( 'Role' )->find( { role => 'Confirmed' } );

  my $user_role = $SCHEMA->resultset( 'UserRole' )->new(
                                                        {
                                                          user_id => $user->id,
                                                          role_id => $confirmed_role->id,
                                                        }
                                                       );
  $SCHEMA->txn_do(
                  sub
                  {
                    $user_role->insert;
                  }
  );
  info sprintf( 'User >%s< successfully confirmed.', $user->username );
  my $logged = Side7::Log->user_log
  (
    user        => sprintf( '%s (ID:%s)', $user->username, $user->id ),
    ip_address  => ( request->header('X-Forwarded-For') // 'Unknown' ),
    log_level   => 'Info',
    log_message => 'Successful account confirmation.',
  );

  template 'account_confirmation',
    {
      data =>
      {
        success => 1,
        user    => $user,
      },
      title => 'Account Confirmation',
    };
};


=head3 POST C</account_confirmation>

POST route for confirmation code resubmission.

=cut

post '/account_confirmation' => sub
{
  my $ccode = body_parameters->get( 'ccode' );

  redirect "/account_confirmation/$ccode";
};

################################################
# ROUTES REQUIRING LOGGED_IN_USER
################################################


=head2 Routes Regarding logged_in_user

=cut

################################################
# USER_DASHBOARD ROUTES
################################################


=head3 GET C</user>

GET route for User Dashboard

=cut

get '/user' => require_login sub
{
  my $user = vars->{user};

  my $total_submissions = $user->search_related( 'uploads', {} )->count;

  my @img_count = $SCHEMA->resultset( 'UserUpload' )->search( {},
    {
      select   => [ 'upload_category.category', { count => 'me.id', -as => 'num_images' } ],
      as       => [ 'category', 'num_images' ],
      join     => [ 'upload_category' ],
      where    => { user_id => logged_in_user->id, 'me.upload_type_id' => 1 },
      group_by => [ 'upload_category_id' ],
      order_by => { -desc => 'num_images' },
    }
  );
  my @aud_count = $user->search_related( 'uploads', {},
    {
      select   => [ 'upload_category.category', { count => 'me.id', -as => 'num_audio' } ],
      as       => [ 'category', 'num_audio' ],
      join     => [ 'upload_category' ],
      where    => { user_id => logged_in_user->id, 'me.upload_type_id' => 2 },
      group_by => [ 'upload_category_id' ],
      order_by => { -desc => 'num_audio' },
    }
  );
  my @lit_count = $user->search_related( 'uploads', {},
    {
      select   => [ 'upload_category.category', { count => 'me.id', -as => 'num_lit' } ],
      as       => [ 'category', 'num_lit' ],
      join     => [ 'upload_category' ],
      where    => { user_id => logged_in_user->id, 'me.upload_type_id' => 3 },
      group_by => [ 'upload_category_id' ],
      order_by => { -desc => 'num_lit' },
    }
  );

  my @img_counts = ();
  foreach my $pair ( @img_count )
  {
    push @img_counts, { category => $pair->get_column( 'category' ), num_images => $pair->get_column( 'num_images' ) };
  }

  my @aud_counts = ();
  foreach my $pair ( @aud_count )
  {
    push @aud_counts, { category => $pair->get_column( 'category' ), num_audio => $pair->get_column( 'num_audio' ) };
  }

  my @lit_counts = ();
  foreach my $pair ( @lit_count )
  {
    push @lit_counts, { category => $pair->get_column( 'category' ), num_lit => $pair->get_column( 'num_lit' ) };
  }

  my @last_4_subs = $user->search_related( 'uploads', {}, { order_by => { -desc => 'uploaded_on' }, rows => 4 } );

  foreach my $upload ( @last_4_subs )
  {
    $upload->check_thumbnail();
  }

  my $credits_rs = $user->search_related( 'credits', {},
    {
      select => [ { sum => 'amount' } ],
      as     => [ 'balance' ],
    }
  );
  my $balance = $credits_rs->first->get_column('balance');

  template "user_dashboard_home",
  {
    data =>
    {
      user        => $user,
      image_count => \@img_counts,
      audio_count => \@aud_counts,
      lit_count   => \@lit_counts,
      total_submissions => $total_submissions,
      last_4_subs => \@last_4_subs,
      balance     => $balance,
    },
    title => 'Overview',
  },
  {
    layout => 'user_dashboard'
  };
};


=head3 GET C</user/credit_history>

Route to pull up the user's account credit transaction history.

=cut

get '/user/credit_history' => require_login sub
{
  my $user = vars->{user};

  my @transactions = $user->search_related( 'credits', {}, { order_by => { -desc => 'timestamp' } } )->all;

  my $credits_rs = $user->search_related( 'credits', {},
    {
      select => [ { sum => 'amount' } ],
      as     => [ 'balance' ],
    }
  );
  my $balance = $credits_rs->first->get_column('balance');

  template 'user_dashboard_credit_history',
  {
    data =>
    {
      transactions => \@transactions,
      balance      => $balance,
    },
    title => 'Credit History',
  },
  {
    layout => 'user_dashboard'
  };
};


=head3 GET C</user/profile/edit>

Route to pull up the user's profile management page.

=cut

get '/user/profile/edit' => require_login sub
{
  my $user           = $SCHEMA->resultset( 'User' )->find( logged_in_user->id );
  my @genders        = $SCHEMA->resultset( 'UserGender' )->search( {} )->all;
  my @countries      = $SCHEMA->resultset( 'Country' )->search( {} )->all;
  my @system_avatars = $SCHEMA->resultset( 'SystemAvatar' )->search( {} )->all;
  my @user_avatars   = $user->search_related( 'avatars' )->search( {} )->all;

  template 'user_dashboard_profile',
  {
    data =>
    {
      user           => $user,
      genders        => \@genders,
      countries      => \@countries,
      user_avatars   => \@user_avatars,
      system_avatars => \@system_avatars,
    },
    title => 'Profile',
  },
  {
    layout => 'user_dashboard'
  };
};


=head3 GET C</user/message_center>

Route to pull up the user's message center page.

=cut

get '/user/message_center' => require_login sub
{
  my $user = vars->{user};

  my $mail_rs      = $user->received_mail( { is_deleted => 0 }, { order_by => { -desc => 'timestamp' } } );
  my $mail_count   = $mail_rs->count();
  my $unread_count = $mail_rs->search( { is_read => 0 } )->count();
  my @all_mail     = $mail_rs->all();

  template 'user_dashboard_message_center',
  {
    data =>
    {
      all_mail     => \@all_mail,
      mail_count   => $mail_count,
      unread_count => $unread_count,
      folder       => 'Inbox',
    },
    title => 'Messages',
  },
  {
    layout => 'user_dashboard'
  };
};


=head3 GET C</user/settings>

Route to pull up the user's settings page.

=cut

get '/user/settings' => require_login sub
{
  my $user = vars->{user};

  my $today = DateTime->today;
  my ($byear, $bmon, $bday) = split( '-', $user->birthday );
  my $birthday = DateTime->new( year => $byear, month => $bmon, day => $bday );
  my $user_age = $today->subtract_datetime( $birthday );

  my @categories = $SCHEMA->resultset( 'UploadCategory' )->search()->all;
  my @ratings    = $SCHEMA->resultset( 'UploadRating' )->search()->all;

  my $user_settings = $user->search_related( 'settings' )->single;

  # Defaults
  my %settings =
  (
    'show_online_status'     => (( defined $user_settings ) ? $user_settings->show_online_status     : 1 ),
    'allow_museum_adds'      => (( defined $user_settings ) ? $user_settings->allow_museum_adds      : 1 ),
    'allow_friend_requests'  => (( defined $user_settings ) ? $user_settings->allow_friend_requests  : 1 ),
    'allow_user_contact'     => (( defined $user_settings ) ? $user_settings->allow_user_contact     : 1 ),
    'allow_add_to_favorites' => (( defined $user_settings ) ? $user_settings->allow_add_to_favorites : 1 ),
    'show_social_links'      => (( defined $user_settings ) ? $user_settings->show_social_links      : 1 ),

    'filter_categories'      => (( defined $user_settings ) ? $user_settings->filter_categories      : '' ),
    'filter_ratings'         => (( defined $user_settings ) ? $user_settings->filter_ratings         : '' ),
    'show_m_thumbnails'      => (( defined $user_settings ) ? $user_settings->show_m_thumbnails      : 0 ),
    'show_adult_content'     => (( defined $user_settings ) ? $user_settings->show_adult_content     : 0 ),
    'over_18'                => (( $user_age->years() >= 18 ) ? 1 : 0 ),

    'email_notifications'    => (( defined $user_settings ) ? $user_settings->email_notifications    : 1 ),
    'notify_on_pm'           => (( defined $user_settings ) ? $user_settings->notify_on_pm           : 1 ),
    'notify_on_comment'      => (( defined $user_settings ) ? $user_settings->notify_on_comment      : 1 ),
    'notify_on_friend_request' => (( defined $user_settings ) ? $user_settings->notify_on_friend_request : 1 ),
    'notify_on_mention'      => (( defined $user_settings ) ? $user_settings->notify_on_mention      : 1 ),
    'notify_on_favorite'     => (( defined $user_settings ) ? $user_settings->notify_on_favorite     : 1 ),
    'notify_on_museum_add'   => (( defined $user_settings ) ? $user_settings->notify_on_museum_add   : 1 ),
    'updated_on'             => (( defined $user_settings ) ? $user_settings->updated_on             : 'Never' ),
  );

  my $category_filter_count = scalar( split( /,/, $settings{'filter_categories'} ) ) // 0;

  template 'user_dashboard_settings',
  {
    data =>
    {
      settings   => \%settings,
      categories => \@categories,
      ratings    => \@ratings,
      category_filter_count => $category_filter_count,
    },
    title => 'Settings',
  },
  {
    layout => 'user_dashboard'
  };
};


################################################
# ROUTES THAT USE AJAX
################################################


=head3 post C</user/profile/update>

Route to update a user's profile.

=cut

post '/user/profile/update' => require_login sub
{
  my $user      = vars->{user};
  my %form_data = params( 'body' );

  my $now = DateTime->now( time_zone => 'UTC' )->datetime;

  my @json = ();
  if ( ! defined $user )
  {
    push( @json, { success => 0, message => 'Invalid user account.' } );
    error sprintf( 'An invalid user ID was submitted when attempting to update the profile. >%s<', logged_in_user->id );
    return to_json( \@json );
  }

  my $old = {}; my $new = {};

  foreach my $field ( @PROFILE_FIELDS )
  {
    $old->{$field} = $user->$field;
    $new->{$field} = $form_data{$field} // undef;
    $user->$field( ( ( defined $form_data{$field} ) ? $form_data{$field} : undef ) );
  }

  $user->updated_at( $now );
  $user->update;

  my $diffs = Side7::Log->find_changes_in_data( old_data => $old, new_data => $new );
  my $logged = Side7::Log->user_log
  (
    user        => sprintf( '%s (ID:%s)', $user->username, logged_in_user->id ),
    ip_address  => ( request->header('X-Forwarded-For') // 'Unknown' ),
    log_level   => 'Info',
    log_message => sprintf( 'Profile updated.', ),
  );

  push( @json, { success => 1, message => 'Your profile has been updated.' } );
  return to_json( \@json );
};


=head3 POST C</user/avatar/select>

Route to select an avatar.

=cut

post '/user/avatar/select' => require_login sub
{
  my $avatar_id   = body_parameters->get( 'avatar_id' )   // undef;
  my $avatar_type = body_parameters->get( 'avatar_type' ) // 'None';
  my $user        = vars->{user};

  my @json = ();
  # Avatar Type should be one of: None, Gravatar, System, Image
  if (
    $avatar_type ne 'None' && $avatar_type ne 'Gravatar'
    && $avatar_type ne 'Image' && $avatar_type ne 'System'
  )
  {
    push( @json, { success => 0, message => '<strong>What\'s that now?</strong><br>Invalid Avatar type selected' } );
    return to_json( \@json );
  }

  if ( uc($avatar_type) eq 'NONE' )
  {
    $user->avatar_type( 'None' );
    $user->avatar_id( undef );
    $user->update;
  }

  if ( uc($avatar_type) eq 'GRAVATAR' )
  {
    $user->avatar_type( 'Gravatar' );
    $user->avatar_id( undef );
    $user->update;
  }

  if ( uc($avatar_type) eq 'SYSTEM' )
  {
    if ( $avatar_id !~ m/^s-/ )
    {
      warning sprintf( 'Invalid system avatar ID provided when setting avatar: %s', $avatar_id );
      push( @json, { success => 0, message => '<strong>Wha?</strong><br>Invalid Avatar ID' } );
      return to_json( \@json );
    }
    $avatar_id =~ s/^s-//;
    $user->avatar_type( 'System' );
    $user->avatar_id( $avatar_id );
    $user->update;
  }

  if ( uc($avatar_type) eq 'IMAGE' )
  {
    if ( $avatar_id !~ m/^u-/ )
    {
      warning sprintf( 'Invalid user avatar ID provided when setting avatar: %s', $avatar_id );
      push( @json, { success => 0, message => '<strong>Wha?</strong><br>Invalid User Avatar ID' } );
      return to_json( \@json );
    }
    $avatar_id =~ s/^u-//;
    $user->avatar_type( 'Image' );
    $user->avatar_id( $avatar_id );
    $user->update;
  }

  push(@json, { success => 1,
                message => sprintf('Your avatar has been updated and set to "%s"!', $avatar_type),
                uri     => $user->avatar,
  });

  return to_json( \@json );
};


=head3 POST C</user/avatar/upload>

Route to upload an avatar file.

=cut

post '/user/avatar/upload' => require_login sub
{
  my $filedata = request->upload( 'filename' );
  my $title    = body_parameters->get( 'title' ) // undef;
  my $user     = vars->{user};

  my @json = ();

  my $gallery_path = $user->dirpath();

  if ( ! defined $gallery_path or $gallery_path eq '' )
  {
    push( @json, { success => 0, message => 'Could not upload avatar. Invalid or missing gallery path.' } );
    return to_json( \@json );
  }

  if ( ! -d $GALLERIES_FILEROOT . $gallery_path )
  {
    push( @json, { success => 0, message => 'Could not locate or create your gallery folder. Please try again.' } );
    return to_json( \@json );
  }

  my $avatar_path  = $gallery_path . '/avatars';

  if ( ! Side7::Util::File::path_exists( $GALLERIES_FILEROOT . $avatar_path ) )
  {
    my $created = Side7::Util::File::create_path( $GALLERIES_FILEROOT . $avatar_path );
    if ( $created->{'success'} < 1 )
    {
      warning sprintf( 'Could not create user avatar path: %s: %s',
                        $avatar_path, $created->{'message'} );
      push( @json, { success => 0, message => '<strong>Well, <em>that</em> went well.</strong><br>Could not create or find avatar path.' } );
      return to_json( \@json );
    }
  }

  my ( $name, $fpath, $ext ) = fileparse( $filedata->basename, '\.[^\.]*' );
  my $sha256 = Digest::SHA->new( 256 );
  $sha256->add( $filedata->basename . $user->username . DateTime->now( time_zone => 'UTC' )->datetime );
  my $newfilename = $sha256->hexdigest . $ext;

  my $upload_path = path( $GALLERIES_FILEROOT, $avatar_path, $newfilename );
  $filedata->link_to( $upload_path );

  if ( ! -e $upload_path )
  {
    warning sprintf( 'Could not save uploaded avatar for user >%s<: %s',
                      $user->username, $upload_path );
    push( @json, { success => 0, message => '<strong>Where did it go?</strong><br>Received your file, but coud not save it to your gallery. Please try again later.' } );
    return to_json( \@json );
  }

  # Generate thumbnail
  my $thumbnails_path = $avatar_path . '/thumbnails';

  if ( ! Side7::Util::File::path_exists( $GALLERIES_FILEROOT . $thumbnails_path ) )
  {
    my $created = Side7::Util::File::create_path( $GALLERIES_FILEROOT . $thumbnails_path );
    if ( $created->{'success'} < 1 )
    {
      warning sprintf( 'Could not create user avatar thumbnail path: %s: %s',
                        $thumbnails_path, $created->{'message'} );
      push( @json, { success => 0, message => '<strong>Well, <em>that</em> went well.</strong><br>Could not create or find avatar thumbnail path.' } );
      return to_json( \@json );
    }
  }

  my $new_thumb_path = path( $GALLERIES_FILEROOT, $thumbnails_path, $newfilename );
  my $generated = Side7::Util::Image::create_thumbnail(
    source    => $upload_path,
    thumbnail => $new_thumb_path,
  );

  # Crop avatar to a square shape.
  my $cropped = Side7::Util::Image::crop_image(
    source => $upload_path,
  );

  my $now = DateTime->now( time_zone => 'UTC' )->datetime;

  my $new_avatar = $user->add_to_avatars(
    {
      filename   => $newfilename,
      title      => $title,
      created_at => $now,
      updated_at => $now,
    }
  );

  my $logged = Side7::Log->user_log
  (
    user        => sprintf( '%s (ID:%s)', $user->username, logged_in_user->id ),
    ip_address  => ( request->header('X-Forwarded-For') // 'Unknown' ),
    log_level   => 'Info',
    log_message => sprintf( 'New avatar added. <a href="%s" target="_blank">&gt;%s&lt;</a>',
                            $avatar_path . '/' . $newfilename, $upload_path ),
  );

  push( @json, { success => 1, message => 'Avatar uploaded!' } );
  return to_json( \@json );
};


=head3 GET C</user/avatars/refresh>

Route to refresh user avatars.

=cut

get '/user/avatars/refresh' => require_login sub
{
  my $user           = vars->{user};
  my @user_avatars   = $user->search_related( 'avatars' )->search( {} )->all;

  template 'partials/_user_avatar_chooser.tt',
  {
    data =>
    {
      user           => $user,
      user_avatars   => \@user_avatars,
    },
  },
  {
    layout => undef,
  };
};


=head3 GET C</user/avatars/delete>

Route to delete selected user avatars.

=cut

post '/user/avatars/delete' => require_login sub
{
  my $user              = vars->{user};
  my $avatars_to_delete = params( 'body' ) // {};

  #debug( 'AVATARS_TO_DELETE LOOKS LIKE THIS: ' . Data::Dumper::Dumper( $avatars_to_delete ) );

  my @json = ();

  if ( scalar( keys %{$avatars_to_delete} ) < 1 )
  {
    push( @json, { success => 0, message => '<strong>Tryin\' to pull a fast one, eh?</strong><br>You need to select which avatars to delete.' } );
    return to_json( \@json );
  }

  # If there is only one element being sent via ajax, then it sends as a string,
  # otherwise, it sends as an array, so we force the string into a one-element array.
  my @delete_these = ( ref( $avatars_to_delete->{'to_delete[]'} ) eq 'ARRAY' )
                      ? @{$avatars_to_delete->{'to_delete[]'}}
                      : [ $avatars_to_delete->{'to_delete[]'} ];

  my @messages = ();

  foreach my $delete_id ( @delete_these )
  {
    #debug ('FINDING AVATAR ID ' . $delete_id);
    my $avatar = $user->search_related( 'avatars', { id => $delete_id } )->single;

    if ( ! defined $avatar )
    {
      push( @messages, sprintf('Could not find avatar ID %d. Maybe it is not yours?', $delete_id) );
    }
    else
    {
      # Remove file.
      my $filepath = $GALLERIES_FILEROOT . $user->dirpath . '/avatars/' . $avatar->filename;
      
      if ( -e $filepath )
      {
        unlink( $filepath );
      }
      my $thumbpath = $GALLERIES_FILEROOT . $user->dirpath . '/avatars/thumbnails/' . $avatar->filename;
      
      if ( -e $thumbpath )
      {
        unlink( $thumbpath );
      }
      # Remove record.
      my $title = ( $avatar->title ne '' ) ? $avatar->title : $avatar->id;

      $avatar->delete();

      push( @messages, sprintf( 'Removed avatar %s.', $title ) );
    }
  }

  push @json, { success => 1, message => join( '<br>', @messages ) };

  return to_json( \@json );
};


=head3 GET C</user/mail_folder/:folder/:filtered>

Route to retrieve a mail messages from a folder.

=cut

ajax '/user/mail_folder/:folder/?:filtered?' => require_login sub
{
  my $folder   = route_parameters->get( 'folder' )   // 'Inbox';
  my $filtered = route_parameters->get( 'filtered' ) // 0;
  my $user     = vars->{user};

  debug sprintf( 'Folder: >%s< / Filtered: >%s<', $folder, $filtered );

  my @all_mail     = ();
  my $mail_count   = 0;
  my $unread_count = 0;

  my %filter_search = ();
  if ( $filtered == 1 )
  {
    %filter_search = ( sender_id => { '!=' => 0 } );
  }

  my $mail_rs = '';
  if ( lc( $folder ) eq 'trash' )
  {
    $mail_rs = $SCHEMA->resultset( 'UserMail' )->search(
      {
        -and =>
        [
          is_deleted => 1,
          %filter_search,
          -or =>
          [
            {recipient_id => $user->id}, {sender_id => $user->id}
          ],
        ],
      },
      { order_by => { -desc => 'timestamp' } }
    );

  }
  elsif ( lc( $folder ) eq 'sent' )
  {
    $mail_rs = $user->sent_mail( { is_deleted => 0, %filter_search }, { order_by => { -desc => 'timestamp' } } );
  }
  else
  {
    $mail_rs = $user->received_mail( { is_deleted => 0, %filter_search }, { order_by => { -desc => 'timestamp' } } );
  }
  $mail_count   = $mail_rs->count();
  $unread_count = $mail_rs->search( { is_read => 0 } )->count();
  @all_mail     = $mail_rs->all();

  debug sprintf( 'Mail Count: %s / Unread Count: %s', ($mail_count // 0), ($unread_count // 0) );

  my @json = ();

  my $output = template 'partials/_user_mail_list_table.tt',
  {
    data =>
    {
      all_mail     => \@all_mail,
      folder       => $folder,
    },
  },
  {
    layout => '',
  };

  push( @json,
    {
      success      => 1,
      mail_list    => $output,
      mail_count   => $mail_count,
      unread_count => $unread_count,
    }
  );
  return to_json( \@json );
};


=head3 GET C</user/mail/:mail_id/:folder>

Route to retrieve a specific message, its details, and return it templetized.

=cut

ajax '/user/mail/:mail_id/:folder' => require_login sub
{
  my $mail_id = route_parameters->get( 'mail_id' );
  my $folder  = route_parameters->get( 'folder' ) // 'Inbox';

  my @json = ();

  if ( ! $mail_id or $mail_id =~ m/\D/ )
  {
    warn( sprintf( 'Invalid or bad mail_id in /user/mail/:mail_id/:folder : %s', $mail_id ) );
    push( @json,
      {
        message => 'Could not find the mail message you were requesting.',
        success => 0,
      }
    );
    return to_json( \@json );
  }

  my $related = 'received_mail';
  my $deleted = 0;
  if ( $folder eq 'Sent'  ) { $related = 'sent_mail'; }
  if ( $folder eq 'Trash' ) { $deleted = 1; }

  my $user    = vars->{user};
  my $message = $user->search_related( $related, { id => $mail_id } )->single;

  my $increment = 0;
  if ( $message->is_read == 0 ) { $increment = 1; }

  if
  (
    ( ( lc($folder) eq 'inbox' or lc($folder) eq 'trash' ) and $message->recipient_id != $user->id )
    or
    ( lc($folder) eq 'sent' and $message->sender_id != $user->id )
  )
  {
    warn( sprintf( 'User %s attempted to access mail not associated to their account: ID:%s', $user->username, $message->id ) );
    push( @json,
      {
        message => 'Could not find the mail message you were requesting.',
        success => 0,
      }
    );
    return to_json( \@json );
  }

  my $next_msg = $user->search_related( $related,
      { id => { '>' => $mail_id }, is_deleted => $deleted },
      { order_by => 'id', rows => 1 } )->single;
  my $prev_msg = $user->search_related( $related,
      { id => { '<' => $mail_id }, is_deleted => $deleted },
      { order_by => { -desc => 'id' }, rows => 1 } )->single;

  my $output = template 'user_mail_body',
  {
    data =>
    {
      message      => $message,
      next_message => $next_msg,
      prev_message => $prev_msg,
      folder       => $folder,
    },
  },
  { layout => '' };

  $message->is_read( 1 );
  $message->update;

  push( @json,
    {
      success   => 1,
      content   => $output,
      increment => $increment,
    }
  );
  return to_json( \@json );
};


=head3 GET C</user/newmail/?:mail_id?>

Route to fetch and display the compose mail function, with our without reply quote.

=cut

ajax '/user/newmail/?:mail_id?' => require_login sub
{
  my $mail_id = route_parameters->get( 'mail_id' ) // undef;

  my $user    = vars->{user};

  my $mail = $SCHEMA->resultset( 'UserMail' )->find( $mail_id ) if defined $mail_id and $mail_id =~ /^\d+$/;

  if ( defined $mail and ref( $mail ) eq 'Side7::Schema::Result::UserMail' )
  {
    if ( $mail->recipient_id ne logged_in_user->id )
    {
      warn( sprintf( 'User %s attempted to quote and reply to mail not associated to their account: ID:%s', $user->username, $mail->id ) );
      $mail = undef;
    }
  }

  my @json = ();

  my $output = template 'partials/_user_mail_compose_form.tt',
  {
    data =>
    {
      user          => $user,
      reply_to_mail => $mail,
    },
  },
  {
    layout => '',
  };

  push( @json,
    {
      success => 1,
      content => $output,
    }
  );
  return to_json( \@json );
};


=head3 AJAX C</user/mail/send>

Route for sending a mail message from one user to another.

=cut

ajax '/user/mail/send' => require_login sub
{
  my $recipient_un = query_parameters->get( 'recipient' );
  my $subject      = query_parameters->get( 'subject' );
  my $body         = query_parameters->get( 'body' );

  my @json = ();

  if ( ! defined $recipient_un or $recipient_un eq '' )
  {
    error sprintf( 'Could not send user message. Invalid or undefined recipient: %s', $recipient_un );
    @json = (
      {
        success => 0,
        message => '<strong>I am not a mind reader.</strong><br>Your message could not be sent because you didn\'t tell me who to send it to.',
      }
    );
    return to_json( \@json );
  }

  if ( ! defined $subject or $subject eq '' )
  {
    error sprintf( 'Could not send user message. Invalid or undefined subject %s', $subject );
    @json = (
      {
        success => 0,
        message => '<strong>You seem confused.</strong><br>Your message could not be sent because you didn\'t define a subject.',
      }
    );
    return to_json( \@json );
  }

  if ( ! defined $body or $body eq '' )
  {
    error sprintf( 'Could not send user message. Invalid body %s', $body );
    @json = (
      {
        success => 0,
        message => '<strong>Shall I make the message up?</strong><br>Sorry, but your message could not be sent as you have not written a message.',
      }
    );
    return to_json( \@json );
  }

  my $user = vars->{user};
  my $recipient = $SCHEMA->resultset( 'User' )->search( { username => $recipient_un } )->single;

  if ( ! defined $recipient or ref( $recipient ) ne 'Side7::Schema::Result::User' )
  {
    error sprintf( 'Could not send user message. Invalid recipient: %s', $recipient_un );
    @json = (
      {
        success => 0,
        message => 'Sorry, but your message could not be sent as we could not find the recipient you indicated.',
      }
    );
    return to_json( \@json );
  }

  my $now = DateTime->now( time_zone => 'UTC' )->datetime;

  my $sent = $user->create_related( 'sent_mail',
    {
      sender_id    => $user->id,
      recipient_id => $recipient->id,
      subject      => $subject,
      body         => $body,
      timestamp    => $now,
    }
  );

  @json = (
    {
      success => 1,
      content => sprintf( '<div class="text-center"><h3>Your message has been sent to %s!</h3> Hope they respond soon!</div>', $recipient->username ),
    }
  );
  return to_json( \@json );
};


=head3 AJAX C</user/mail/delete>

Route to delete one or more user mail messages.

=cut

ajax '/user/mail/delete' => require_login sub
{
  my @delete_ids = split( ',', query_parameters->get( 'delete_ids' ) );

  my $total_deletions = 0;

  my $user = vars->{user};

  my @emails = $user->search_related( 'received_mail', { id => { '-in' => \@delete_ids }, is_deleted => 0 } );
  foreach my $email ( @emails )
  {
    $email->is_deleted( 1 );
    $email->update;
    $total_deletions++;
  }

  undef @emails;
  @emails = $user->search_related( 'sent_mail', { id => { '-in' => \@delete_ids }, is_deleted => 0 } );
  foreach my $email ( @emails )
  {
    $email->is_deleted( 1 );
    $email->update;
    $total_deletions++;
  }

  my @json = ();
  if ( $total_deletions > 0 )
  {
    @json = (
      {
        success => 1,
        message => sprintf( '<strong>Dust in the wind.</strong><br>Successfully deleted %d messages.', $total_deletions ),
      }
    );
  }
  else
  {
    @json = (
      {
        success => 0,
        message => '<strong>Uh oh.</strong><br>For some reason, nothing was deleted. If that was expected, ignore this.',
      }
    );
  }
  return to_json( \@json );
};


=head3 AJAX C</user/settings/filter/categories>

Route to fetch the category filter settings page.

=cut

get '/user/settings/filter/categories' => require_login sub
{
  my $user = vars->{user};
  my $settings = $user->search_related( 'settings' )->single;

  my %filtered_categories = ();
  %filtered_categories = map { $_ => 1 } split( /,/, $settings->filter_categories ) if defined $settings;

  my @categories = $SCHEMA->resultset( 'UploadCategory' )->search( {}, { order_by => [ 'upload_type_id', 'sort_order' ] })->all;

  template 'user_settings_filter_categories',
  {
    data =>
    {
      filtered_categories => \%filtered_categories,
      categories          => \@categories,
    },
  },
  {
    layout => 'ajax-modal'
  };
};


=head3 AJAX C</user/settings/filter/ratings>

Route to fetch the ratings filter settings page.

=cut

get '/user/settings/filter/ratings' => require_login sub
{
  my $user = vars->{user};
  my $settings = $user->search_related( 'settings' )->single;

  my %filtered_ratings = ();
  %filtered_ratings = map { $_ => 1 } split( /,/, $settings->filter_ratings ) if defined $settings;

  my @ratings = $SCHEMA->resultset( 'UploadRating' )->search( {}, { order_by => [ 'upload_type_id', 'sort_order' ] })->all;

  template 'user_settings_filter_ratings',
  {
    data =>
    {
      filtered_ratings => \%filtered_ratings,
      ratings          => \@ratings,
    },
  },
  {
    layout => 'ajax-modal'
  };
};


=head3 AJAX C</user/settings/update>

Route to set the user settings.

=cut

post '/user/settings/update' => require_login sub
{
  my $user = vars->{user};
  my $settings = $user->search_related( 'settings' )->single;

  my %form_data = params('body');
  my $today = DateTime->now;

  my @settings_fields = (
    qw/
       show_online_status allow_museum_adds allow_friend_requests allow_user_contact
       allow_add_to_favorites show_social_links show_m_thumbnails show_adult_content
       email_notifications notify_on_pm notify_on_comment notify_on_friend_request
       notify_on_mention notify_on_favorite notify_on_museum_add
     /
  );

  my @json = ();

  if ( defined $settings )
  {
    foreach my $key ( @settings_fields )
    {
      if ( defined $form_data{$key} )
      {
        $settings->$key( ($form_data{$key} eq 'on') ? 1 : 0 );
      }
      else
      {
        $settings->$key( 0 );
      }
    }
    $settings->updated_on( $today->datetime );
    $settings->update;
  }
  else
  {
    my %new_settings = map {
      $_ => ( (defined $form_data{$_}) 
            ? ( ( $form_data{$_} eq 'on' ) ? 1 : 0 )
            : 0 )
    } @settings_fields;
    $user->create_related( 'settings', ( %new_settings, { updated_on => $today->datetime, }, ) );
  }

  push (@json, { success => 1, message => 'Your settings have been updated.' } );

  return to_json( \@json );
};


=head3 AJAX C</user/settings/filter/categories/update>

Route to set the category filter settings.

=cut

post '/user/settings/filter/categories/update' => require_login sub
{
  my $user = vars->{user};
  my $settings = $user->search_related( 'settings' )->single;
  my $raw_filters = param( 'filter' ) // undef;
  my $today = DateTime->now;

  my @json = ();

  # If raw_filters is empty, clear the value from filter_categories.
  if ( !defined $raw_filters or scalar( @{$raw_filters} ) < 1 )
  {
    if ( defined $settings )
    {
      $settings->filter_categories( '' );
      $settings->updated_on( $today->datetime );
      $settings->update;
    }
    else
    {
      my $user->add_to_settings( { filter_categories => '', updated_on => $today->datetime } );
    }
    push (@json, { success => 1, message => 'Your filters have been cleared.' } );
  }
  # Else, stringify the values of raw_filters, and set filter_categories to a comma-separated list.
  else
  {
    if ( defined $settings )
    {
      $settings->filter_categories( join( ',', @{$raw_filters} ) );
      $settings->updated_on( $today->datetime );
      $settings->update;
    }
    else
    {
      my $user->add_to_settings( { filter_categories => join( ',', @{$raw_filters} ), updated_on => $today->datetime } );
    }
    push (@json, { success => 1, message => 'Your filters have been updated.' } );
  }

  return to_json( \@json );
};


=head3 AJAX C</user/settings/filter/ratings/update>

Route to set the rating filter settings.

=cut

post '/user/settings/filter/ratings/update' => require_login sub
{
  my $user = vars->{user};
  my $settings = $user->search_related( 'settings' )->single;
  my $raw_filters = param( 'filter' ) // undef;
  my $today = DateTime->now;

  my @json = ();

  # If raw_filters is empty, clear the value from filter_categories.
  if ( !defined $raw_filters or scalar( @{$raw_filters} ) < 1 )
  {
    if ( defined $settings )
    {
      $settings->filter_ratings( '' );
      $settings->updated_on( $today->datetime );
      $settings->update;
    }
    else
    {
      my $user->add_to_settings( { filter_ratings => '' }, updated_on => $today->datetime );
    }
    push (@json, { success => 1, message => 'Your filters have been cleared.' } );
  }
  # Else, stringify the values of raw_filters, and set filter_categories to a comma-separated list.
  else
  {
    if ( defined $settings )
    {
      $settings->filter_ratings( join( ',', @{$raw_filters} ) );
      $settings->updated_on( $today->datetime );
      $settings->update;
    }
    else
    {
      my $user->add_to_settings( { filter_ratings => join( ',', @{$raw_filters} ), updated_on => $today->datetime } );
    }
    push (@json, { success => 1, message => 'Your filters have been updated.' } );
  }

  return to_json( \@json );
};


=head3 AJAX C</content/:content_id/comment/create/?:thread_id?>

Route to save a new comment, whether it's a new thread or a reply to an existing one.

=cut

ajax '/content/:content_id/comment/create/?:thread_id?' => require_login sub
{
  my $content_id = route_parameters->get( 'content_id' );

  my $thread_id = body_parameters->get( 'thread_id' ) // undef;
  my $comment   = body_parameters->get( 'comment' )   // undef;
  my $rating    = body_parameters->get( 'rating')     // 0;
  my $private   = body_parameters->get( 'private')    // 0;

  my @json = ();

  if ( ! defined logged_in_user )
  {
    push @json, { success => 0, message => '<strong>Who are you?</strong><br>You need to be logged in to leave a comment.' };
    warning sprintf( 'Attempt to post a comment without being logged in: Request: >%s< / Comment: >%s<', Data::Dumper::Dumper( request ), Data::Dumper::Dumper( query_parameters ) );
    return to_json( \@json );
  }

  if ( ! defined $comment or $comment eq '' )
  {
    push @json, { success => 0, message => '<strong>Do you think I\'m a mind reader?</strong><br>What do you want me to post as your comment?' };
    return to_json( \@json );
  }

  if ( ! defined $content_id or $content_id !~ /^\d+$/ )
  {
    push @json, { success => 0, message => '<strong>Say what?</strong><br>We could not save your comment as an error occurred. Please try again later.' };
    warning sprintf( 'Invalid or undefined content_id provided when attempting to save a new comment: >%s<', $content_id );
    return to_json( \@json );
  }

  my $user    = vars->{user};
  my $content = $SCHEMA->resultset( 'UserUpload' )->find( $content_id );

  if ( ! defined $content or ref( $content ) ne 'Side7::Schema::Result::UserUpload' )
  {
    push @json, { success => 0, message => '<strong>Say what?</strong><br>We could not save your comment as an error occurred. Please try again later.' };
    warning sprintf( 'Invalid or undefined content returned from content_id when attempting to save a new comment: >%s<', $content_id );
    return to_json( \@json );
  }

  my $now = DateTime->now( time_zone => 'UTC' )->datetime;

  my $thread = '';
  # If no thread_id is passed in, we need to create a new thread.
  if ( defined $thread_id and $thread_id =~ /^\d+$/ )
  {
    $thread = $content->find_related( 'comment_threads', { id => $thread_id } );
  }
  else
  {
    $thread = $content->create_related( 'comment_threads',
      {
        creator_id => logged_in_user->id,
        created_on => $now
      }
    );
  }

  if ( ! defined $thread or ref( $thread ) ne 'Side7::Schema::Result::UploadCommentThread' )
  {
    push @json, { success => 0, message => '<strong>Say what?</strong><br>We could not save your comment as an error occurred. Please try again later.' };
    warning sprintf( 'Invalid or undefined thread returned from thread_id or new thread creationg when attempting to save a new comment: >%s<', $thread_id );
    return to_json( \@json );
  }

  # Create comment, linked to the new thread or the reply_to thread.
  my $new_comment = $thread->create_related( 'comments',
    {
      user_id    => logged_in_user->id,
      username   => logged_in_user->username,
      comment    => $comment,
      private    => $private,
      rating     => $rating,
      ip_address => ( request->host // 'Unknown' ),
      timestamp  => $now
    }
  );

  my $output = template 'partials/_comment_block.tt',
  {
    data =>
    {
      upload => $content
    },
    item => $new_comment,
    no_jquery => 1,
  },
  {
    layout => undef
  };

  push @json, {
    success    => 1,
    message    => '<strong>Comment Posted!</strong><br>Your comment has been successfully posted.',
    content    => $output,
    thread_id  => $thread->id,
    comment_id => $new_comment->id,
  };
  return to_json( \@json );
};


=head3 AJAX C</content/:content_id/comment/:comment_id/delete>

Route to delete a comment from a User Upload.

=cut

ajax '/content/:content_id/comment/:comment_id/delete' => require_login sub
{
  my $content_id = route_parameters->get( 'content_id' );
  my $comment_id = route_parameters->get( 'comment_id' );

  my $user = vars->{user};

  my @json = ();

  if ( ! defined $user or ref( $user ) ne 'Side7::Schema::Result::User' )
  {
    push @json, { success => 0, message => '<strong>Who are you?</strong><br>You need to be logged in to delete a comment.' };
    warning sprintf( 'Attempt to delete a comment without being logged in: Request: >%s< / Comment: >%s<', Data::Dumper::Dumper( request ), Data::Dumper::Dumper( route_parameters ) );
    return to_json( \@json );
  }

  my $upload = $user->find_related( 'uploads', { id => $content_id } );

  if ( ! defined $upload or ref( $upload ) ne 'Side7::Schema::Result::UserUpload' )
  {
    push @json, { success => 0, message => '<strong>Not Your Content</strong><br>The comment you are attempting to delete is not on one of your items. You do not have permission to do so.' };
    warning sprintf( 'Attempt to delete a comment on someone else\'s content: User: >%s< / Comment: >%s< / Content: >%s<', logged_in_user->username . '(' . logged_in_user->id . ')', $comment_id, $content_id );
    return to_json( \@json );
  }

  my $comment = $SCHEMA->resultset( 'UploadComment' )->search(
    { 'me.id' => $comment_id },
    {
      prefetch => { 'thread' => 'upload' },
    }
  )->single;

  if ( ! defined $comment or ref( $comment ) ne 'Side7::Schema::Result::UploadComment' )
  {
    push @json, { success => 0, message => '<strong>Where did it go?</strong><br>The comment you are attempting to delete could not be found.' };
    warning sprintf( 'Invalid comment retrieved when attempting to delete comment: User: >%s< / Comment: >%s< / Content: >%s<', logged_in_user->username . '(' . logged_in_user->id . ')', $comment_id, $content_id );
    return to_json( \@json );
  }

  if ( $comment->thread->upload->id != $content_id )
  {
    push @json, { success => 0, message => '<strong>Trying to pull a fast one?</strong><br>The comment you are attempting to delete does not belong to the indicated content.' };
    warning sprintf( 'Comment not associated to indicated content when attempting to delete comment: User: >%s< / Comment: >%s< / Content: >%s<', logged_in_user->username . '(' . logged_in_user->id . ')', $comment_id, $content_id );
    return to_json( \@json );
  }

  my $thread_id = $comment->thread->id;
  my $thread    = $comment->find_related( 'thread', { id => $thread_id } );

  # Delete comment.
  $comment->delete();

  # Was this comment the only one in the thread? If so, delete the thread also.
  if ( $thread->search_related( 'comments', {} )->count < 1 )
  {
    $thread->delete();
  }

  # Return Success.
  push @json,
  {
    success => 1,
    message => '<strong>And like that... it\'s gone.</strong><br>The comment has been deleted.'
  };
  return to_json( \@json );
};


=head3 AJAX C</comment/toggle_privacy/:comment_id/:mode>

Route to toggle the privacy/visibility of a comment on user content.

=cut

ajax '/comment/toggle_privacy/:comment_id/:mode' => require_login sub
{
  my $comment_id = route_parameters->get( 'comment_id' );
  my $mode       = route_parameters->get( 'mode' );

  my $user = vars->{user};

  my @json = ();

  if ( ! defined $user or ref( $user ) ne 'Side7::Schema::Result::User' )
  {
    push @json, { success => 0, message => '<strong>Who are you?</strong><br>You need to be logged in to delete a comment.' };
    warning sprintf( 'Attempt to delete a comment without being logged in: Request: >%s< / Comment: >%s<', Data::Dumper::Dumper( request ), Data::Dumper::Dumper( route_parameters ) );
    return to_json( \@json );
  }

  my $comment = $SCHEMA->resultset( 'UploadComment' )->search(
    { 'me.id' => $comment_id },
    {
      prefetch => { 'thread' => 'upload' },
    }
  )->single;

  if ( ! defined $comment or ref( $comment ) ne 'Side7::Schema::Result::UploadComment' )
  {
    push @json, { success => 0, message => '<strong>Where did it go?</strong><br>The comment you are attempting to update could not be found.' };
    warning sprintf( 'Invalid comment retrieved when attempting to change the visibility of the comment: User: >%s< / Comment: >%s< ', logged_in_user->username . '(' . logged_in_user->id . ')', $comment_id );
    return to_json( \@json );
  }

  my $upload = $SCHEMA->resultset( 'UserUpload' )->find( $comment->thread->upload->id );

  if ( ! defined $upload or ref( $upload ) ne 'Side7::Schema::Result::UserUpload' )
  {
    push @json, { success => 0, message => '<strong>Where did it go?</strong><br>The comment you are attempting to update could not be found.' };
    warning sprintf( 'Invalid comment retrieved when attempting to change the visibility of the comment: User: >%s< / Comment: >%s< ', logged_in_user->username . '(' . logged_in_user->id . ')', $comment_id );
    return to_json( \@json );
  }

  if ( $upload->user->id != logged_in_user->id )
  {
    push @json, { success => 0, message => '<strong>Not Your Content</strong><br>The comment you are attempting to delete is not on one of your items. You do not have permission to do so.' };
    warning sprintf( 'Attempt to delete a comment on someone else\'s content: User: >%s< / Comment: >%s<', logged_in_user->username . '(' . logged_in_user->id . ')', $comment_id );
    return to_json( \@json );
  }

  $comment->private( $mode );
  $comment->update;

  push @json,
  {
    success => 1,
    message => '<strong>Alakazam!</strong><br>The comment\'s privacy setting has been updated.'
  };

  return to_json( \@json );
};


=head3 POST C</util/username_ac>

Route to fetch a suggestion list for auto-complete.

=cut

ajax '/util/username_ac' => require_login sub
{
  my $username = query_parameters->get( 'phrase' );
  return to_json( [] ) if ! defined $username;

  my @usernames = $SCHEMA->resultset( 'User' )->search(
    {
      username       => { like => '%' . $username . '%' },
      user_status_id => 2
    },
  );

  my @suggestions = ();
  if ( scalar( @usernames ) > 0 )
  {
    foreach my $record ( @usernames )
    {
      push @suggestions, { username => $record->username, full_name => $record->full_name };
    }
  }

  return to_json( \@suggestions );
};


################################################
# ADMIN ROUTES
################################################


=head2 Admin Routes


=head3 GET C</admin>

Route to load the admin dashboard.

=cut

get '/admin' => require_role Admin => sub
{
  my @storage_stats = `du -h -d1 /data/galleries | sort -h`;
  my @diskfree = `df -h`;

  my $stop = DateTime->today;
  my $start = $stop->clone();
  $start->subtract( days => 31 );

  my @new_user_dates = ();
  my @last_30_day_users = $SCHEMA->resultset( 'User' )->search(
    { created_at => { '-between' => [ $start->ymd, $stop->ymd ] } },
    {
      'columns' => [ 'me.created_at', { new_user_count => { count => 'me.id' } }],
      group_by  => [ 'me.created_at' ],
      rows => 30
    }
  );

  my $ustart = $start->clone();
  while ( $ustart->add( days => 1 ) < $stop )
  {
    my $found = 0;
    foreach my $date ( @last_30_day_users )
    {
      if ( $ustart->ymd('-') eq $date->created_at )
      {
        push @new_user_dates, { $ustart->strftime('%d %b') => $date->new_user_count };
        $found = 1;
        last;
      }
    }
    if ( $found == 0 )
    {
      push @new_user_dates, { $ustart->strftime('%d %b') => 0 };
    }
  }

  my @upload_dates = ();
  my @last_30_day_uploads = $SCHEMA->resultset( 'UserUpload' )->search(
    undef,
    {
      select =>
      [
        { date => 'me.uploaded_on', -as => 'upload_date' },
        { count => 'me.id', -as => 'upload_count' },
      ],
      where  =>
      [
        { 'DATE(me.uploaded_on)' => { '-between' => [ $start->ymd, $stop->ymd ] } },
      ],
      group_by   => [ 'DATE(me.uploaded_on)' ],
      rows => 30
    }
  );

  my $pstart = $start->clone();
  while ( $pstart->add( days => 1 ) < $stop )
  {
    my $found = 0;
    foreach my $date ( @last_30_day_uploads )
    {
      if ( $pstart->ymd('-') eq $date->upload_date )
      {
        push @upload_dates, { $pstart->strftime('%d %b') => $date->upload_count };
        $found = 1;
        last;
      }
    }
    if ( $found == 0 )
    {
      push @upload_dates, { $pstart->strftime('%d %b') => 0 };
    }
  }

  template 'admin_dashboard_home',
  {
    data =>
    {
      user           => vars->{user},
      new_user_dates => \@new_user_dates,
      upload_dates   => \@upload_dates,
      stats          => \@storage_stats,
      disk           => \@diskfree,
    },
  },
  {
    layout => 'admin'
  };
};


################################################
# ADDITIONAL METHODS
################################################


=head1 ADDITIONAL METHODS


=head3 get_full_user_dirpath()

Returns a string containing a complete user file path.

  my $user_filepath = get_full_user_dirpath( $user );

=cut

sub get_full_user_dirpath
{
  my ( $user ) = @_;

  if ( ! defined $user or ref( $user ) ne 'Side7::Schema::Result::User' )
  {
    error sprintf( 'Invalid User object passed to "get_full_user_dirpath". >%s<', $user );
    return;
  }

  return sprintf( '%s%s%s', path( app->location ), $GALLERIES_ROOT, $user->dirpath );
}


=head1 COPYRIGHT & LICENSE

Copyright 2017-2018 Side 7 L<http://www.side7.com>

All rights reserved.

=cut

true;
