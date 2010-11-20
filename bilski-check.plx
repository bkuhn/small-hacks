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

my $SLEEP_VAL_SECONDS = 15;
my @SCOTUS_URLS = ('http://www.supremecourt.gov/', 'http://www.supremecourt.gov/opinions/slipopinions.aspx');

# Test data:
#my $DATE_STR_TO_SEEK = '6/07/10';
#my $CASE_TO_SEEK = 'Krupski';

my $DATE_STR_TO_SEEK = '6/28/10';
my $CASE_TO_SEEK = 'Bilski';

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

while (1) {
#  my($fh, $filename) = tempfile();

  foreach my $url (@SCOTUS_URLS) {
    my $file = URI::Fetch->fetch($url) or DieLoud(URI::Fetch->errstr());
    my $data = $file->content;

    $data =~ s/$DATE_STR_TO_SEEK.*McDonald//;

    my $out = "";
    if ($data =~ /$DATE_STR_TO_SEEK/im and $data =~ /$CASE_TO_SEEK/im) {
      my $out = "$CASE_TO_SEEK announced!";
      if ($data =~ /<\s*a[^>]+href\s*=\s*"([^"]+)".*$CASE_TO_SEEK/im) {
        my $subUrl = $1;
        $subUrl = "$url$subUrl" unless $subUrl =~ /^\s*(ftp|http)/;
        $out .= " URL: $subUrl";
        system("wget -N \'$subUrl\' &");
      }
      DieLoud($out);
    }
  }
  sleep $SLEEP_VAL_SECONDS;
}

