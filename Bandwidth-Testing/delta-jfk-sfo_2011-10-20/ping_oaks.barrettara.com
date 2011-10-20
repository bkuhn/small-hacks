$ ping -c10 oaks.barrettara.com
PING cpe00146c37277d-cm00122540140e.cpe.net.cable.rogers.com (99.245.149.18) 56(84) bytes of data.
64 bytes from CPE00146c37277d-CM00122540140e.cpe.net.cable.rogers.com (99.245.149.18): icmp_req=1 ttl=229 time=217 ms
64 bytes from CPE00146c37277d-CM00122540140e.cpe.net.cable.rogers.com (99.245.149.18): icmp_req=2 ttl=229 time=247 ms
64 bytes from CPE00146c37277d-CM00122540140e.cpe.net.cable.rogers.com (99.245.149.18): icmp_req=3 ttl=229 time=224 ms
64 bytes from CPE00146c37277d-CM00122540140e.cpe.net.cable.rogers.com (99.245.149.18): icmp_req=4 ttl=229 time=318 ms
64 bytes from CPE00146c37277d-CM00122540140e.cpe.net.cable.rogers.com (99.245.149.18): icmp_req=5 ttl=229 time=765 ms
64 bytes from CPE00146c37277d-CM00122540140e.cpe.net.cable.rogers.com (99.245.149.18): icmp_req=6 ttl=229 time=502 ms
64 bytes from CPE00146c37277d-CM00122540140e.cpe.net.cable.rogers.com (99.245.149.18): icmp_req=7 ttl=229 time=396 ms
64 bytes from CPE00146c37277d-CM00122540140e.cpe.net.cable.rogers.com (99.245.149.18): icmp_req=8 ttl=229 time=182 ms
64 bytes from CPE00146c37277d-CM00122540140e.cpe.net.cable.rogers.com (99.245.149.18): icmp_req=9 ttl=229 time=235 ms
64 bytes from CPE00146c37277d-CM00122540140e.cpe.net.cable.rogers.com (99.245.149.18): icmp_req=10 ttl=229 time=332 ms

--- cpe00146c37277d-cm00122540140e.cpe.net.cable.rogers.com ping statistics ---
10 packets transmitted, 10 received, 0% packet loss, time 9000ms
rtt min/avg/max/mdev = 182.431/342.418/765.569/168.464 ms
