$ ping -c10 apache2-rank.blade.dreamhost.com
PING apache2-rank.blade.dreamhost.com (67.205.53.192) 56(84) bytes of data.
64 bytes from apache2-rank.blade.dreamhost.com (67.205.53.192): icmp_req=1 ttl=53 time=9975 ms
64 bytes from apache2-rank.blade.dreamhost.com (67.205.53.192): icmp_req=4 ttl=53 time=7058 ms
64 bytes from apache2-rank.blade.dreamhost.com (67.205.53.192): icmp_req=6 ttl=53 time=5087 ms
64 bytes from apache2-rank.blade.dreamhost.com (67.205.53.192): icmp_req=5 ttl=53 time=6089 ms
64 bytes from apache2-rank.blade.dreamhost.com (67.205.53.192): icmp_req=7 ttl=53 time=4155 ms
64 bytes from apache2-rank.blade.dreamhost.com (67.205.53.192): icmp_req=9 ttl=53 time=2214 ms
64 bytes from apache2-rank.blade.dreamhost.com (67.205.53.192): icmp_req=10 ttl=53 time=1265 ms
64 bytes from apache2-rank.blade.dreamhost.com (67.205.53.192): icmp_req=3 ttl=53 time=12209 ms

--- apache2-rank.blade.dreamhost.com ping statistics ---
10 packets transmitted, 8 received, 20% packet loss, time 9004ms
rtt min/avg/max/mdev = 1265.938/6007.225/12209.986/3472.586 ms, pipe 10
