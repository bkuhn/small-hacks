#!/bin/bash
# Copyright (C) 2013 Bradley M. Kuhn
#
# The copyright holders wish that this script could be placed into the public
# domain.  However, should such a public domain dedication not be possible,
# the copyright holders grant a waiver and/or license under the terms of
# CC0-1.0, as published by Creative Commons, Inc.  A copy of CC0-1.0 can be
# found in the same repository as this README.md file under the filename
# CC0-1.0.txt.  If this document has been separated from the repository, a
# copy of CC0-1.0 can be found on Creative Commons' website at:
# http://creativecommons.org/publicdomain/zero/1.0/legalcode

/usr/bin/lockfile -r 8 ~/.running-calendar

remove_lock() {
    set +e
    /bin/rm -f ~/.running-calendar
    trap - INT TERM EXIT
    exit 0
}
remove_lock_and_fail() {
    echo '${color5}' $! $# 'Failure in' $0 ': Aborting!'
    /bin/rm -f ~/.running-calendar
}
# It's a TRAP!!!
trap remove_lock_and_fail INT TERM EXIT

set -e

HOME_MACHINE=baptist.ebb.org

~/hacks/Small-Hacks/calendar-export.plx ~/Public-Configuration/calendar-export-home.config

cd ~/calendars/personal/private/bkuhn

git checkout -q master
/usr/bin/rsync -q --exclude .git --delete -Hav ~/calendars/staging/personal/ ~/calendars/personal/private/bkuhn/
/usr/bin/git add .

set +e
/usr/bin/git commit -a -m'Automated calendar import from Emacs diary' > /dev/null
set -e
/usr/bin/git status > /dev/null

# Make sure machine is up.  set -e will ensure that.
/bin/ping -q -w 20 -c 5 $HOME_MACHINE > /dev/null 2>&1

cd ~/calendars/personal/private/bkuhn
git push -q ${HOME_MACHINE} master
git checkout -q webdav
git pull -q ${HOME_MACHINE} webdav

~/hacks/Small-Hacks/calendar-import.plx ~/Public-Configuration/calendar-export-home.config

git checkout -q master
git merge -q webdav -m'Automated merge from webdav branch'

if [ ! -z "$WORK_MACHINE" ]; then
    ~/hacks/Small-Hacks/calendar-export.plx ~/Public-Configuration/calendar-export-work.config

    cd ~/calendars/work/public/bkuhn

    /usr/bin/git checkout master
    /usr/bin/rsync -q --exclude .git --delete -Hav ~/calendars/staging/work/ ~/calendars/work/private/bkuhn/ 
    /usr/bin/git commit -a -m'Automated calendar import from Emacs diary'

    # Make sure machine is up.  set -e will ensure that.
    /bin/ping -q -w 20 -c 5 $WORK_MACHINE > /dev/null 2>&1
    cd ~/calendars/work/public/bkuhn
    git push  ${WORK_MACHINE} master
fi

remove_lock
trap - INT TERM EXIT
exit 0
