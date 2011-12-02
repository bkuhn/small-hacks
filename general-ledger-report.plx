#!/usr/bin/perl
# general-ledger-report.plx                                    -*- Perl -*-
#
#    Script to generate a General Ledger report that accountants like
#    using Ledger.
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

use strict;
use warnings;

use Math::BigFloat;

my $LEDGER_CMD = "/usr/bin/ledger";

my $ACCT_WIDTH = 75;

sub ParseNumber($) {
  $_[0] =~ s/,//g;
  return Math::BigFloat->new($_[0]);
}

Math::BigFloat->precision(-2);
my $ZERO =  Math::BigFloat->new("0.00");

if (@ARGV < 2) {
  print STDERR "usage: $0 <BEGIN_DATE> <END_DATE> <OTHER_LEDGER_OPTS>\n";
  exit 1;
}

my($beginDate, $endDate, @otherLedgerOpts) = @ARGV;

my(@chartOfAccountsOpts) = ('--wide-register-format', "%150A\n",  '-w', '-s',
                            '-b', $beginDate, @otherLedgerOpts, 'reg');

open(CHART_DATA, "-|", $LEDGER_CMD, @chartOfAccountsOpts)
  or die "Unable to run $LEDGER_CMD @chartOfAccountsOpts: $!";

open(CHART_OUTPUT, ">", "chart-of-accounts.txt") or die "unable to write chart-of-accounts.txt: $!";

my @accounts;
while (my $line = <CHART_DATA>) {
  chomp $line;
  $line =~ s/^\s*//;   $line =~ s/\s*$//;
  push(@accounts, $line);

}
close(CHART_DATA); die "error reading ledger output for chart of accounts: $!" unless $? == 0;

open(CHART_OUTPUT, ">", "chart-of-accounts.txt") or die "unable to write chart-of-accounts.txt: $!";

my @sortedAccounts;
foreach my $acct (
                  # Proper sorting for a chart of accounts
                  sort {
                    if ($a =~ /^Assets/ and $b !~ /^Assets/) {
                      return 1;
                    } else {
                      return $a cmp $b;
                    }
                  } @accounts) {
  print CHART_OUTPUT "$acct\n";
  push(@sortedAccounts, $acct);

}
close(CHART_OUTPUT); die "error writing to chart-of-accounts.txt: $!" unless $? == 0;
###############################################################################
#
# Local variables:
# compile-command: "perl -c general-ledger-report.plx"
# End:

