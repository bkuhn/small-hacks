#!/usr/bin/perl

use strict;
use warnings;

use WWW::Mechanize;
use HTTP::Cookies;

my $mech = WWW::Mechanize->new(
     autocheck => 1,
     cookie_jar => HTTP::Cookies->new( file => "$ENV{HOME}/Crypt/Poker/dc-cookies.txt"));

$mech->get("http://www.deucescracked.com/dashboard");
print $mech->content;
