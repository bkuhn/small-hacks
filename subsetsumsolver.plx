#!/usr/bin/perl
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

use strict;
use warnings;

my $ZERO= 0;

sub SubSetSumSolver ($$$) {
  my($numberList, $totalSought, $extractNumber) = @_;

  my($P, $N) = (0, 0);
  foreach my $ii (@{$numberList}) {
    if ($ii < $ZERO) {
      $N += $ii;
    } else {
      $P += $ii;
    }
  }
  print "P = $P, N = $N\n";

  my $size = scalar(@{$numberList});
  my %Q;
  my(@L) =
     map { { val => &$extractNumber($_), obj => $_ } } @{$numberList};

  for (my $ii = 0 ; $ii <= $size ; $ii++ ) {
    $Q{$ii}{0}{value} = 1;
    $Q{$ii}{0}{list} = [];
  }
  for (my $jj = $N; $jj <= $P ; $jj++) {
    $Q{0}{$jj}{value} = ($L[0]{val} == $jj);
    $Q{0}{$jj}{list} = $Q{0}{$jj}{value} ? [ $L[0]{obj} ] : [];
  }
  for (my $ii = 1; $ii <= $size ; $ii++ ) {
    for (my $jj = $N; $jj <= $P ; $jj++) {
      if ($Q{$ii-1}{$jj}{value}) {
        $Q{$ii}{$jj}{value} = 1;

        $Q{$ii}{$jj}{list} = [] unless defined $Q{$ii}{$jj}{list};
        push(@{$Q{$ii}{$jj}{list}}, @{$Q{$ii-1}{$jj}{list}});

      } elsif ($L[$ii]{val} == $jj) {
        $Q{$ii}{$jj}{value} = 1;

        $Q{$ii}{$jj}{list} = [] unless defined $Q{$ii}{$jj}{list};
        push(@{$Q{$ii}{$jj}{list}}, $jj);
      } elsif ($Q{$ii-1}{$jj - $L[$ii]{val}}{value}) {
        $Q{$ii}{$jj}{value} = 1;
        $Q{$ii}{$jj}{list} = [] unless defined $Q{$ii}{$jj}{list};
        push(@{$Q{$ii}{$jj}{list}}, $L[$ii]{obj}, @{$Q{$ii-1}{$jj - $L[$ii]{val}}{list}});
      } else {
        $Q{$ii}{$jj}{value} = 0;
        $Q{$ii}{$jj}{list} = [];
      }
    }
  }
  foreach (my $ii = 0; $ii <= $size; $ii++) {
    foreach (my $jj = $N; $jj <= $P; $jj++) {
      print "Q($ii, $jj) == $Q{$ii}{$jj}{value} with List of ", join(", ", @{$Q{$ii}{$jj}{list}}), "\n";
    }
  }
  if (not $Q{$size}{$totalSought}{value}) {
    print "No solution\n";
  } else {
    print "Solution\n";
    print "List: ", join(", ", @{$Q{$size}{$totalSought}{list}}), "\n";
  }
}

sub NonNegativeSubSetSumSolver ($$$) {
  # First arg is list ref that is the whole list, and second arg is the
  # total sought, and third arg is a subref that will extract the number
  # from items in the list (so that the list can be of more complex
  # objects)
  my($numberList, $totalSought, $extractNumber) = @_;

  my(@L) =
     map { { val => &$extractNumber($_), obj => $_ } } @{$numberList};

  my %Q;

  my $size = scalar(@{$numberList});
  for (my $ii = 0 ; $ii <= $size ; $ii++ ) {
    $Q{$ii}{0}{value} = 1;
    $Q{$ii}{0}{list} = [];
  }
  for (my $jj = 1; $jj <= $totalSought ; $jj++) {
    $Q{0}{$jj}{value} = 0;
    $Q{0}{$jj}{list} = [];
  }
  for (my $ii = 1; $ii <= $size ; $ii++ ) {
    for (my $jj = 1; $jj <= $totalSought ; $jj++) {
      if ($Q{$ii-1}{$jj}{value}) {
        $Q{$ii}{$jj}{value} = 1;

        $Q{$ii}{$jj}{list} = [] unless defined $Q{$ii}{$jj}{list};
        push(@{$Q{$ii}{$jj}{list}}, @{$Q{$ii-1}{$jj}{list}});

      } elsif ( ($L[$ii-1]{val} <= $jj) and ($Q{$ii-1}{$jj - $L[$ii-1]{val}}{value}) ) {
        $Q{$ii}{$jj}{value} = 1;

        $Q{$ii}{$jj}{list} = [] unless defined $Q{$ii}{$jj}{list};
        push(@{$Q{$ii}{$jj}{list}}, $L[$ii-1]{obj}, @{$Q{$ii-1}{$jj - $L[$ii-1]{val}}{list}});

      } else {
        $Q{$ii}{$jj}{value} = 0;
        $Q{$ii}{$jj}{list} = [];
      }

    }
  }
  if (not $Q{$size}{$totalSought}{value}) {
    print "No solution\n";
  } else {
    print "Solution\n";
    print "List: ", join(", ", @{$Q{$size}{$totalSought}{list}}), "\n";
  }
}

if (@ARGV < 1) {
  print STDERR "usage: $0 <SUM_DESIRED> <SET_NUMBERS> ...\n";
  exit 1;
}

my $sum = shift @ARGV;
my $x = SubSetSumSolver( \@ARGV, $sum, sub { return $_[0]; } );
$x = NonNegativeSubSetSumSolver( \@ARGV, $sum, sub { return $_[0]; } );
###############################################################################
#
# Local variables:
# compile-command: "perl -c subsetsumsolver.plx"
# End:
