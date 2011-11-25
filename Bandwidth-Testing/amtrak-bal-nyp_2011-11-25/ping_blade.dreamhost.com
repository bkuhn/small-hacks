$ ping -c10 blade.dreamhost.com
PING blade.dreamhost.com (67.205.53.98) 56(84) bytes of data.
64 bytes from blade.dreamhost.com (67.205.53.98): icmp_req=1 ttl=53 time=986 ms
64 bytes from blade.dreamhost.com (67.205.53.98): icmp_req=2 ttl=53 time=1771 ms
64 bytes from blade.dreamhost.com (67.205.53.98): icmp_req=3 ttl=53 time=854 ms
64 bytes from blade.dreamhost.com (67.205.53.98): icmp_req=4 ttl=53 time=629 ms
64 bytes from blade.dreamhost.com (67.205.53.98): icmp_req=5 ttl=53 time=7472 ms

--- blade.dreamhost.com ping statistics ---
10 packets transmitted, 5 received, 50% packet loss, time 10639ms
rtt min/avg/max/mdev = 629.487/2342.977/7472.966/2593.649 ms, pipe 6
