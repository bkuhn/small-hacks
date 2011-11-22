$ ping -c10 blade.dreamhost.com
PING blade.dreamhost.com (67.205.53.98) 56(84) bytes of data.
64 bytes from blade.dreamhost.com (67.205.53.98): icmp_req=1 ttl=53 time=293 ms
64 bytes from blade.dreamhost.com (67.205.53.98): icmp_req=2 ttl=53 time=258 ms
64 bytes from blade.dreamhost.com (67.205.53.98): icmp_req=3 ttl=53 time=1377 ms
64 bytes from blade.dreamhost.com (67.205.53.98): icmp_req=4 ttl=53 time=456 ms
64 bytes from blade.dreamhost.com (67.205.53.98): icmp_req=5 ttl=53 time=1628 ms
64 bytes from blade.dreamhost.com (67.205.53.98): icmp_req=6 ttl=53 time=1016 ms
64 bytes from blade.dreamhost.com (67.205.53.98): icmp_req=7 ttl=53 time=160 ms
64 bytes from blade.dreamhost.com (67.205.53.98): icmp_req=8 ttl=53 time=136 ms
64 bytes from blade.dreamhost.com (67.205.53.98): icmp_req=9 ttl=53 time=164 ms
64 bytes from blade.dreamhost.com (67.205.53.98): icmp_req=10 ttl=53 time=167 ms

--- blade.dreamhost.com ping statistics ---
10 packets transmitted, 10 received, 0% packet loss, time 8998ms
rtt min/avg/max/mdev = 136.708/566.001/1628.586/532.820 ms, pipe 2
