$ ping -c10 polarmobile.com
PING polarmobile.com (64.34.71.101) 56(84) bytes of data.
64 bytes from polarmobile.com (64.34.71.101): icmp_req=1 ttl=44 time=177 ms
64 bytes from polarmobile.com (64.34.71.101): icmp_req=2 ttl=44 time=200 ms
64 bytes from polarmobile.com (64.34.71.101): icmp_req=3 ttl=44 time=860 ms
64 bytes from polarmobile.com (64.34.71.101): icmp_req=4 ttl=44 time=275 ms
64 bytes from polarmobile.com (64.34.71.101): icmp_req=5 ttl=44 time=671 ms
64 bytes from polarmobile.com (64.34.71.101): icmp_req=6 ttl=44 time=324 ms
64 bytes from polarmobile.com (64.34.71.101): icmp_req=7 ttl=44 time=726 ms
64 bytes from polarmobile.com (64.34.71.101): icmp_req=8 ttl=44 time=211 ms
64 bytes from polarmobile.com (64.34.71.101): icmp_req=9 ttl=44 time=153 ms
64 bytes from polarmobile.com (64.34.71.101): icmp_req=10 ttl=44 time=189 ms

--- polarmobile.com ping statistics ---
10 packets transmitted, 10 received, 0% packet loss, time 13183ms
rtt min/avg/max/mdev = 153.491/379.120/860.689/252.943 ms
