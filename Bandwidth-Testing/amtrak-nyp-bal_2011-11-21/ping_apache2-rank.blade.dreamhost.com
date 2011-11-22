$ ping -c10 apache2-rank.blade.dreamhost.com
PING apache2-rank.blade.dreamhost.com (67.205.53.192) 56(84) bytes of data.
64 bytes from apache2-rank.blade.dreamhost.com (67.205.53.192): icmp_req=2 ttl=53 time=252 ms
64 bytes from apache2-rank.blade.dreamhost.com (67.205.53.192): icmp_req=1 ttl=53 time=6634 ms
64 bytes from apache2-rank.blade.dreamhost.com (67.205.53.192): icmp_req=3 ttl=53 time=5447 ms

--- apache2-rank.blade.dreamhost.com ping statistics ---
10 packets transmitted, 3 received, 70% packet loss, time 8998ms
rtt min/avg/max/mdev = 252.568/4111.684/6634.890/2771.521 ms, pipe 7
