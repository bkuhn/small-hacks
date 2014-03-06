#!/bin/sh
# license: CC0-1.0
# This document may be Copyright © 2008, 2010, Bradley M. Kuhn

# The copyright holders wish that this document could be placed into the
# public domain.  However, should such a public domain dedication not be
# possible, the copyright holders grant a waiver and/or license under the
# terms of CC0-1.0, as published by Creative Commons, Inc.  A copy of CC0-1.0
# can be found in the same repository as this README.md file under the
# filename CC0-1.0.txt.  If this document has been separated from the
# repository, a copy of CC0-1.0 can be found on Creative Commons' website at
#    http://creativecommons.org/publicdomain/zero/1.0/legalcode.

for i in `ls -r1t $1.~*~`; do
    date=`stat -c '%y' $i | perl -pe 's/(\.\d+) / /'`
    logdate=`stat -c '%y' $i|perl -pe 's/^(\S+)\s+.*$/$1/;'`
    echo $logdate $date $i
    cp -pa $i $2
    export GIT_AUTHOR_DATE="$date"
    git commit -m "Brought in file from ~ backup files, as it was on $logdate" $2
done
