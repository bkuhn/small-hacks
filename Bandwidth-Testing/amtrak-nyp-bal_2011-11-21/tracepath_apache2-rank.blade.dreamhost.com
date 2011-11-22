$ tracepath apache2-rank.blade.dreamhost.com
 1:  10.74.40.220                                          0.197ms pmtu 1500
 1:  10.74.40.1                                            2.620ms 
 1:  10.74.40.1                                            2.405ms 
 2:  10.74.40.1                                            3.822ms pmtu 1350
 2:  192.168.17.254                                      178.012ms 
 3:  172.16.221.252                                      563.529ms 
 4:  70.42.157.253                                       179.271ms 
 5:  core1.te5-2-bbnet2.wdc002.pnap.net                  317.633ms 
 6:  no reply
 7:  te0-0-0-6.ccr22.iad02.atlas.cogentco.com            177.751ms 
 8:  te0-4-0-5.ccr22.dca01.atlas.cogentco.com            314.232ms 
 9:  te0-0-0-3.ccr22.atl01.atlas.cogentco.com            143.655ms asymm 12 
10:  te0-0-0-1.ccr22.iah01.atlas.cogentco.com            308.517ms 
11:  te0-0-0-3.ccr22.lax01.atlas.cogentco.com            1689.204ms 
11:  te0-0-0-5.ccr22.lax01.atlas.cogentco.com            5692.961ms 
12:  no reply
13:  no reply
14:  no reply
15:  no reply
16:  no reply
13:  38.122.20.218                                       12830.684ms 
13:  38.122.20.218                                       17087.360ms 
13:  38.122.20.218                                       21092.893ms 
18:  no reply
19:  no reply
14:  ip-66-33-201-114.dreamhost.com                      29441.788ms asymm 11 
21:  no reply
22:  no reply
23:  no reply
24:  no reply
25:  no reply
26:  no reply
27:  no reply
28:  no reply
29:  no reply
30:  no reply
31:  no reply
     Too many hops: pmtu 1350
     Resume: pmtu 1350 
