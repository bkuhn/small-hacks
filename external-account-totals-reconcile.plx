#!/usr/bin/perl
# external-accounts-total-reconcile.plx                                    -*- Perl -*-
#
#    Script to verify that balances listed in an external file all match
#    the balances
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
use Date::Manip;
use File::Temp qw/tempfile/;

my $LEDGER_CMD = "/usr/bin/ledger";

my $ACCT_WIDTH = 75;

sub ParseNumber($) {
  $_[0] =~ s/,//g;
  return Math::BigFloat->new($_[0]);
}


Math::BigFloat->precision(-2);
my $ZERO =  Math::BigFloat->new("0.00");

if (@ARGV < 2) {
  print STDERR "usage: $0 <END_DATE> <OTHER_LEDGER_OPTS>\n";
  exit 1;
}

my($endDate, @otherLedgerOpts) = @ARGV;

my(@accountOptions) = ('--wide-register-format', '%-.150A %22.108t\n',  '-w', '-s',
                            '-e', $endDate, @otherLedgerOpts, 'reg');

my %externalBalances;
while (my $line = <STDIN>) {
  chomp $line;
  $line =~ s/^\s*//;   $line =~ s/\s*$//;

  next unless $line =~
    /^\s*(\S+\:.+)\s+[\(\d].+\s+\(?\s*([\d\.\,])+\s*\)?\s*$/;
  my($acct, $value) = ($1, $2);
  $acct =~ s/^\s*//;   $acct =~ s/\s*$//;

  $externalBalances{$acct} = ParseNumber($value);
}

open(ACCT_DATA, "-|", $LEDGER_CMD, @accountOptions)
  or die "Unable to run $LEDGER_CMD @accountOptions: $!";

my %internalBalances;
while (my $line = <ACCT_DATA>) {
  chomp $line;
  $line =~ s/^\s*//;   $line =~ s/\s*$//;
  next unless
    $line =~ /^\s*(\S+\:.+)\s+[\(\d].+\s+\(?\s*([\d\.\,])+\s*\)?\s*$/;

  my($acct, $value) = ($1, $2);
  $acct =~ s/^\s*//;   $acct =~ s/\s*$//;

  $internalBalances{$acct} = ParseNumber($value);

}
close(ACCT_DATA); die "error reading ledger output for chart of accounts: $!" unless $? == 0;

print "EXTERNAL: \n";
foreach my $acct (sort keys %externalBalances) {
  print "$acct: $externalBalances{$acct}\n";
}

print "INTERNAL: \n";
foreach my $acct (sort keys %internalBalances) {
  print "$acct: $internalBalances{$acct}\n";
}
###############################################################################
#
# Local variables:
# compile-command: "perl -c external-account-totals-reconcile.plx"
# End:

