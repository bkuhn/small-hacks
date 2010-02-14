#!/bin/sh

for i in `ls -r1t $1.~*~`; do
    date=`stat -c '%y' $i | perl -pe 's/(\.\d+) / /'`
    logdate=`stat -c '%y' $i|perl -pe 's/^(\S+)\s+.*$/$1/;'`
    echo $logdate $date $i
    cp -pa $i $2
    export GIT_AUTHOR_DATE="$date"
    git commit -m "Brought in file from ~ backup files, as it was on $logdate" $2
done
