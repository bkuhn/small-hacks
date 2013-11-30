#!/usr/bin/perl -w
# calendar-import.plx                                         -*- Perl -*-
# ====================================================================
#
# The sub's "safe_read_from_pipe" and read_from_process are:
# ====================================================================
# Copyright (c) 2000-2004 CollabNet.  All rights reserved.
#
# This software is licensed as described in the file COPYING, which
# you should have received as part of this distribution.  The terms
# are also available at http://subversion.tigris.org/license-1.html.
# If newer versions of this license are posted there, you may use a
# newer version instead, at your option.
#
# This software consists of voluntary contributions made by many
# individuals.  For exact contribution history, see the revision
# history and logs, available at http://subversion.tigris.org/.


#  Note: bkuhn downloaded the license from
#  http://subversion.tigris.org/license-1.html on 2013-12-29 which said:

# The license of Subversion 1.7 and later is at
# http://svn.apache.org/repos/asf/subversion/trunk/LICENSE.

# The license of Subversion 1.6 and earlier can be found at
# http://svn.apache.org/repos/asf/subversion/tags/1.6.0/www/license-1.html.

# Both license texts are now included, in APACHE-LICENSE and OLD-SVN-LICENSE,
# respectively.
# ====================================================================
#

# Copyright © 2013 Bradley M. Kuhn <bkuhn@ebb.org>
#
# This software's license gives you freedom; you can copy, convey,
# propogate, redistribute and/or modify this program under the terms of
# the GNU  General Public License (GPL) as published by the Free
# Software Foundation (FSF), either version 3 of the License, or (at your
# option) any later version of the GPL published by the FSF.
#
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program in a file in the toplevel directory called
# "GPLv3".  If not, see <http://www.gnu.org/licenses/>.

use strict;
use warnings;

my($CONFIG_FILE) = (@ARGV);

if (@ARGV != 1) {
  print STDERR "usage: $0 <CONFIG_FILE>\n";
  exit 1;
}
###############################################################################
# Start a child process safely without using /bin/sh.
sub safe_read_from_pipe
{
  unless (@_)
    {
      DieLog("$0: safe_read_from_pipe passed no arguments.");
    }

  my $pid = open(SAFE_READ, '-|');
  unless (defined $pid)
    {
      DieLog("$0: cannot fork: $!");
    }
  unless ($pid)
    {
      open(STDERR, ">&STDOUT")
        or DieLog("$0: cannot dup STDOUT: $!");
      exec(@_)
        or DieLog("$0: cannot exec `@_': $!\n");
    }
  my @output;
  while (<SAFE_READ>)
    {
      s/[\r\n]+$//;
      push(@output, $_);
    }
  close(SAFE_READ);
  my $result = $?;
  my $exit   = $result >> 8;
  my $signal = $result & 127;
  my $cd     = $result & 128 ? "with core dump" : "";
  if ($signal or $cd)
    {
      DieLog("$0: pipe from `@_' failed $cd: exit=$exit signal=$signal\n");
    }
  if (wantarray)
    {
      return ($result, @output);
    }
  else
    {
      return $result;
    }
}
###############################################################################
# Use safe_read_from_pipe to start a child process safely and return
# the output if it succeeded or an error message followed by the output
# if it failed.
sub read_from_process
{
  unless (@_)
    {
      DieLog("$0: read_from_process passed no arguments.");
    }
  my ($status, @output) = &safe_read_from_pipe(@_);
  if ($status)
    {
      return ("$0: `@_' failed with this output:", @output);
    }
  else
    {
      return @output;
    }
}
###############################################################################
sub  ParseEventAndAddProposed ($$$) {
  my($config, $veventFile, $modString) = @_;

  my $icsImportFile = tmpnam();

  my $newCalendar = Data::ICal->new(data => <<END_ICAL
BEGIN:VCALENDAR
VERSION:2.0
PRODID:-//Emacs//NONSGML icalendar.el//EN
END:VCALENDAR
END_ICAL
);
  my $oldCalendar = Data::ICal->new(filename => $veventFile);
  my $entries = (defined $oldCalendar) ? $oldCalendar->entries : [];
  foreach my $entry (@{$entries}) {
    my $summary = $entry->property("summary");
    if (defined $summary) {
      die("Multiple summary found in $veventFile") unless @{$summary} == 1;
      $summary->[0]->value($modString . ": " .  $summary->[0]->value);
    }
    $newCalendar->add_entry($entry);
  }
  open(SINGLE_EVENT_ICAL, ">", $icsImportFile) or DieLog("Unable to overwrite $icsImportFile: $!");
  print SINGLE_EVENT_ICAL $newCalendar->as_string;
  close SINGLE_EVENT_ICAL;
  DieLog("Error ($?) while writing $icsImportFile ($?): $!") unless $? == 0;
  undef $newCalendar;

  my($elispFH, $elispFile) = tempfile();
  print $elispFH "(setq-default european-calendar-style t)\n"
    if $config->{calendarStyle} =~  /european/i;
  print $elispFH <<ELISP_END
(setq icalendar-uid-format "emacs-%u-%h-%s")
(icalendar-import-file "$icsImportFile" "$config->{proposedDiary}")
ELISP_END
;
  $elispFH->close();
  my @emacsOutput = read_from_process($config->{emacsBinary}, '--no-windows',
                 '--batch', '--no-site-file', '-l', $elispFile);
  DieLog("Emacs process for importing $veventFile and " .
         "$config->{proposedDiary} exited with non-zero exit status of " .
         "$? ($!), and output of:\n    " . join("\n   ", @emacsOutput))
    if ($? != 0);
  my $goodCount =0;
  foreach my $line (@emacsOutput) { $goodCount++;  }
  DieLog("Unexpected Emacs output: " . join("\n   ", @emacsOutput))
    if ($goodCount > 1);
  WarnLog("unable to remove temporary file: $icsImportFile: $!")
          unless unlink($icsImportFile) == 1;
}
###############################################################################
sub HandleProposal ($$$) {
  my($config, $operation, $file) = @_;

  if ($operation eq 'A') {
    ParseEventAndAddProposed($config, $file, "PROPOSED ADDITION");
  } elsif ($operation eq 'M') {
    ParseEventAndAddProposed($config, $file, "PROPOSED CHANGE");
  } elsif ($operation eq 'D') {
    chdir $config->{gitDir} or DieLog("Unable to change directory to $config->{gitDir}");
    system($config->{gitBinary}, 'checkout', $config->{myBranch});
    DieLog("Unable to checkout $config->{myBranch} branch in git") unless ($? == 0);

    ParseEventAndAddProposed($config, $file, "PROPOSED DELETE");

    # Now, reset back to incoming branch, as GenerateDiaryFromNewEvents assumes that.
    chdir $config->{gitDir} or DieLog("Unable to change directory to $config->{gitDir}");
    system($config->{gitBinary}, 'checkout', $config->{incomingBranch});
    DieLog("Unable to checkout $config->{incomingBranch} branch in git") unless ($? == 0);
  } else {
    DieLog("Invalid operation of $operation for $file");
  }
}
###############################################################################
sub GenerateDiaryFromNewEvents ($) {
  my($config)  = @_;

  chdir $config->{gitDir} or DieLog("Unable to change directory to $config->{gitDir}");

  system($config->{gitBinary}, 'checkout', $config->{incomingBranch});
  DieLog("Unable to checkout $config->{incomingBranch} branch in git") unless ($? == 0);
  my @gitDiffSummaryOutput =
    read_from_process($config->{gitBinary}, 'diff-index', $config->{myBranch});

  foreach my $line (@gitDiffSummaryOutput) {
    next if $line =~ /$ENV{USER}/;   # Ignore lines that aren't for my calendar.
    DieLog("odd line in diff-index output: $line") unless
      $line =~ /(A|D|M)\s+(\S+)$/;
    my($operation, $file) = ($1, $2);
    HandleProposedEvent($config, $operation, $file);
  }
}
###############################################################################

system("/usr/bin/lockfile -r 8 $CALENDAR_LOCK_FILE");
DieLog("Failure to acquire calendar lock on $CALENDAR_LOCK_FILE") unless ($? == 0);
my $config = ReadConfig($CONFIG_FILE);

$config->{scrubPrivate} = 0 if not defined $config->{scrubPrivate};
$config->{reportProblems} = $config->{user} if not defined $config->{reportProblems};
$config->{emacsBinary} = "/usr/bin/emacs" if not defined $config->{emacsBinary};
$config->{calendarStyle} = 'plain' if not defined $config->{calendarStyle};
DieLog("$config->{emacsBinary} doesn't appear to be executable") unless -x $config->{emacsBinary};

DieLog("$CONFIG_FILE doesn't specify a (readable) Git directory via gitDir setting: $!")
  unless defined $config->{gitDir} and -d $config->{gitDir};



&$LOCK_CLEANUP_CODE();
__END__
# Local variables:
# compile-command: "perl -c calendar-import.plx"
# End:
