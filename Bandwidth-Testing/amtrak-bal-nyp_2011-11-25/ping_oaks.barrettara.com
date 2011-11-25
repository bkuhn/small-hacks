$ ping -c10 oaks.barrettara.com
PING cpe00146c37277d-cm00122540140e.cpe.net.cable.rogers.com (99.245.149.18) 56(84) bytes of data.
64 bytes from CPE00146c37277d-CM00122540140e.cpe.net.cable.rogers.com (99.245.149.18): icmp_req=1 ttl=235 time=245 ms
64 bytes from cpe00146c37277d-cm00122540140e.cpe.net.cable.rogers.com (99.245.149.18): icmp_req=2 ttl=235 time=389 ms
64 bytes from cpe00146c37277d-cm00122540140e.cpe.net.cable.rogers.com (99.245.149.18): icmp_req=3 ttl=235 time=191 ms
64 bytes from cpe00146c37277d-cm00122540140e.cpe.net.cable.rogers.com (99.245.149.18): icmp_req=4 ttl=235 time=259 ms
64 bytes from cpe00146c37277d-cm00122540140e.cpe.net.cable.rogers.com (99.245.149.18): icmp_req=5 ttl=235 time=164 ms
64 bytes from cpe00146c37277d-cm00122540140e.cpe.net.cable.rogers.com (99.245.149.18): icmp_req=6 ttl=235 time=157 ms
64 bytes from cpe00146c37277d-cm00122540140e.cpe.net.cable.rogers.com (99.245.149.18): icmp_req=7 ttl=235 time=132 ms
64 bytes from cpe00146c37277d-cm00122540140e.cpe.net.cable.rogers.com (99.245.149.18): icmp_req=8 ttl=235 time=1057 ms
64 bytes from cpe00146c37277d-cm00122540140e.cpe.net.cable.rogers.com (99.245.149.18): icmp_req=9 ttl=235 time=952 ms
64 bytes from cpe00146c37277d-cm00122540140e.cpe.net.cable.rogers.com (99.245.149.18): icmp_req=10 ttl=235 time=1569 ms

--- cpe00146c37277d-cm00122540140e.cpe.net.cable.rogers.com ping statistics ---
10 packets transmitted, 10 received, 0% packet loss, time 8997ms
rtt min/avg/max/mdev = 132.412/512.078/1569.899/474.854 ms, pipe 2
