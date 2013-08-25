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

if (@ARGV != 6 and @ARGV != 7) {
  print STDERR "usage: $0 /path/to/mythtv/git/checkout <units> <location> <text_voffset> <img_voffset> <fontsize_pixels> [hour-format]\n";
  exit 1;
}
my($MYTH_PATH, $UNITS, $LOCATION, $VOFFSET_TEXT, $VOFFSET_IMAGE, $FONT_SIZE, $HOUR_FORMAT) = @ARGV;
$HOUR_FORMAT = "%a %H:%M" unless defined $HOUR_FORMAT;
my $degree;
if ($UNITS eq "SI") {
  $degree = encode('utf8', "°C");
} elsif ($UNITS eq 'ENG') {
  $degree = encode('utf8', "°F");
} else {
  die "invalid units, $UNITS";
}
my($forecastCmd) = $MYTH_PATH .
                 "/mythplugins/mythweather/mythweather/scripts/us_nws/ndfd18.pl";
my($mythIconPath) = $MYTH_PATH .  "/mythplugins/mythweather/theme/default/icons";

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
foreach my $ii (qw/0 1 2 3 4 5/) {
  my $time = ParseDate($forecast{"time-${ii}"});
  if (defined $time) {
    $time = DateCalc($time, "+ 1 day") if ($time lt $now);
    $forecast{"time-${ii}"} = UnixDate($time, $HOUR_FORMAT);
  }
}
my($xpos, $vpos) = ($FONT_SIZE * (3 + length($forecast{"time-0"})),
                    $VOFFSET_IMAGE + 37);
my $f = $FONT_SIZE + 5;
print '${voffset ', $VOFFSET_TEXT , '} ${font :size=', $f, '}${alignc}Forecast:${font}', " $forecast{'18hrlocation'}\n\n";
foreach my $ii (qw/0 1 2 3 4 5/) {
  my($time, $temp, $pop, $icon) =
    ($forecast{"time-${ii}"}, $forecast{"temp-${ii}"},
     $forecast{"pop-${ii}"}, $forecast{"18icon-${ii}"});
  $pop =~ s/\s+//g;
  $pop = "  $pop" if length($pop) eq 2;
  $pop = " $pop" if length($pop) eq 3;
  print "\${font :size=${FONT_SIZE}px} $time: $temp $degree \${image $mythIconPath/$icon -p $xpos,$vpos  -s 25x18}     $pop chance\n\n";
  $vpos += ($FONT_SIZE * 2) + 15;
}

###############################################################################
#
# Local variables:
# compile-command: "perl -c conky-mythtv-weather-build.plx"
# End:

