$ ping -c10 pocketmatrix.com
PING pocketmatrix.com (96.30.2.198) 56(84) bytes of data.
64 bytes from ando.dotsbox.com (96.30.2.198): icmp_req=1 ttl=52 time=5501 ms
64 bytes from ando.dotsbox.com (96.30.2.198): icmp_req=2 ttl=52 time=4719 ms
64 bytes from ando.dotsbox.com (96.30.2.198): icmp_req=3 ttl=52 time=3720 ms
64 bytes from ando.dotsbox.com (96.30.2.198): icmp_req=4 ttl=52 time=2876 ms
64 bytes from ando.dotsbox.com (96.30.2.198): icmp_req=6 ttl=52 time=2006 ms
64 bytes from ando.dotsbox.com (96.30.2.198): icmp_req=7 ttl=52 time=1130 ms
64 bytes from ando.dotsbox.com (96.30.2.198): icmp_req=8 ttl=52 time=1383 ms
64 bytes from ando.dotsbox.com (96.30.2.198): icmp_req=5 ttl=52 time=9643 ms

--- pocketmatrix.com ping statistics ---
10 packets transmitted, 8 received, 20% packet loss, time 11001ms
rtt min/avg/max/mdev = 1130.033/3872.878/9643.835/2619.373 ms, pipe 6
