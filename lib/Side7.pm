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

# Side 7 modules
use Side7::Schema;
use Side7::Util;
use Side7::Mail;
use Side7::Log;
use Side7::Crypt;

our $VERSION = '5.0';

const my $DOMAIN_ROOT               => 'http://www.side7.com';
const my $SCHEMA                    => Side7::Schema->db_connect();
const my $USER_SESSION_EXPIRE_TIME  => 172800; # 48 hours in seconds.
const my $ADMIN_SESSION_EXPIRE_TIME => 600;    # 10 minutes in seconds.
const my $DPAE_REALM                => 'site'; # Dancer2::Plugin::Auth::Extensible realm

$SCHEMA->storage->debug(1); # Turns on DB debuging. Turn off for production.


=head1 NAME

Side7


=head1 DESCRIPTION

Primary library and route handler for the Side 7 web app.


=head1 HOOKS


=head2 before_template_render

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
};


=head2 after_authenticate_user

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

  template 'index',
  {
    data =>
    {
      announcements => \@announcements,
      news          => \@news,
      recents       => \@recents,
      stats         => \%stats,
    }
  };
};


=head2 GET C</news/:page>

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
    },
    title => 'News',
    breadcrumbs =>
    [
      { name => 'News', current => 1 },
    ],
  };
};


=head2 GET C</news/item/:news_id>

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
    },
    title => $news->title,
    breadcrumbs =>
    [
      { name => 'News', link => '/news' },
      { name => $news->title, current => 1 },
    ],
  };

};


=head2 GET C</faq>

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
    },
    title => 'Frequently Asked Questions',
    breadcrumbs =>
    [
      { name => 'FAQ', current => 1 },
    ]
  }
};


=head2 GET C</faq/:category_id>

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
    },
    title => sprintf( 'FAQ | %s', $category->category ),
    breadcrumbs =>
    [
      { name => 'FAQ', link => '/faq' },
      { name => $category->category, current => 1 },
    ]
  }

};


=head2 GET C</faq/:category_id/:entry_id>

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


=head2 GET C</upload-tooltip/:upload_id>

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


=head2 GET C</reset_password>

Route to reset a user's password.

=cut

get '/reset_password' => sub
{
  template 'reset_password_form', { title => 'Reset Password' };
};


=head2 POST C</reset_password>

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


=head2 GET C</reset_my_password/:code>

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


=head2 GET C</signup>

Route to the sign-up form.

=cut

get '/signup' => sub
{
  template 'signup', { title => 'Sign Up For An Account' };
};


=head2 POST C</signup>

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


=head2 GET C</signed_up>

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


=head2 GET C</resend_confirmation>

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


=head2 POST C</resend_confirmation>

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


=head2 GET C</login>

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


=head2 POST C</login>

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


=head2 ANY C</logout>

Logout route, for killing user sessions, and redirecting to the index page.

=cut

any '/logout' => sub
{
  app->destroy_session;
  flash( notify => 'You are logged out. Come back soon!' );
};


=head2 ANY C</login/denied>

User denied access route for authentication failures.

=cut

any '/login/denied' => sub
{
  template 'login_denied';
};


=head2 GET C</account_confirmation>

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


=head2 POST C</account_confirmation>

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


=head2 GET C</user>

GET route for User Dashboard

=cut

get '/user' => sub
{
  my $user = $SCHEMA->resultset( 'User' )->find( logged_in_user->id );

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


=head2 Admin Routes

=cut


=head1 ADDITIONAL METHODS

=cut


=head1 COPYRIGHT & LICENSE

Copyright 2017 Side 7 L<http://www.side7.com>

All rights reserved.

=cut

true;
