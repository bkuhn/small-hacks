$ ping -c10 pocketmatrix.com
PING pocketmatrix.com (96.30.2.198) 56(84) bytes of data.
64 bytes from ando.dotsbox.com (96.30.2.198): icmp_req=1 ttl=44 time=137 ms
64 bytes from ando.dotsbox.com (96.30.2.198): icmp_req=2 ttl=44 time=211 ms
64 bytes from ando.dotsbox.com (96.30.2.198): icmp_req=3 ttl=44 time=159 ms
64 bytes from ando.dotsbox.com (96.30.2.198): icmp_req=4 ttl=44 time=214 ms
64 bytes from ando.dotsbox.com (96.30.2.198): icmp_req=5 ttl=44 time=184 ms
64 bytes from ando.dotsbox.com (96.30.2.198): icmp_req=6 ttl=44 time=136 ms
64 bytes from ando.dotsbox.com (96.30.2.198): icmp_req=7 ttl=44 time=203 ms
64 bytes from ando.dotsbox.com (96.30.2.198): icmp_req=8 ttl=44 time=171 ms
64 bytes from ando.dotsbox.com (96.30.2.198): icmp_req=9 ttl=44 time=235 ms
64 bytes from ando.dotsbox.com (96.30.2.198): icmp_req=10 ttl=44 time=370 ms

--- pocketmatrix.com ping statistics ---
10 packets transmitted, 10 received, 0% packet loss, time 9010ms
rtt min/avg/max/mdev = 136.488/202.497/370.215/64.198 ms
