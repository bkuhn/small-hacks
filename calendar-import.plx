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
