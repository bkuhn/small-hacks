#!/usr/bin/perl -w
# calendar-export.plx                                         -*- Perl -*-

# NOTE: Overall license of this file is GPLv3-only, due (in part) to Software
# Freedom Law Center copyrights (see below).  Kuhn's personal copyrights are
# licensed GPLv3-or-later.

# ====================================================================
# The sub's "safe_read_from_pipe" and read_from_process are:
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

# ====================================================================
# The functions DoLog, BinarySearchForTZEntry, PrivatizeMergeAndTZIcalFile,
# BuildTZList, MergeLists, PrivacyFilterICalFiles, and FilterEmacsToICal material
# copyrighted and licensed as below:

# Copyright © 2006 Software Freedom Law Center, Inc.
#
# This software gives you freedom; it is licensed to you under version 3
# of the GNU General Public License.
#
# This software is distributed WITHOUT ANY WARRANTY, without even the
# implied warranties of MERCHANTABILITY and FITNESS FOR A PARTICULAR
# PURPOSE.  See the GNU General Public License for further details.
#
# You should have received a copy of the GNU General Public License,
# version 3.  If not, see <http://www.gnu.org/licenses/>

use strict;
use warnings;

use POSIX ":sys_wait_h";
use Fcntl;             # for sysopen
use Carp;
use Data::ICal;
use File::Temp qw/:POSIX tempfile/;
use DateTime::TimeZone;
use Date::Manip;
use DateTime::Format::ICal;

my($CONFIG_FILE) = (@ARGV);

if (@ARGV != 1) {
  print STDERR "usage: $0 <CONFIG_FILE>\n";
  exit 1;
}
###############################################################################
my $CALENDAR_LOCK_FILE = "$ENV{HOME}/.emacs-calendar-to-ics-lock";

my $LOCK_CLEANUP_CODE = sub {
  return (unlink($CALENDAR_LOCK_FILE) != 1) ?
    "Failed unlink of $CALENDAR_LOCK_FILE.  Could cause trouble." :
    "";
};
###############################################################################
{
  my %messageHistory;

  sub DoLog ($$$;$) {
    my($type, $user, $message, $cleanupCode) = @_;

    use Date::Manip;
    my $NOW = ParseDate("now");

    my $lastTime = $messageHistory{$message};

    my $sendIt = 0;
    if (not defined $lastTime) {
      $sendIt = 1;
    } else {
      my $err;
      my $sinceLast = DateCalc($lastTime,"+ 10 minutes",\$err);
      $sendIt = 1 if ($NOW gt $sinceLast);
    }
    if ($sendIt) {
      my  $fh = File::Temp->new();
      $fh->unlink_on_destroy( 1 );
      my  $fname = $fh->filename;
      print $fh "Calendar Export Failure: $message\n";
      $fh->close();
      system('/home/bkuhn/bin/myosd', $fname);
      unless (-f "$ENV{HOME}/.silent-running") {
        open(ESPEAK, "-|", "/usr/bin/espeak",  '-p', '45', '-s', '130', '-f', $fname, "--stdout");
        open(PAPLAY, "|-", "/usr/bin/paplay");
        my $data;
        while (read(ESPEAK, $data, 8) == 8) {
          print PAPLAY  $data;
        }
        close PAPLAY; close ESPEAK;
      }
      system('/usr/bin/notify-send', '-u', 'critical', '-t', '300000',
             'Failure', "Calendar export failure: $message");
      $messageHistory{$message} = $NOW;
    }
    my $more;
    $more = &$cleanupCode if defined $cleanupCode and ref $cleanupCode;
    $message .= "  $more" if (defined $more and $more !~ /^\s*$/);
    croak $message if $type eq "die";
    warn $message;
  }
  sub DieLog ($;$) {
    DoLog("die", undef, $_[0], $_[1]);
  }
  sub WarnLog ($$) {
    DoLog("warn", $_[0], $_[1]);
  }
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
sub BinarySearchForTZEntry {
# $tzList is assumed to be sorted, $dateTime is 
  my($tzList, $dateTime) = @_;
  my ($l, $u) = (0, @$tzList - 1);  # lower, upper end of search interval
  my $i;                       # index of probe
  my $final = 0;
  while ($l <= $u) {
    $i = int(($l + $u)/2);
    my $compareVal = DateTime->compare($tzList->[$i]{date}, $dateTime);
    if ($compareVal < 0) {
      $l = $i+1;
      $final = $i;
    } elsif ($compareVal > 0) {
      $u = $i-1;
    } else {
      return $tzList->[$i]; # found, won't happen often
    }
  }
  return  $tzList->[$final];         # not found, go down one lower
}
###############################################################################
# Take a list of keys and a list of values and insersperse them and
# return the result
sub MergeLists {
    my ($keys, $values) = @_;
    DieLog("Length mismatch", $LOCK_CLEANUP_CODE) unless @$keys == @$values;
    # Add the argument names to the values
    my @result;
    for (my $i = 0; $i < @$keys; $i++) {
	push @result, $keys->[$i] => $values->[$i];
    }
    return @result;
}
###############################################################################
sub BuildTZList ($$$) {
  my($user, $pubEmacsFile, $privEmacsFile) = @_;

  my @tzList;

  foreach my $file ($pubEmacsFile, $privEmacsFile) {
    open(DATA, "<$file") or DieLog("unable to read $file: $!",
                                   $LOCK_CLEANUP_CODE);
    while (my $line = <DATA>) {
      if ($line =~ /^\s*;[;\s]*TZ\s*=([^\s,]+)\s*(?:,+\s*LOCA?T?I?O?N?\s*=\"([^"]+)\")?
                    \s+(?:at|on)\s*(.*)\s+in\s+(\S+)\s*$/ix) {
        my($newTZstr, $location, $dateStartStr, $dateStartTZstr) = ($1, $2, $3, $4);
        my $newTZ;
        eval { $newTZ = DateTime::TimeZone->new( name => $newTZstr ); };
        if ($@ or not defined $newTZ) {
          WarnLog($user,
                  "Invalid time zone of \"$newTZstr\" in $line from $file: $@");
          next;
        }
        my $dateStartTZ;
        eval {
          $dateStartTZ = DateTime::TimeZone->new( name => $dateStartTZstr ); };
        if ($@ or not defined $dateStartTZ) {
          WarnLog($user,
           "Invalid time zone of \"$dateStartTZstr\" in $line from $file: $@");
          next;
        }
        my(@data) = UnixDate("$dateStartStr", qw(%Y %m %d %H %M %S));
        if (@data != 6) {
          WarnLog($user, "Unparseable date string of \"$dateStartStr\"" .
                   "in $line from $file");
          next;
        }
        my @args = MergeLists([qw( year month day hour minute second)], \@data);
        my $startDate;
        eval {
          $startDate = DateTime->new(@args, time_zone => $dateStartTZstr);
        };
        if ($@ or not defined $startDate) {
          WarnLog($user, "Trouble parsing \"$dateStartStr $dateStartTZstr\" " .
                  "in $line from $file\n\n" .
                  "Most likely $dateStartTZstr was a bad time zone.: $@ ");
          next;
        }
        push(@tzList, { date => $startDate, newTZ => $newTZ, location => $location});
      }
    }
  }
  # If we found nothing, everything is NYC
  if (@tzList == 0) {
    push(@tzList, { date => DateTime->new(year => 2006,  month => 11, day => 03,
                                          hour =>  11, minute => 00,  second => 00,
                                          time_zone => "America/New_York"),
                    newTZ => "America/New_York", location => undef });

  }
  return sort { DateTime->compare($a->{date}, $b->{date}); } @tzList;
}
###############################################################################
sub FilterEmacsToICal ($$$$$) {
  my ($publicCalendarFile, $privateCalendarFile, $outputDir,
      $emacsSettings, $user) = @_;

  my @tzList = BuildTZList($emacsSettings->{reportProblems},
                           $publicCalendarFile, $privateCalendarFile);

  my($elispFH, $elispFile) = tempfile();
  my $icsWillBePrivatizedFile = tmpnam();
  my $icsPublicFile = tmpnam();
  print $elispFH "(setq-default european-calendar-style t)\n"
    if $emacsSettings->{calendarStyle} =~  /european/i;
  print $elispFH <<ELISP_END
(setq icalendar-uid-format "emacs-%u-%h-%s")
ELISP_END
;
  print $elispFH "(icalendar-export-file \"$privateCalendarFile\" \"$icsWillBePrivatizedFile\")\n"
    if defined $privateCalendarFile;
  print $elispFH "(icalendar-export-file \"$publicCalendarFile\" \"$icsPublicFile\")\n"
    if defined $publicCalendarFile;

  $elispFH->close();
  my @emacsOutput = read_from_process($emacsSettings->{emacsBinary}, '--no-windows',
                 '--batch', '--no-site-file', '-l', $elispFile);
  DieLog("Emacs process for exporting $privateCalendarFile and " .
         "$publicCalendarFile exited with non-zero exit status of " .
         "$? ($!), and output of:\n    " . join("\n   ", @emacsOutput),
         $LOCK_CLEANUP_CODE)
    if ($? != 0);
  my $goodCount =0;
  foreach my $line (@emacsOutput) {
    $goodCount++ 
      if $line =~ /^\s*Wrote\s+($icsPublicFile|$icsWillBePrivatizedFile)\s*$/;
  }
  DieLog("Unexpected Emacs output: " . join("\n   ", @emacsOutput),
         $LOCK_CLEANUP_CODE)
    if ($goodCount > 2);

  PrivatizeMergeAndTZIcalFile($icsWillBePrivatizedFile, $icsPublicFile,
                            $outputDir, \@tzList, $user);

  PrivacyFilterICalFile($outputDir) if $emacsSettings->{privacyScrub};
  DieLog("Unable to remove temporary files", $LOCK_CLEANUP_CODE)
    unless unlink($icsPublicFile, $icsWillBePrivatizedFile) == 2;
}
###############################################################################
sub PrivacyFilterICalFiles ($$) {
  my($icsDirectory) = @_;

  chdir $icsDirectory or die "unable to change to $icsDirectory: $!";

  foreach my $file (<*.ics>) {
    my $newCalendar = Data::ICal->new(data => <<END_ICAL
BEGIN:VCALENDAR
VERSION:2.0
PRODID:-//Emacs//NONSGML icalendar.el//EN
END:VCALENDAR
END_ICAL
);
    my $oldCalendar = Data::ICal->new(filename => $file);
    my $entries = (defined $oldCalendar) ? $oldCalendar->entries : [];
    my $x =0;
    foreach my $entry (@{$entries}) {
      my @newSubEntries;
      foreach my $subEntry (@{$entry->{entries}}) {
        my $refVal = ref $subEntry;
        if (defined $refVal and $refVal =~ /Alarm/i) {
          # Don't put it in the list in the public version if is an alarm
        } else {
          push(@newSubEntries, $subEntry);
        }
      }
      $entry->{entries} = \@newSubEntries;

      my $classes = $entry->property('class');
      my $class;
      foreach my $classProp (@{$classes}) {
        $class = $classProp->value;
        last if defined $class and
          $class =~ /^\s*(?:PUBLIC|PRIVATE|CONFIDENTIAL)\s*/i;
      }
      if (defined $class and $class  =~ /CONFIDENTIAL/i) {
        foreach my $prop (qw/location summary description/) {
          my $propList = $entry->property($prop);
          $entry->add_property($prop => "Private")
            if (defined $propList and @{$propList} > 0);
        }
      } elsif (defined $class and $class =~ /PRIVATE/i){
        # do not put this event in the output at all
        die "unable to scrub $file in $icsDirectory: $!"
          unless unlink($file) == 1;
      }
      $newCalendar->add_entry($entry);
    }
    open(SCRUBBED_CAL, ">$file") or
      DieLog("Unable to overwrite $file: $!", $LOCK_CLEANUP_CODE);
    print SCRUBBED_CAL $newCalendar->as_string;
    close SCRUBBED_CAL;
    DieLog("Error when writing $file: $!", $LOCK_CLEANUP_CODE)
      unless $? == 0;
    undef $newCalendar;
  }
}
######################################################################
sub PrivatizeMergeAndTZIcalFile ($$$$$$) {
  my($icsPrivate, $icsPublic, $icsOutputDir, $tzList, $user, $errorUser) = @_;

  my %calendar;
  $calendar{private} = Data::ICal->new(filename => $icsPrivate);
  $calendar{public} = Data::ICal->new(filename => $icsPublic);
  my $type = "public";
  foreach my $type (qw/public private/) {
    my $entries = (defined $calendar{$type}) ? $calendar{$type}->entries : [];
    foreach my $entry (@{$entries}) {
      my $newCalendar = Data::ICal->new(data => <<END_ICAL
BEGIN:VCALENDAR
VERSION:2.0
PRODID:-//Emacs//NONSGML icalendar.el//EN
END:VCALENDAR
END_ICAL
      );
      $entry->add_property(class => "CONFIDENTIAL") if ($type eq "private");

      # Let's shift some timezones around.
      foreach my $dateType (qw/DTSTART DTEND/) {
        my $datePropList = $entry->property($dateType);
        next unless @$datePropList > 0;

        WarnLog($errorUser, "Strange that the entry below for $icsOutputDir had more " .
                      "than one $dateType:\n" . Data::Dumper->Dumper($entry) )
          unless @$datePropList == 1;

        my $dateProp = $datePropList->[0];
        # Only continue processing date if we have this property.  (Duh)
        next unless defined $dateProp;
        my $params = $dateProp->parameters();

        # Only continue if it is a DATE-TIME property.  This is a bit of a
        # judgement call but I think it's the right one.  When someone
        # creates an all-day event, we don't want to allow it to drift to
        # antoher day merely because the user has moved time zones.

        next unless defined $params and defined $params->{VALUE}
                                    and $params->{VALUE} =~ /DATE\-TIME/i;
        my $nyTime = DateTime::Format::ICal->parse_datetime($dateProp->value);
        my $newDate = DateTime::Format::ICal->parse_datetime($dateProp->value);
        $nyTime->set_time_zone("America/New_York")
          if $nyTime->time_zone->name =~ /floating/;
        my $val = BinarySearchForTZEntry($tzList, $nyTime);
        $newDate->set_time_zone($val->{newTZ});
        $newDate->set_time_zone("America/New_York");
        $newDate->set_time_zone("floating");
        my $newICalDate = DateTime::Format::ICal->format_datetime($newDate);
        $dateProp->value($newICalDate);

      }
      $newCalendar->add_entry($entry);

      # Now, write out each event into a single ics file in $icsOutputDir.
      # This will overwrite existing events of the same name.

      my $uidList = $entry->property('UID');
      DieLog("This entry has multiple UIDs: @{$uidList}", $LOCK_CLEANUP_CODE)
        unless @$uidList == 1;
      my $uid = $uidList->[0]->value;

      my $outputFile = File::Spec->catpath("", $icsOutputDir, "${uid}.ics");
      open(SINGLE_EVENT_ICAL, ">", $outputFile) or
        DieLog("Unable to overwrite $outputFile: $!", $LOCK_CLEANUP_CODE);
      print SINGLE_EVENT_ICAL $newCalendar->as_string;
      close SINGLE_EVENT_ICAL;
      DieLog("Error ($?) while writing $outputFile ($?): $!", $LOCK_CLEANUP_CODE) unless $? == 0;
      undef $newCalendar;
    }
  }

  # Create specialized "Time Zone change" events to indicate the user's travel.
  foreach my $tzEntry (@$tzList) { $tzEntry->{date}->set_time_zone("floating"); }
  for (my $ii = 0; $ii < @$tzList; $ii++) {
    my $tzEntry = $tzList->[$ii];

    next unless defined $tzEntry->{location} and
                $tzEntry->{location} !~ /^\s*NYC\s*$/i;

    my $startDate = DateTime::Format::ICal->format_datetime($tzEntry->{date});


    my $nextDate = ($ii+1 < @$tzList) ?
      DateTime::Format::ICal->format_datetime($tzList->[$ii+1]{date}) : $startDate;

    $nextDate =~ s/T\d+Z?$//; $startDate =~ s/T\d+Z?$//;

    my $whereEvent = Data::ICal::Entry::Event->new();
    my $desc = "$user Travel: ". $tzEntry->{location};
    my $uid = "bkuhnScript" . '-' . sha1($desc . $startDate);
    $whereEvent->add_properties(summary     => "$user Travel: ". $tzEntry->{location},
                                description => $tzEntry->{location},
                                dtstart     => [ $startDate, { VALUE => 'DATE' } ],
                                dtend       => [ $nextDate,{ VALUE => 'DATE' } ],
                                uid         => $uid);
      my $newCalendar = Data::ICal->new(data => <<END_ICAL
BEGIN:VCALENDAR
VERSION:2.0
PRODID:-//Emacs//NONSGML icalendar.el//EN
END:VCALENDAR
END_ICAL
      );
    $newCalendar->add_entry($whereEvent);

    my $outputFile = File::Spec->catpath("", $icsOutputDir, "${uid}.ics");
    open(SINGLE_EVENT_ICAL, ">", $outputFile) or
      DieLog("Unable to overwrite $outputFile: $!", $LOCK_CLEANUP_CODE);
    print SINGLE_EVENT_ICAL $newCalendar->as_string;
    close SINGLE_EVENT_ICAL;
    DieLog("Error ($?) while writing $outputFile ($?): $!", $LOCK_CLEANUP_CODE) unless $? == 0;
    undef $newCalendar;
  }
  return \%calendar;
}
######################################################################
sub ReadConfig($) {
  my($configFile) = @_;
  open (CONFIG_FILE, "<", $configFile) or DieLog("unable to read $configFile ($?): $!");

  my %config;

  while (my $line = <CONFIG_FILE>) {
    chomp $line;
    DieLog("Unable to parse $line in config file, $configFile",
           $LOCK_CLEANUP_CODE)
      unless $line =~ /^\s*([^:]+)\s*:\s*([^:]+)\s*$/;
    $config{$1} = $2;
  }
  close CONFIG_FILE;  DieLog("Error reading $configFile ($?): $!",
                             $LOCK_CLEANUP_CODE) if $? != 0;
  return \%config;
}
######################################################################
system("/usr/bin/lockfile -r 8 $CALENDAR_LOCK_FILE");
unless ($? == 0) {
  print "\${color5}Calendar export failure: Cannot aquire lock on $CALENDAR_LOCK_FILE\n";
  exit 0;
}
if (not -r $CONFIG_FILE) {
  print "\${color5}$CONFIG_FILE does not exist\n";
  exit 1;
}
my $config = ReadConfig($CONFIG_FILE);

$config->{scrubPrivate} = 0 if not defined $config->{scrubPrivate};
$config->{reportProblems} = $config->{user} if not defined $config->{reportProblems};
$config->{emacsBinary} = "/usr/bin/emacs" if not defined $config->{emacsBinary};
$config->{calendarStyle} = 'plain' if not defined $config->{calendarStyle};
DieLog("$config->{emacsBinary} doesn't appear to be executable for $config->{emacsBinary}")
    unless defined $config->{emacsBinary} and -x $config->{emacsBinary};

DieLog("$CONFIG_FILE doesn't specify a (readable) output directory via outputDir setting: $!")
  unless defined $config->{outputDir} and -d $config->{outputDir};

if (defined $config->{cleanOutputDirFirst} and $config->{cleanOutputDirFirst}) {
  chdir $config->{outputDir} or die "unable to change directory to $config->{outputDir} $? $!";
  system("/bin/rm -f *.ics");
}

foreach my $key (qw/publicDiary privateDiary/) {
  unless (defined $config->{$key} and -r $config->{$key}) {
    print "\${color5}$key file, $config->{$key} does not exist\n";
    exit 1;
  }
}
FilterEmacsToICal($config->{publicDiary}, $config->{privateDiary},
                  $config->{outputDir}, $config, $config->{user});

&$LOCK_CLEANUP_CODE();

__END__
# Local variables:
# compile-command: "perl -c calendar-export.plx"
# End:
