#! /usr/bin/env perl

use strict;
use warnings;

my $hashref1 = { dog => 'bark', cat => 'meow' };
my $hashref2 = { bird => 'tweet', cow => 'moo' };

my $hashrefs = ();

foreach my $ref ( $hashref1, $hashref2 )
{
  foreach my $key ( keys %{ $ref } )
  {
    $hashrefs->{$key} = $ref->{$key};
  }
}

foreach my $key ( keys %{ $hashrefs } )
{
  printf ("The %s goes '%s'\n", $key, $hashrefs->{$key} );
}
