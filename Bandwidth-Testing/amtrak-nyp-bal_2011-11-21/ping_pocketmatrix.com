$ ping -c10 pocketmatrix.com
PING pocketmatrix.com (96.30.2.198) 56(84) bytes of data.
64 bytes from ando.dotsbox.com (96.30.2.198): icmp_req=1 ttl=53 time=1286 ms
64 bytes from ando.dotsbox.com (96.30.2.198): icmp_req=2 ttl=53 time=743 ms
64 bytes from ando.dotsbox.com (96.30.2.198): icmp_req=3 ttl=53 time=844 ms
64 bytes from ando.dotsbox.com (96.30.2.198): icmp_req=4 ttl=53 time=200 ms
64 bytes from ando.dotsbox.com (96.30.2.198): icmp_req=5 ttl=53 time=180 ms
64 bytes from ando.dotsbox.com (96.30.2.198): icmp_req=7 ttl=53 time=537 ms
64 bytes from ando.dotsbox.com (96.30.2.198): icmp_req=6 ttl=53 time=1565 ms
64 bytes from ando.dotsbox.com (96.30.2.198): icmp_req=8 ttl=53 time=355 ms
64 bytes from ando.dotsbox.com (96.30.2.198): icmp_req=9 ttl=53 time=1614 ms
64 bytes from ando.dotsbox.com (96.30.2.198): icmp_req=10 ttl=53 time=1427 ms

--- pocketmatrix.com ping statistics ---
10 packets transmitted, 10 received, 0% packet loss, time 8998ms
rtt min/avg/max/mdev = 180.259/875.702/1614.953/532.759 ms, pipe 2
