#!/usr/bin/perl

use strict;
use warnings;

use File::Temp qw/ tempfile /;
use URI::Fetch;

my $SLEEP_VAL_SECONDS = 15;
my @SCOTUS_URLS = ('http://www.supremecourt.gov/', 'http://www.supremecourt.gov/opinions/slipopinions.aspx');

my $DATE_STR_TO_SEEK = '6/07/10';
my $CASE_TO_SEEK = 'Krupski';

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
    my $out = "";
    if ($data =~ /$DATE_STR_TO_SEEK/im) {
      my $out = ($data =~ /$CASE_TO_SEEK/im) ? "$CASE_TO_SEEK announced!"
                                             : "No $CASE_TO_SEEK today!";
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

