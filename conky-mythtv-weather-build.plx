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

my($mythIconPath) = $MYTH_PATH .  "/mythplugins/mythweather/theme/default/icons";
my(%commands) = ('forecast' => $MYTH_PATH .
                 "/mythplugins/mythweather/mythweather/scripts/us_nws/ndfd18.pl",
                 'extended' => $MYTH_PATH .
                 "/mythplugins/mythweather/mythweather/scripts/us_nws/ndfd.pl");

my %data;
foreach my $type (keys %commands) {
  open(DATA, "-|", $commands{$type}, '-u', $UNITS, $LOCATION)
    or die "unable to run: $commands{$type} -u $UNITS $LOCATION: $!";

  while (my $line = <DATA>) {
    die "bad line output in data: $line"
      unless $line =~ /^\s*(\S+)\s*:\s*:\s*(.+)$/;
    $data{$type}{$1} = $2;
  }
  close DATA;
  die "error($?) running: $commands{$type} -u $UNITS $LOCATION: $!"
    unless $? == 0;
}

$data{forecast}{updatetime} =~ s/\s*Last\s+Updated\s+on\s*//;
my $now =  ParseDate("now");
my $x = Delta_Format(DateCalc(ParseDate($data{forecast}{updatetime}), $now), 0,
                     "%mt minutes ago");

$data{forecast}{updatetime} = $x if defined $x;
$data{forecast}{updatetime} = "as of $data{forecast}{updatetime}";
my %doneDays;
foreach my $ii (qw/0 1 2 3 4 5/) {
  my $time = ParseDate($data{forecast}{"time-${ii}"});
  if (defined $time) {
    $time = DateCalc($time, "+ 1 day") if ($time lt $now);
    $data{forecast}{"time-${ii}"} = UnixDate($time, $HOUR_FORMAT);
    $doneDays{UnixDate($time, '%A')} = 'forecast';
  }
}
my($xpos, $vpos) = ($FONT_SIZE * (3 + length($data{forecast}{"time-0"})),
                    $VOFFSET_IMAGE + 37);
my $f = $FONT_SIZE + 5;
print '${voffset ', $VOFFSET_TEXT , '} ${font :size=', $f, '}${alignc}Weather:${font}', " $data{forecast}{'18hrlocation'}\n\n";
foreach my $ii (qw/0 1 2 3 4 5/) {
  my($time, $temp, $pop, $icon) =
    ($data{forecast}{"time-${ii}"}, $data{forecast}{"temp-${ii}"},
     $data{forecast}{"pop-${ii}"}, $data{forecast}{"18icon-${ii}"});
  $pop =~ s/\s+//g;
  $pop = "  $pop" if length($pop) eq 2;
  $pop = " $pop" if length($pop) eq 3;
  print "\${font :size=${FONT_SIZE}px} $time: $temp $degree \${image $mythIconPath/$icon -p $xpos,$vpos  -s 25x18}     $pop chance\n";
  $vpos += ($FONT_SIZE * 2) + 15;
}
($xpos, $vpos) = ($FONT_SIZE * 26,
                    $VOFFSET_IMAGE + 37 + 230);
foreach my $ii (qw/0 1 2 3 4 5/) {
  next if defined $doneDays{$data{extended}{"date-${ii}"}};
  my($day, $high, $low, $icon) =
    ($data{extended}{"date-${ii}"}, $data{extended}{"high-${ii}"},
     $data{extended}{"low-${ii}"}, $data{extended}{"icon-${ii}"});
  print "\n\${font :size=${FONT_SIZE}px} $day:\${goto 120}High: $high $degree   Low: $low $degree \${image $mythIconPath/$icon -p $xpos,$vpos  -s 25x18}\n";
  $vpos += ($FONT_SIZE * 2) + 15;
}

###############################################################################
#
# Local variables:
# compile-command: "perl -c conky-mythtv-weather-build.plx"
# End:
