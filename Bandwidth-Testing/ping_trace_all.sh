#!/bin/sh
# Written by Denver Gingerich (ossguy), downloaded from:
#  wget http://ossguy.com/bandwidth/ping_trace_all.sh
#  Denver told me:
#      <denver> and I license it to you CC0
#  I made minor modifications to this, also licensed CC0 -- bkuhn@ebb.org

for host in `cat ../hosts`
do
	echo tracepath $host...
	echo \$ tracepath $host > tracepath_$host
	tracepath $host >> tracepath_$host
	echo ping $host...
	echo \$ ping -c10 $host > ping_$host
	ping -c10 $host >> ping_$host
done
