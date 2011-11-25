$ tracepath blade.dreamhost.com
 1:  10.81.40.87                                           0.180ms pmtu 1500
 1:  10.81.40.1                                            2.365ms 
 1:  10.81.40.1                                            2.554ms 
 2:  10.81.40.1                                            7.248ms pmtu 1350
 2:  192.168.17.254                                      1515.458ms 
 2:  192.168.16.254                                      7614.953ms 
 3:  172.16.221.252                                      163.076ms 
 3:  172.16.221.252                                      6167.928ms 
 3:  172.16.221.252                                      12173.565ms 
 4:  70.42.157.253                                       225.478ms 
 5:  216.52.127.96                                       156.360ms 
 6:  216.156.116.77.ptr.us.xo.net                        123.881ms 
 7:  206.111.0.218.ptr.us.xo.net                         165.949ms asymm  9 
 8:  xe-4-1-0.cr2.dca2.us.above.net                      143.119ms asymm  9 
 9:  xe-2-2-0.cr2.iah1.us.above.net                      415.756ms asymm 13 
 8:  xe-4-1-0.cr2.dca2.us.above.net                      2802.168ms asymm  9 
10:  xe-2-0-0.cr2.lax112.us.above.net                    265.459ms asymm 11 
11:  xe-0-1-0.mpr1.lax7.us.above.net                     209.264ms asymm 12 
12:  64.124.196.90.t00867-01.above.net                   207.335ms 
13:  ip-66-33-201-221.dreamhost.com                      167.610ms asymm 12 
14:  router-0.hq.newdream.net                            197.925ms asymm 11 
 9:  xe-2-2-0.cr2.iah1.us.above.net                      3007.828ms asymm 13 
17:  no reply
18:  no reply
19:  no reply
20:  no reply
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
