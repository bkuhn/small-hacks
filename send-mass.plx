#!/usr/bin/perl
# send-mass.plx                                               -*- Perl -*-

use strict;
use warnings;

if (@ARGV != 3) {
  print "usage: $0 <LIST_OF_ADDRESSES_FILE> <MESSAGE_FILE> <FRM_ADDR>\n";
  exit 1;
}
my($LIST_FILE, $MESSAGE_FILE, $FROM_ADDRESS) = @ARGV;

open(LIST, "<$LIST_FILE") or die "unable to open $LIST_FILE: $!";

my @sendTo;
while (my $line = <LIST>) {
  chomp $line;
  $line =~ s/#.*$//;
  next if $line =~ /^\s*$/;
  push(@sendTo, $line);
}
close LIST;


open(MESSAGE, "<$MESSAGE_FILE") or die "unable to open $MESSAGE_FILE: $!";

my @message;

@message = <MESSAGE>;

close MESSAGE;

foreach my $fullEmailLine (@sendTo) {

  my $emailTo = $fullEmailLine;
  $emailTo =~ s/^[^<]+\<\s*([^\>]+)\s*\>\s*$/$1/;

  open(SENDMAIL, "|/usr/lib/sendmail -f \"$FROM_ADDRESS\" -oi -oem -- $emailTo") or
    die "unable to run sendmail: $!";

  print SENDMAIL "To: $emailTo\n"; # X-Precedence: bulk\n";
  print SENDMAIL @message;

  close SENDMAIL;
  sleep 1;
}

# Local variables:
# compile-command: "perl -c send-mass.plx"
# End:
