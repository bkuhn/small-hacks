#!/usr/bin/perl
# trail-balance-report.plx                                    -*- Perl -*-
#
#    Script to generate a Trial Balance report for a ledger.
#
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

# ledger --wide-register-format "%-.70A %22.108t\n" -f no-fund.ledger -b 2010/03/01 -e 2011/03/01 -w reg

use strict;
use warnings;

use Math::BigFloat;

my $LEDGER_CMD = "/usr/bin/ledger";

my $ACCT_WIDTH = 70;

# http://www.moneyinstructor.com/lesson/trialbalance.asp
# told me:

# Key to preparing a trial balance is making sure that all the account
# balances are listed under the correct column.  The appropriate columns
# are as follows:

# Assets = Debit balance
# Liabilities = Credit balance
# Expenses = Debit Balance
# Equity = Credit balance
# Revenue = Credit balance


# So, there are some sign switches that are needed:

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

my(@ledgerOptions) = ('--wide-register-format', "%-.${ACCT_WIDTH}A %22.108t" .'\n',  '-w', '-s', @ARGV,
                     'reg');


open(LEDGER_DEBIT, "-|", $LEDGER_CMD, '-d', 'a>0', @ledgerOptions)
  or die "Unable to run $LEDGER_CMD -d a<0 @ledgerOptions: $!";

my %acct;
while (my $negLine = <LEDGER_DEBIT>) {

  chomp $negLine;

  die "Unable to parse output line from negative_ledger command: $negLine"
    unless $negLine =~ /^\s*([^\$]+)\s+\$\s*\s*([\d\.\,]+)/;
  my($account, $amount) = ($1, $2);
  $amount = ParseNumber($amount);
  $account =~ s/^\s+//;    $account =~ s/\s+$//;
  $acct{$account}{debit} = $amount;
}
close LEDGER_DEBIT;
die "error($0): $! while running negative_ledger command line" unless ($? == 0);

# Lazy here: this is nearly identical to loop above

open(LEDGER_CREDIT, "-|", $LEDGER_CMD, '-d', 'a<0', @ledgerOptions)
  or die "Unable to run $LEDGER_CMD -d a<0 @ledgerOptions: $!";
while (my $postLine = <LEDGER_CREDIT>) {
  chomp $postLine;

  die "Unable to parse output line from positive_ledger command: $postLine"
    unless $postLine =~ /^\s*([^\$]+)\s+\$\s*\-\s*([\d\.\,]+)/;
  my($account, $amount) = ($1, $2);
  $amount = ParseNumber($amount);
  $account =~ s/^\s+//;    $account =~ s/\s+$//;

  $acct{$account}{credit} = $amount;
}
close LEDGER_CREDIT;
die "error($0): $! while running positive_ledger command line" unless ($? == 0);

print sprintf("%-${ACCT_WIDTH}.${ACCT_WIDTH}s        %s              %s\n\n", "ACCOUNT", "DEBITS", "CREDITS");

my $format = "%-${ACCT_WIDTH}.${ACCT_WIDTH}s       \$%11.2f       \$%11.2f\n";
my($totDeb, $totCred) = ($ZERO, $ZERO);
foreach my $account (sort keys %acct) {
  foreach my $val (qw/debit credit /) {
    $acct{$account}{$val} = $ZERO unless defined $acct{$account}{$val};
  }
  print sprintf($format, $account,
                $acct{$account}{debit},                 $acct{$account}{credit});
  $totDeb += $acct{$account}{debit};
  $totCred += $acct{$account}{credit};


}
print "\n\n", sprintf($format, 'TOTAL', $totDeb, $totCred);
###############################################################################
#
# Local variables:
# compile-command: "perl -c trial-balance-report.plx"
# End:

