$ ping -c10 apache2-rank.blade.dreamhost.com
PING apache2-rank.blade.dreamhost.com (67.205.53.192) 56(84) bytes of data.
64 bytes from apache2-rank.blade.dreamhost.com (67.205.53.192): icmp_req=1 ttl=43 time=252 ms
64 bytes from apache2-rank.blade.dreamhost.com (67.205.53.192): icmp_req=2 ttl=43 time=264 ms
64 bytes from apache2-rank.blade.dreamhost.com (67.205.53.192): icmp_req=3 ttl=43 time=232 ms
64 bytes from apache2-rank.blade.dreamhost.com (67.205.53.192): icmp_req=4 ttl=43 time=231 ms
64 bytes from apache2-rank.blade.dreamhost.com (67.205.53.192): icmp_req=5 ttl=43 time=195 ms
64 bytes from apache2-rank.blade.dreamhost.com (67.205.53.192): icmp_req=6 ttl=43 time=181 ms
64 bytes from apache2-rank.blade.dreamhost.com (67.205.53.192): icmp_req=7 ttl=43 time=226 ms
64 bytes from apache2-rank.blade.dreamhost.com (67.205.53.192): icmp_req=8 ttl=43 time=176 ms
64 bytes from apache2-rank.blade.dreamhost.com (67.205.53.192): icmp_req=9 ttl=43 time=318 ms
64 bytes from apache2-rank.blade.dreamhost.com (67.205.53.192): icmp_req=10 ttl=43 time=213 ms

--- apache2-rank.blade.dreamhost.com ping statistics ---
10 packets transmitted, 10 received, 0% packet loss, time 9000ms
rtt min/avg/max/mdev = 176.883/229.393/318.284/40.297 ms
