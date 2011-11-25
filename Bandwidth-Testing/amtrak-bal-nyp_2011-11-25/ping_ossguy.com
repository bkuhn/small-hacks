$ ping -c10 ossguy.com
PING ossguy.com (64.15.152.44) 56(84) bytes of data.
64 bytes from singpolyma.net (64.15.152.44): icmp_req=1 ttl=54 time=752 ms
64 bytes from singpolyma.net (64.15.152.44): icmp_req=2 ttl=54 time=443 ms
64 bytes from singpolyma.net (64.15.152.44): icmp_req=5 ttl=54 time=594 ms
64 bytes from singpolyma.net (64.15.152.44): icmp_req=6 ttl=54 time=950 ms
64 bytes from singpolyma.net (64.15.152.44): icmp_req=7 ttl=54 time=155 ms
64 bytes from singpolyma.net (64.15.152.44): icmp_req=3 ttl=54 time=4849 ms
64 bytes from singpolyma.net (64.15.152.44): icmp_req=4 ttl=54 time=4277 ms
64 bytes from singpolyma.net (64.15.152.44): icmp_req=8 ttl=54 time=537 ms
64 bytes from singpolyma.net (64.15.152.44): icmp_req=9 ttl=54 time=1030 ms
64 bytes from singpolyma.net (64.15.152.44): icmp_req=10 ttl=54 time=3116 ms

--- ossguy.com ping statistics ---
10 packets transmitted, 10 received, 0% packet loss, time 9001ms
rtt min/avg/max/mdev = 155.846/1670.732/4849.130/1643.228 ms, pipe 5
