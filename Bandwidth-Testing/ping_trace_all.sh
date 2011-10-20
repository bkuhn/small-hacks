#!/bin/sh
# Written by Denver Gingerich, downloaded from:
#  wget http://ossguy.com/bandwidth/ping_trace_all.sh
#  Denver told me:
#      <denver> and I license it to you CC0

for host in `cat ../bin/hosts`
do
	echo tracepath $host...
	echo \$ tracepath $host > tracepath_$host
	tracepath $host >> tracepath_$host
	echo ping $host...
	echo \$ ping -c10 $host > ping_$host
	ping -c10 $host >> ping_$host
done
