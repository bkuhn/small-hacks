#!/usr/bin/perl
# Copyright (C) 2010, Bradley M. Kuhn
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

use strict;
use warnings;

use File::Temp qw/ tempfile /;
use URI::Fetch;
my %URLS = 
# 1Z5FX957P216384708
# 1ZX799380356685541                                                             
# FEDEX: 782107230144867
#1Z1826920372528717                                                             
(
'http://wwwapps.ups.com/WebTracking/track?HTMLVersion=5.0&loc=en_US&Requester=UPSHome&WBPM_lid=&trackNums=1ZX799470353725469&track.x=Track'
=>  { date => '07/06/2011', time => '7:03 A.M.' },
'http://wwwapps.ups.com/WebTracking/track?loc=en_US&track.x=Track&trackNums=%20%20%20%201ZX799470353838132'
=> { date => '07/06/2011', time => '9:03 A.M.' },
 'http://wwwapps.ups.com/WebTracking/track?HTMLVersion=5.0&loc=en_US&Requester=UPSHome&WBPM_lid=&trackNums=1ZX799390318463734&track.x=Track'
 => { date => '07/06/2011', time => '2:18 A.M.' },
);

my $SLEEP_VAL_SECONDS = 90;

if (@ARGV != 0) {
  print STDERR "Usage: $0\n";
  exit 1;
}


sub DieLoud {
  my($err) = @_;


  my ($fh, $filename) = tempfile();
  print $fh $err;

  print STDERR "$err\n";

  system("/home/bkuhn/bin/myosd $filename &");
  die "Unable to run myosd: $err" unless $? == 0;
  system("/bin/cat $filename | /usr/bin/espeak -p 45 -s 130  --stdin");
  die "Unable to run espeak for: $err" unless $? == 0;

  die $err;
}

sub WarnLoud {
  my($err) = @_;


  my ($fh, $filename) = tempfile();
  print $fh $err;

  print STDERR "$err\n";

  system("/home/bkuhn/bin/myosd $filename &");
  die "Unable to run myosd: $err" unless $? == 0;
  system("/bin/cat $filename | /usr/bin/espeak -p 45 -s 130  --stdin");
  die "Unable to run espeak for: $err" unless $? == 0;

  warn $err;
}

while (1) {
#  my($fh, $filename) = tempfile();

  foreach my $url (keys %URLS) {
    my($date, $time) = ($URLS{$url}{date}, $URLS{$url}{time});

    open(WEB_DATA, "/usr/bin/links -dump '$url'|")
      or DieLoud("unable to download URL");

    my $foundEvents = 0;
    while (my $line = <WEB_DATA>) {
      if ($line =~ /^\s*Location\s*Date/) {
        $foundEvents = 1;
      } elsif ($foundEvents) {
        if ($line =~ /^.*\s+(\d+\s*\/\s*\d*\s*\/\s*\d*)\s+(\S+\s+\S+)\s*(.*)/) {
          my($newDate, $newTime, $data) = ($1, $2, $3);
          if ($newDate ne $date or $newTime ne $time) {
            WarnLoud("UPS Action at $newTime on $newDate: $data: $url");
            last;
          } else {
            $foundEvents = 0;
            last;
          }
        }
      }
    }
    close WEB_DATA;
  }
  sleep $SLEEP_VAL_SECONDS;
  my $date=`/bin/date`;
  chomp $date;
  print "Checking (at $date)...\n";
}

