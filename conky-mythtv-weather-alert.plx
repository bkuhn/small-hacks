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
use utf8;
use feature 'unicode_strings';
use Encode qw(encode decode);

my $now =  ParseDate("now");

my $MYTH_PATH = shift;
my($command) = $MYTH_PATH .
             "/mythplugins/mythweather/mythweather/scripts/us_nws/nws-alert.pl";
my %data;

foreach my $location (@ARGV) {
  open(DATA, "-|", $command, $location)
    or die "unable to run: $command $location: $!";

  while (my $line = <DATA>) {
    die "bad line output in data: $line"
      unless $line =~ /^\s*(\S+)\s*:\s*:\s*(.+)$/;
    $data{$location}{$1} = $2;
  }
  close DATA;
  die "error($?) running: $command $location: $!" unless $? == 0;
}
my $warned = 0;
foreach my $location (keys %data) {
  die "Missing $location!" if (not defined $data{$location}{alerts});
  next if $data{$location}{alerts} =~ /no\s*warning/i;
  print "\${color5}\${font :size=20}WEATHER ALERT:\n";
  my $datetime = ParseDate($data{$location}{updatetime});
  my $ago = Delta_Format(DateCalc($datetime, $now), 0, "%mt min");
  $ago = Delta_Format(DateCalc($datetime, $now), 0, "%st sec")
    if ($ago =~ /0 minutes/);
  print "\${font}As of $ago ago:\n$data{$location}{alerts}\n";
}

###############################################################################
#
# Local variables:
# compile-command: "perl -c conky-mythtv-weather-alert.plx"
# End:

