$ ping -c10 oaks.barrettara.com
PING cpe00146c37277d-cm00122540140e.cpe.net.cable.rogers.com (99.245.149.18) 56(84) bytes of data.
64 bytes from CPE00146c37277d-CM00122540140e.cpe.net.cable.rogers.com (99.245.149.18): icmp_req=1 ttl=235 time=99.9 ms
64 bytes from cpe00146c37277d-cm00122540140e.cpe.net.cable.rogers.com (99.245.149.18): icmp_req=2 ttl=235 time=477 ms
64 bytes from cpe00146c37277d-cm00122540140e.cpe.net.cable.rogers.com (99.245.149.18): icmp_req=3 ttl=235 time=149 ms
64 bytes from cpe00146c37277d-cm00122540140e.cpe.net.cable.rogers.com (99.245.149.18): icmp_req=4 ttl=235 time=514 ms
64 bytes from cpe00146c37277d-cm00122540140e.cpe.net.cable.rogers.com (99.245.149.18): icmp_req=5 ttl=235 time=1007 ms
64 bytes from cpe00146c37277d-cm00122540140e.cpe.net.cable.rogers.com (99.245.149.18): icmp_req=6 ttl=235 time=336 ms
64 bytes from cpe00146c37277d-cm00122540140e.cpe.net.cable.rogers.com (99.245.149.18): icmp_req=7 ttl=235 time=2186 ms
64 bytes from cpe00146c37277d-cm00122540140e.cpe.net.cable.rogers.com (99.245.149.18): icmp_req=8 ttl=235 time=1926 ms
64 bytes from cpe00146c37277d-cm00122540140e.cpe.net.cable.rogers.com (99.245.149.18): icmp_req=9 ttl=235 time=1748 ms
64 bytes from cpe00146c37277d-cm00122540140e.cpe.net.cable.rogers.com (99.245.149.18): icmp_req=10 ttl=235 time=1200 ms

--- cpe00146c37277d-cm00122540140e.cpe.net.cable.rogers.com ping statistics ---
10 packets transmitted, 10 received, 0% packet loss, time 9001ms
rtt min/avg/max/mdev = 99.998/964.808/2186.356/730.437 ms, pipe 3
