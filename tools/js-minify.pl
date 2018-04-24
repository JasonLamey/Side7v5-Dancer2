#!/usr/bin/env perl

use strict;
use warnings;

use File::Slurp;
use IO::File;
use HTTP::Request::Common qw(POST);
use LWP::UserAgent;

my $js_file = $ARGV[0];
my $output  = $ARGV[1] // undef;

if ( ! defined $js_file or ! -e $js_file )
{
  die sprintf("EXITING: Invalid or missing .js file: '%s'\n\nUSAGE: js-minify.pl <.js file> <output file>\n", $js_file );
}

my $js = read_file( $js_file );

sub minify
{
    my $js = shift;

    my $js_min_url = "https://javascript-minifier.com/raw";

    my $ua = LWP::UserAgent->new;
    my $request = POST($js_min_url, [ 'input' => $js ]);
    my $js_min = $ua->request($request)->decoded_content();

    return $js_min;
}

if ( ! defined $output )
{
  print minify($js), "\n";
}
else
{
  my $fh = IO::File->new("> $output");
  if (defined $fh)
  {
    print $fh minify($js);
    $fh->close;
    print "Done\n";
  }
}

exit 0;
