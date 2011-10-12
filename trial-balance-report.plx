#!/usr/bin/perl
# trail-balance-report.plx                                    -*- Perl -*-
#
#    Script to generate a Trial Balance report for a ledger.

# Copyright (C) 2011, Bradley M. Kuhn
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

my $LEDGER_CMD = "/usr/bin/ledger";

my $ACCT_WIDTH = 70;

sub ParseNumber($) {
  $_[0] =~ s/,//g;
  return Math::BigFloat->new($_[0]);
}

Math::BigFloat->precision(-2);
my $ZERO =  Math::BigFloat->new("0.00");

if (@ARGV == 0) {
  print STDERR "usage: $0 <LEDGER_OPTIONS>\n";
  exit 1;
}

my(@ledgerOptions) = ('--wide-register-format', "%-.${ACCT_WIDTH}A %22.108t\n",  '-w', '-s', @ARGV);


open(LEDGER_NEGATIVE, "-|", $LEDGER_CMD, '-d', 'a<0', @ledgerOptions)
  or die "Unable to run $LEDGER_CMD -d a<0 @ledgerOptions: $!";

my %acct;
while (my $negLine = <LEDGER_NEGATIVE>) {
  chomp $negLine;

  die "Unable to parse output line from negative_ledger command: $negLine"
    unless $negLine =~ /^\s*([^\$]+)\s+\$\s*\-\s*([\d\.\,]+)/;
  my($account, $amount) = ($1, $2);
  $amount = ParseNumber($amount);
  $account =~ s/^\s+//;    $account =~ s/\s+$//;

  $acc{$account}{negative} = $amount;
}
close LEDGER_NEGATIVE;
die "error($0): $! while running negative_ledger command line" unless ($? == 0);

open(LEDGER_NEGATIVE, "-|", $LEDGER_CMD, '-d', 'a<0', @ledgerOptions)
  or die "Unable to run $LEDGER_CMD -d a<0 @ledgerOptions: $!";


# Lazy here: this is nearly identical to loop above

open(LEDGER_POSITIVE, "-|", $LEDGER_CMD, '-d', 'a>0', @ledgerOptions)
  or die "Unable to run $LEDGER_CMD -d a<0 @ledgerOptions: $!";
while (my $negLine = <LEDGER_POSITIVE>) {
  chomp $negLine;

  die "Unable to parse output line from positive_ledger command: $negLine"
    unless $negLine =~ /^\s*([^\$]+)\s+\$\s*\s*([\d\.\,]+)/;
  my($account, $amount) = ($1, $2);
  $amount = ParseNumber($amount);
  $account =~ s/^\s+//;    $account =~ s/\s+$//;

  $acct{$account}{positive} = $amount;
}
close LEDGER_POSITIVE;
die "error($0): $! while running positive_ledger command line" unless ($? == 0);


print sprintf("%${ACCT_WIDTH}s       %s       %s\n\n", "ACCOUNT", "DEBITS", "CREDITS");

print "ACCOUNT       DEBITS       CREDITS\n\n";

my($totNeg, $totPos) = ($ZERO, $ZERO);
foreach my $account (keys %acct) {
  foreach my $val (qw/positive negative/) {
    $acct{$account}{$val} = $ZERO unless defined $acct{$account}{$val};
  }
  print sprintf("%${ACCT_WIDTH}s       \$%-.2d       \$%-2.d\n", $account, 
                $acct{$account}{negative},                 $acct{$account}{postiive});

}
print sprintf("%${ACCT_WIDTH}s       \$%-.2d       \$%-2.d\n", TOTAL, $totNeg, $totPos);
###############################################################################
#
# Local variables:
# compile-command: "perl -c trial-balance-report.plx"
# End:

