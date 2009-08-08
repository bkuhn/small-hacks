#!/bin/sh

for i in `ls -r1t $1.~*~ $1`; do
    date=`stat -c '%y' $i|perl -pe 's/^(\S+)\s+.*$/$1/;'`
    echo $date $i
    cp -pa $i $2
    svn commit -m "  * file as it stood on $date" $2
done
