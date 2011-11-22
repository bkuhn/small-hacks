$ ping -c10 ossguy.com
PING ossguy.com (64.15.152.44) 56(84) bytes of data.
64 bytes from singpolyma.net (64.15.152.44): icmp_req=1 ttl=54 time=206 ms
64 bytes from singpolyma.net (64.15.152.44): icmp_req=2 ttl=54 time=167 ms
64 bytes from singpolyma.net (64.15.152.44): icmp_req=3 ttl=54 time=216 ms
64 bytes from singpolyma.net (64.15.152.44): icmp_req=4 ttl=54 time=143 ms
64 bytes from singpolyma.net (64.15.152.44): icmp_req=5 ttl=54 time=96.9 ms
64 bytes from singpolyma.net (64.15.152.44): icmp_req=6 ttl=54 time=432 ms
64 bytes from singpolyma.net (64.15.152.44): icmp_req=7 ttl=54 time=149 ms
64 bytes from singpolyma.net (64.15.152.44): icmp_req=8 ttl=54 time=168 ms
64 bytes from singpolyma.net (64.15.152.44): icmp_req=9 ttl=54 time=196 ms
64 bytes from singpolyma.net (64.15.152.44): icmp_req=10 ttl=54 time=182 ms

--- ossguy.com ping statistics ---
10 packets transmitted, 10 received, 0% packet loss, time 9002ms
rtt min/avg/max/mdev = 96.912/196.257/432.450/85.340 ms
