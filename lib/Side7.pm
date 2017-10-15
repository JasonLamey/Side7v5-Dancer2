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

our $VERSION = '5.0';

const my $DOMAIN_ROOT               => 'http://www.side7.com';
const my $SCHEMA                    => Side7::Schema->db_connect();
const my $USER_SESSION_EXPIRE_TIME  => 172800; # 48 hours in seconds.
const my $ADMIN_SESSION_EXPIRE_TIME => 600;    # 10 minutes in seconds.
const my $DPAE_REALM                => 'site'; # Dancer2::Plugin::Auth::Extensible realm


=head1 NAME

Side7


=head1 DESCRIPTION

Primary library and route handler for the Side 7 web app.


=head1 ROUTES


=head2 General Routes


=head3 GET C</boilerplate>

Route for styles boilerplate.

=cut

get '/boilerplate' => sub
{
  template 'boilerplate';
};


=head3 GET C</>

Route for index page.

=cut

get '/' => sub
{
  template 'index';
};


=head2 Routes Requiring User Login

=cut


=head2 Admin Routes

=cut


=head1 ADDITIONAL METHODS

=cut


=head1 COPYRIGHT & LICENSE

Copyright 2017 Side 7 L<http://www.side7.com>

All rights reserved.

=cut

true;
