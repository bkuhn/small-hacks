#!/usr/bin/perl
# Text.pm                                                          -*- Perl -*-
#
#   Copyright (C) 2008, 2011 Bradley M. Kuhn.
#
# This program is free software; you can redistribute it and/or modify it
# under the terms of either the GNU General Public License; either Version
# 1, or (at your option) any later version, or under the terms of the
# Artistic License.
#
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
# or FITNESS FOR A PARTICULAR PURPOSE.  See either the GNU General Public
# License or the Artistic License for more details.
#
# Please see the LICENSE file that was shipped with this distribution for
# more details about the licensing of this program.
use strict;
use warnings;

use Text::Autoformat  qw(autoformat break_wrap);;

sub getText {
  my $text = shift;

  my @lines = split(/\n/, $text);
  my $lines = \@lines;
  my $newText;

  # First, fine out the average length of a line.
  my $count = 0;
  my $totLen = 0;
  for (my $ii = 0; $ii < @lines; $ii++) {
    $lines->[$ii] =~ s/^\s*//;  $lines->[$ii] =~ s/\s*$//;
    if ($lines->[$ii] !~ /^\s*$/) {
      $count++;
      $totLen += length($lines->[$ii]);
    }
  }
  my $avgLen = $totLen / $count;

  # Now, the loop that:
  #    (a) tries to find paragraphs
  #    (b) attempts to un-hyphenate words

  my $inPara = 0;
  my $cutOffLen = $avgLen - 5;
  for (my $ii = 0; $ii < @lines; $ii++) {
    my $curLen = length($lines->[$ii]);
    if ($lines->[$ii] =~ /\s{10,}/ or
        ($lines->[$ii] =~ /\s*\d+\.\s+/ and $curLen <= $cutOffLen)) {
      # Assume that any line that starts with ten spaces or more is a
      # title, heading or other stand alone unit of some sort.

      $newText .= "\n\n" if ($newText !~ /\n\n$/s or $inPara);

      $newText .= $lines->[$ii] . "\n";
      # Add another newline if one doesn't follow
      $newText .= "\n" unless $lines->[$ii+1] =~ /^\s*$/;
      $inPara = 0;
      next;
    }
    ($lines->[$ii],$lines->[$ii+1]) =
      _handleDeHyphen($lines->[$ii],$lines->[$ii+1])
        if ($lines->[$ii] =~ /\-$/);

    $curLen = length($lines->[$ii]);  # May have changed
    if ($curLen <= $cutOffLen) {
      $newText .= $lines->[$ii] . "\n";
      # Add another newline if one doesn't follow so the para is separated
      $newText .= "\n" unless $lines->[$ii+1] =~ /^\s*$/;
      $inPara = 0;
    } else {
      $newText .= $lines->[$ii] . " ";
      $inPara = 1;
    }
  }
  return autoformat($newText, {break=>break_wrap, all=>1, left=>0, right=>72});

}

sub _handleDeHyphen {
  my($self, $origFirstLine, $origSecondLine) = @_;
  my ($firstLine, $secondLine) = ($origFirstLine, $origSecondLine);
  if ($firstLine =~ s/^(.*\s+[\[\(,]*)(\S+)\-\s*$/$1/) {
    my $word = $2;
    if ($secondLine =~ s/^\s*(\w+)([\s\.\,\)\]]+)(.*)$/$3/) {
      $word .= $1;
      my $buffer = $2;
      my $firstLineRebuild = "$firstLine$word";
      $firstLineRebuild .= $buffer unless ($buffer =~ /^\s*$/);
      return ("$firstLineRebuild", $secondLine)
        if ($self->{speller}->check($word));
    }
  }
  return ($origFirstLine, $origSecondLine);
}


my $data;
while (my $line = <>) {
  $data .= $line;
}
print getText($data);
###############################################################################
# Local variables:
# compile-command: "perl -c normalize-text.plx"
# End:
