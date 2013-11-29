#!/usr/bin/perl -w
# calendar-export.plx                                         -*- Perl -*-

# NOTE: Overall license of this file is GPLv3-only, due (in part) to Software
# Freedom Law Center copyrights (see below).  Kuhn's personal copyrights are
# licensed GPLv3-or-later.

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

# The functions PrivatizeMergeAndTZIcalFile, BuildTZList,
# PrivacyFilterICalFile, and FilterEmacsToICal material copyrighted and
# licensed as below:

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

use POSIX ":sys_wait_h";
use Fcntl;             # for sysopen
use Carp;
use Data::ICal;
use File::Temp qw/:POSIX tempfile/;
use DateTime::TimeZone;
use Date::Manip;
use DateTime::Format::ICal;
use Date::ICal;
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
  my ($publicCalendarFile, $privateCalendarFile, $outputFile,
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
(icalendar-export-file "$privateCalendarFile" "$icsWillBePrivatizedFile")
(icalendar-export-file "$publicCalendarFile" "$icsPublicFile")
ELISP_END
;
  $elispFH->close();
  my @emacsOutput = read_from_process($EMACS, '--no-windows',
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
    if ($goodCount != 2);

  my $icsFullFile = tmpnam();
  PrivatizeMergeAndTZIcalFile($icsWillBePrivatizedFile, $icsPublicFile,
                            $icsFullFile, \@tzList, $user,
                              $emacsSettings->{reportProblems});

  PrivacyFilterICalFile($icsFullFile, $outputFile);
  DieLog("Unable to remove temporary files")
    unless unlink($icsPublicFile, $icsWillBePrivatizedFile, $icsFullFile) == 3;
}
###############################################################################
sub PrivacyFilterICalFile ($$) {
  my($inputFile, $outputFile) = @_;

  my $oldCalendar = Data::ICal->new(filename => $inputFile);
  my $newCalendar = Data::ICal->new(data => <<END_ICAL
BEGIN:VCALENDAR
VERSION:2.0
PRODID:-//Mozilla.org/NONSGML Mozilla Calendar V1.0//EN
END:VCALENDAR
END_ICAL
);
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
      next;
    }
    $newCalendar->add_entry($entry);
  }
  open(SCRUBBED_CAL, ">$outputFile") or
    DieLog("Unable to overwrite $outputFile: $!", $LOCK_CLEANUP_CODE);
  print SCRUBBED_CAL $newCalendar->as_string;
  close SCRUBBED_CAL;
  DieLog("Error when writing $outputFile: $!", $LOCK_CLEANUP_CODE)
    unless $? == 0;
}
######################################################################
sub PrivatizeMergeAndTZIcalFile ($$$$$$) {
  my($icsPrivate, $icsPublic, $icsFull, $tzList, $user, $errorUser) = @_;

  my %calendar;
  $calendar{private} = Data::ICal->new(filename => $icsPrivate);
  $calendar{public} = Data::ICal->new(filename => $icsPublic);
  my $newCalendar = Data::ICal->new(data => <<END_ICAL
BEGIN:VCALENDAR
VERSION:2.0
PRODID:-//Emacs//NONSGML icalendar.el//EN
END:VCALENDAR
END_ICAL
);
  my $type = "public";
  while (1) {
    my $entries = (defined $calendar{$type}) ? $calendar{$type}->entries : [];
    foreach my $entry (@{$entries}) {
      $entry->add_property(class => "CONFIDENTIAL") if ($type eq "private");

      # Let's shift some timezones around.
      foreach my $dateType (qw/DTSTART DTEND/) {
        my $datePropList = $entry->property($dateType);
        next unless @$datePropList > 0;

        WarnLog($errorUser, "Strange that the entry below for $icsFull had more " .
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
    }
    last if ($type eq "private");
    $type = "private";
  }
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
                                uid         => $uid;
    $newCalendar->add_entry($whereEvent);
  }
  open(MERGED_CAL, ">$icsFull") or
    DieLog("Unable to overwrite $icsFull: $!", $LOCK_CLEANUP_CODE);
  print MERGED_CAL $newCalendar->as_string;
  close MERGED_CAL;
  DieLog("Error when writing $icsFull: $!", $LOCK_CLEANUP_CODE)
    unless $? == 0;
}
