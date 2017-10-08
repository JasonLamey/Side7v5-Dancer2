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

our $VERSION = '5.0';


=head1 NAME

Side7


=head1 DESCRIPTION

Primary library and route handler for the Side 7 web app.


=head1 ROUTES


=head2 General Routes

=cut

get '/' => sub {
    template 'index';
};


=head2 Routes Requiring User Login

=cut


=head2 Admin Routes

=cut


=head1 ADDITIONAL METHODS

=cut

true;
