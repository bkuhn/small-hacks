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

# Get listing of stations with:
# /home/bkuhn/hacks/mythtv/mythplugins/mythweather/mythweather/scripts/us_nws/nwsxml.pl  -l

use strict;
use warnings;
use Date::Manip;
use utf8;
use feature 'unicode_strings';
use Encode qw(encode decode);

use File::Temp qw/tempdir/;

chdir("$ENV{HOME}/tmp/.conky-mythtv-weather")
  or die "unable to go to $ENV{HOME}/tmp/.conky-mythtv-weather";

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
                 "/mythplugins/mythweather/mythweather/scripts/us_nws/ndfd.pl",
                 'current' => $MYTH_PATH .
                 "/mythplugins/mythweather/mythweather/scripts/us_nws/nwsxml.pl",
                'accuweather' => $MYTH_PATH .
                "/mythplugins/mythweather/mythweather/scripts/accuweather/accuweather.pl");

my %data;

my($location1) = $LOCATION;
my($location2) = $LOCATION;
if ($LOCATION =~ /^([^|]+)\|([^|]+)/) {
  ($location1, $location2) = ($1, $2);
}
if ($location1 eq "FORCE_ACCUWEATHER") {
  foreach my $key (qw/forecast extended current/) { delete $commands{$key}; }
}
foreach my $type (keys %commands) {
  my $location = $location1;
  $location = $location2 if $type eq "accuweather";
  open(DATA, "-|", $commands{$type}, '-u', $UNITS, $location)
    or die "unable to run: $commands{$type} -u $UNITS $LOCATION: $!";

  while (my $line = <DATA>) {
    die "bad line output in data: $line"
      unless $line =~ /^\s*(\S+)\s*:\s*:\s*(.*)$/;
    $data{$type}{$1} = $2;
  }
  close DATA;
  die "error($?) running: $commands{$type} -u $UNITS $LOCATION: $!"
    unless $? == 0;
}
if (not defined $data{current}{observation_time}) {
  foreach my $key (%{$data{accuweather}}) {
    $data{current}{$key} = $data{accuweather}{$key};
  }
}
if (not defined $data{forecast}{updatetime}
    and defined $data{accuweather}{'time-1'}) {
  foreach my $key (%{$data{accuweather}}) {
    $data{forecast}{$key} = $data{accuweather}{$key};
  }
}
if (not defined $data{extended}{updatetime}) {
  foreach my $key (%{$data{accuweather}}) {
    $data{extended}{$key} = $data{accuweather}{$key};
  }
}

$data{forecast}{updatetime} =~ s/\s*Last\s+Updated\s+(?:on|:)?\s*//
  if defined $data{forecast}{updatetime};
my $now =  ParseDate("now");
my $updateTime = ParseDate($data{forecast}{updatetime});
my $x = Delta_Format(DateCalc($updateTime, $now), 0, "%mt minutes ago");

$data{forecast}{updatetime} = $x if defined $x;
$data{forecast}{updatetime} = "as of $data{forecast}{updatetime}";
$data{forecast}{"maxLength"} = 0;
my %doneDays;
foreach my $ii (qw/0 1 2 3 4 5/) {
  next if not defined $data{forecast}{"time-${ii}"};
  my $time = ParseDate($data{forecast}{"time-${ii}"});
  next if not defined $time;
  if (defined $time) {
    $time = DateCalc($time, "+ 1 day") if ($time lt $updateTime);
    if ($time lt $now) {
      delete $data{forecast}{"time-${ii}"};
      next;
    }
    my $day = UnixDate($time, '%A');
    $data{forecast}{"time-${ii}"} = UnixDate($time, $HOUR_FORMAT);
    my $ll = length($data{forecast}{"time-${ii}"});
    $data{forecast}{"maxLength"} = $ll
      unless $data{forecast}{"maxLength"} > $ll;
    $doneDays{$day} = 'forecast';
  }
}
my $f = $FONT_SIZE + 5;
print '${voffset ', $VOFFSET_TEXT , '} ${font :size=', $f, '}${alignc}Weather:${font}', " $data{current}{'cclocation'}\n";
if (not defined $data{current}{observation_time_rfc822}) {
  $data{current}{observation_time_rfc822} = $data{current}{observation_time};
  $data{current}{observation_time_rfc822} =~ s/^\s*(?:Observation\s*of\s*:?|Last\s*Updated\s*(?:on)?)\s*//;
}
my($temp, $feelsLike, $humidity, $windSpeed, $windGust, $icon, $datetime, $weatherConditions) =
  ($data{current}{temp}, $data{current}{heat_index},
   $data{current}{relative_humidity}, $data{current}{wind_speed},
   $data{current}{wind_gust}, $data{current}{weather_icon},
   $data{current}{observation_time_rfc822}, $data{current}{weather});

my $date = ParseDate($datetime);

my $howOld = DateCalc($date, $now);
my $ago = Delta_Format($howOld, 0, "%mt min ago");
my $hourFormat = $HOUR_FORMAT;
if ($howOld ge DateCalc($now, "+ 1 day")) {
  $ago =  Delta_Format($howOld, 0, "\${color5}%dt day(s) ago\${color}");
} elsif (UnixDate($date, "%Y-%m-%d") ne UnixDate($now, "%Y-%m-%d")) {
  $hourFormat = "%a at $hourFormat" unless $hourFormat =~ /%[aA]/g;
  $ago = UnixDate($date, $hourFormat);
} else {
  $hourFormat =~ s/\s*%[aA]\s*//;
  $ago = UnixDate($date, $hourFormat);
}
$ago = Delta_Format(DateCalc($date, $now), 0, "%st sec ago")
  if ($ago =~ /0 min ago/);
$feelsLike = $data{current}{windchill}
  if (not defined $feelsLike) or $feelsLike =~ /^\s*N[\s\/]*A\s*$/i;
undef $feelsLike if defined $feelsLike and $feelsLike =~ /^\s*(N[\s\/]*A)?\s*$/i;
undef $windGust if defined $windGust   and $windGust =~ /^\s*(N[\s\/]*A)?\s*$/i;
undef $windSpeed if defined $windSpeed and $windSpeed =~ /^\s*(N[\s\/]*A)?\s*$/i;
undef $weatherConditions
  if defined $weatherConditions and $weatherConditions =~ /^\s*(N[\s\/]*A|unknown)?\s*$/i;

$icon = $data{extended}{"icon-0"}
  if ($icon =~ /unknown/i and $data{extended}{"date-0"} eq UnixDate($now, "%A"));

my($xpos, $vpos) = (350, $VOFFSET_IMAGE + 40);
my $smallFontSize = $FONT_SIZE - 5;
$smallFontSize = 7 if $smallFontSize < 7;
(defined $ago) ?
  print "\${alignr}\${font :size=${smallFontSize}px}(as of $ago)\n" :
   print "\n";
print "\${font :size=${FONT_SIZE}px} Current: $temp $degree";
print " (feels like: $feelsLike $degree)" if defined $feelsLike;
print "\${image $mythIconPath/$icon -p $xpos,$vpos  -s 50x37}"
  unless $icon =~ /unknown/i;
print "\n\${goto 82}Humidity: $humidity\%";
print "     Wind: " if defined $windSpeed or defined $windGust;
print "$windSpeed kph" if defined $windSpeed;
print "  ($windGust kph)" if defined $windGust;
print "\n\${goto 82}Conditions: $weatherConditions\n" if defined $weatherConditions;
print "\n";
($xpos, $vpos) = ($FONT_SIZE * (5 + $data{forecast}{maxLength}),
                  $VOFFSET_IMAGE + 78);

my $cnt = 0;
foreach my $ii (qw/0 1 2 3 4 5/) {
  next if not defined $data{forecast}{"time-${ii}"};
  $cnt++;
  my($time, $temp, $pop, $icon) =
    ($data{forecast}{"time-${ii}"}, $data{forecast}{"temp-${ii}"},
     $data{forecast}{"pop-${ii}"}, $data{forecast}{"18icon-${ii}"});
  $pop =~ s/\s+//g;
  $pop = "  $pop" if length($pop) eq 2;
  $pop = " $pop" if length($pop) eq 3;
  print "\${font :size=${FONT_SIZE}px} $time:\${goto 120}$temp $degree \${image $mythIconPath/$icon -p $xpos,$vpos  -s 20x15}     $pop chance\n";
  $vpos += $FONT_SIZE + 7;
}
($xpos, $vpos) = ($FONT_SIZE * 26,
                    $VOFFSET_IMAGE + 173);
foreach my $ii (qw/0 1 2 3 4 5/) {
  # You can also use "%doneDays" here, as in:
  #      next if defined $doneDays{$data{extended}{"date-${ii}"}};
  next if not defined $data{extended}{"date-${ii}"};
  next if $data{extended}{"date-${ii}"} eq UnixDate($now, "%A");
  my($day, $high, $low, $icon) =
    ($data{extended}{"date-${ii}"}, $data{extended}{"high-${ii}"},
     $data{extended}{"low-${ii}"}, $data{extended}{"icon-${ii}"});
  print "\${font :size=${FONT_SIZE}px} $day:\${goto 120}High: $high $degree   Low: $low $degree \${image $mythIconPath/$icon -p $xpos,$vpos  -s 20x15}\n";
  $vpos += $FONT_SIZE + 8;
}

###############################################################################
#
# Local variables:
# compile-command: "perl -c conky-mythtv-weather-build.plx"
# End:

