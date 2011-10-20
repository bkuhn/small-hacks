$ ping -c10 ossguy.com
PING ossguy.com (67.205.53.192) 56(84) bytes of data.
64 bytes from apache2-rank.blade.dreamhost.com (67.205.53.192): icmp_req=1 ttl=43 time=1429 ms
64 bytes from apache2-rank.blade.dreamhost.com (67.205.53.192): icmp_req=2 ttl=43 time=1749 ms
64 bytes from apache2-rank.blade.dreamhost.com (67.205.53.192): icmp_req=3 ttl=43 time=1655 ms
64 bytes from apache2-rank.blade.dreamhost.com (67.205.53.192): icmp_req=4 ttl=43 time=1068 ms
64 bytes from apache2-rank.blade.dreamhost.com (67.205.53.192): icmp_req=5 ttl=43 time=1611 ms
64 bytes from apache2-rank.blade.dreamhost.com (67.205.53.192): icmp_req=6 ttl=43 time=1414 ms
64 bytes from apache2-rank.blade.dreamhost.com (67.205.53.192): icmp_req=7 ttl=43 time=1457 ms
64 bytes from apache2-rank.blade.dreamhost.com (67.205.53.192): icmp_req=8 ttl=43 time=1418 ms
64 bytes from apache2-rank.blade.dreamhost.com (67.205.53.192): icmp_req=9 ttl=43 time=1163 ms
64 bytes from apache2-rank.blade.dreamhost.com (67.205.53.192): icmp_req=10 ttl=43 time=1372 ms

--- ossguy.com ping statistics ---
10 packets transmitted, 10 received, 0% packet loss, time 11157ms
rtt min/avg/max/mdev = 1068.763/1434.149/1749.977/198.056 ms, pipe 2
