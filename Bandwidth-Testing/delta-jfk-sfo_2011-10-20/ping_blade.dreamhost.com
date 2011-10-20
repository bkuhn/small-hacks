$ ping -c10 blade.dreamhost.com
PING blade.dreamhost.com (67.205.53.98) 56(84) bytes of data.
64 bytes from blade.dreamhost.com (67.205.53.98): icmp_req=1 ttl=43 time=166 ms
64 bytes from blade.dreamhost.com (67.205.53.98): icmp_req=2 ttl=43 time=356 ms
64 bytes from blade.dreamhost.com (67.205.53.98): icmp_req=3 ttl=43 time=214 ms
64 bytes from blade.dreamhost.com (67.205.53.98): icmp_req=4 ttl=43 time=279 ms
64 bytes from blade.dreamhost.com (67.205.53.98): icmp_req=5 ttl=43 time=189 ms
64 bytes from blade.dreamhost.com (67.205.53.98): icmp_req=6 ttl=43 time=263 ms
64 bytes from blade.dreamhost.com (67.205.53.98): icmp_req=7 ttl=43 time=169 ms
64 bytes from blade.dreamhost.com (67.205.53.98): icmp_req=8 ttl=43 time=285 ms
64 bytes from blade.dreamhost.com (67.205.53.98): icmp_req=9 ttl=43 time=217 ms
64 bytes from blade.dreamhost.com (67.205.53.98): icmp_req=10 ttl=43 time=414 ms

--- blade.dreamhost.com ping statistics ---
10 packets transmitted, 10 received, 0% packet loss, time 9009ms
rtt min/avg/max/mdev = 166.017/255.802/414.938/77.525 ms
