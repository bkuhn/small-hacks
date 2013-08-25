#!/usr/bin/perl
# conky-mythtv-weather-build.plx
#
# Copyright (C) 2013, Bradley M. Kuhn
#
# This program gives you software freedom; you can copy, modify, convey,
# and/or redistribute it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 3 of the
# License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with this program in a file called 'GPLv3'.  If not, write to the:
#    Free Software Foundation, Inc., 51 Franklin St, Fifth Floor
#                                    Boston, MA 02110-1301, USA.
#
# Quick hack to use mythtv scripts.

use strict;
use warnings;
use Date::Manip;

if (@ARGV != 3) {
  print STDERR "usage: $0 /path/to/mythtv/git/checkout <units> <location>\n";
  exit 1;
}
my($MYTH_PATH, $UNITS, $LOCATION) = @ARGV;

my($forecastCmd) = $MYTH_PATH .
                 "/mythplugins/mythweather/mythweather/scripts/us_nws/ndfd18.pl";

open(FORECAST, "-|", $forecastCmd, '-u', $UNITS, $LOCATION)
  or die "unable to run: $forecastCmd -u $UNITS $LOCATION: $!";

my %forecast;

while (my $line = <FORECAST>) {
  die "bad line output in forecast: $line"
    unless $line =~ /^\s*(\S+)\s*:\s*:\s*(.+)$/;
  $forecast{$1} = $2;
}
close FORECAST;
die "error($?) running: $forecastCmd -u $UNITS $LOCATION: $!" unless $? == 0;

$forecast{updatetime} =~ s/\s*Last\s+Updated\s+on\s*//;
my $now =  ParseDate("now");
my $x = Delta_Format(DateCalc(ParseDate($forecast{updatetime}), $now), 0,
                     "%mt minutes ago");

$forecast{updatetime} = $x if defined $x;
$forecast{updatetime} = "as of $forecast{updatetime}";
###############################################################################
#
# Local variables:
# compile-command: "perl -c conky-mythtv-weather-build.plx"
# End:

