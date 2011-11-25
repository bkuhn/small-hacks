$ tracepath apache2-rank.blade.dreamhost.com
 1:  10.81.40.87                                           0.196ms pmtu 1500
 1:  10.81.40.1                                           36.366ms 
 1:  10.81.40.1                                            3.451ms 
 2:  10.81.40.1                                            3.505ms pmtu 1350
 2:  192.168.23.254                                      1002.796ms 
 2:  192.168.21.254                                      5428.486ms 
 3:  172.16.221.252                                      1340.797ms 
 3:  172.16.221.252                                      10365.811ms 
 4:  70.42.157.253                                       284.553ms 
 5:  core3.te4-1-bbnet1.wdc002.pnap.net                  665.607ms 
 6:  216.156.116.77.ptr.us.xo.net                        198.655ms 
 7:  206.111.0.214.ptr.us.xo.net                         198.952ms asymm  9 
 8:  xe-4-1-0.cr2.dca2.us.above.net                      249.214ms asymm  9 
 9:  xe-2-2-0.cr2.iah1.us.above.net                      196.789ms asymm 13 
10:  xe-2-0-0.cr2.lax112.us.above.net                    235.736ms asymm 11 
11:  xe-0-1-0.mpr1.lax7.us.above.net                     245.065ms asymm 12 
12:  64.124.196.90.t00867-01.above.net                   797.755ms 
13:  ip-66-33-201-221.dreamhost.com                      462.166ms asymm 12 
 5:  216.52.127.96                                       7522.936ms 
14:  router-0.hq.newdream.net                            558.679ms asymm 11 
14:  router-0.hq.newdream.net                            2703.973ms asymm 11 
15:  no reply
16:  no reply
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
