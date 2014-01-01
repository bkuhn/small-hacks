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
use Text::Autoformat qw(autoformat);
use File::Temp ();

######################################################################
sub ReadRecentWeatherAlerts ($) {
  my($dir) = @_;

  my %info;
  my $file = File::Spec->catfile($dir, 'conky-weather-alert-recent');
  open(RECENT_ALERTS, "<", $file) or die "unable to open $file for reading: $!";
  my $key;
  my $data = "";
  foreach my $line (<RECENT_ALERTS>) {
    chomp $line;
    next if $line =~ /^\s*$/;
    if ($line =~ /^\s*([\d\:\-]+)/) {
      my $newKey = $1;
      $info{$key} = $data if defined $key;
      $key = $newKey;
      $data = "";
    } else {
      $data .= $line;
    }
  }
  close RECENT_ALERTS; die "error($?) reading $file: $!" unless $? == 0;

  $info{$key} = $data if (defined $key);  # Grab last one.

  return \%info;
}
######################################################################
sub WriteRecentWeatherAlerts ($$) {
  my($dir, $info) = @_;

  my $file = File::Spec->catfile($dir, 'conky-weather-alert-recent');
  open(RECENT_ALERTS, ">", $file) or die "unable to open $file for reading: $!";

  foreach my $key (sort keys %$info) {
    print RECENT_ALERTS "$key\n$info->{$key}\n";
  }
  close RECENT_ALERTS; die "error($?) writing $file: $!" unless $? == 0;
}
######################################################################

my $TEXT_LINE_OFFSET_VPOS_AMOUNT = 1.59;

my $now =  ParseDate("now");

my $DIR = File::Spec->catdir("$ENV{HOME}", 'tmp', '.conky-mythtv-weather');
chdir($DIR) or die "unable to go to $DIR";
my $VOFFSET_FILE = File::Spec->catfile($DIR, 'conky-weather-voffset-last');

my $MYTH_PATH = shift @ARGV;
my($command) = $MYTH_PATH .
             "/mythplugins/mythweather/mythweather/scripts/us_nws/nws-alert.pl";
my %data;

my $vpos = 0;

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

my $output = "";
my $record = "";
my $info = ReadRecentWeatherAlerts($DIR);
foreach my $location (keys %data) {
  die "Missing $location!" if (not defined $data{$location}{alerts});
  next if $data{$location}{alerts} =~ /no\s*warning/i;
  if ($output eq "") {
    print "\${color5}\${font :size=20}WEATHER ALERT:\n";
    $vpos += 20 * $TEXT_LINE_OFFSET_VPOS_AMOUNT;
  }
    $data{$location}{updatetime} =~ s/\s*last\s*updated?\s*(at|on)\s*//i;
  my $datetime = ParseDate($data{$location}{updatetime});

  my $ago = Delta_Format(DateCalc($datetime, $now), 0, "%mt min");
  if (defined $ago) {
    $ago = Delta_Format(DateCalc($datetime, $now), 0, "%st sec")
      if ($ago =~ /0 minutes/);
  } else {
    $ago = $data{$location}{updatetime};
  }
  my $data = $data{$location}{alerts};
  my $conkyOut = autoformat(
    "\${font :size=10}For $data{$location}{swlocation}, as of $ago ago:\n$data",
                       { justify => 'left', fill => 1, right => 60 });
  my $numLines = $conkyOut =~ tr/\n/\n/;
  print $conkyOut;
  $output .= "For $data{$location}{swlocation}, as of $ago ago: $data\n";
  $record .= "For $data{$location}{swlocation}: $data";
  $vpos += 10 * $TEXT_LINE_OFFSET_VPOS_AMOUNT * ($numLines);
}
if ($output ne "") {
  print "\${color}\$hr\n";
  $vpos += 10 * $TEXT_LINE_OFFSET_VPOS_AMOUNT;
}
$record =~ s/\n/ /gm;
if (keys(%data) > 0 and length($output) > 0) {
  my $alreadyDone = 0;
  foreach my $key (keys %$info) {
    $alreadyDone = (($info->{$key} eq $record) and
                    (Delta_Format(DateCalc($key, $now), 0, "%mt") < 1440));
    last if $alreadyDone;
  }
  unless ($alreadyDone) {
    $info->{$now} = $record;
    my $fh = File::Temp->new();
    $fh->unlink_on_destroy( 1 );
    my $fname = $fh->filename;
    print $fh $output;
    $fh->close();
    system("$ENV{HOME}/bin/myosd", $fname);
    system('/usr/bin/notify-send', '-u', 'critical', '-t', '300000',
           'Weather Alert', $output);
    system("$ENV{HOME}/bin/myspeakbyfile", $fname)
      unless -f "$ENV{HOME}/.silent-running";
  }
}
WriteRecentWeatherAlerts($DIR, $info);
$vpos = 9 if $vpos == 0;
open(VOFFSET, ">", $VOFFSET_FILE);
print VOFFSET "$vpos\n";
close VOFFSET;
###############################################################################
#
# Local variables:
# compile-command: "perl -c conky-mythtv-weather-alert.plx"
# End:

