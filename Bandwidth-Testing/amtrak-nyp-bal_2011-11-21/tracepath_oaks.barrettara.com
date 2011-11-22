$ tracepath oaks.barrettara.com
 1:  10.74.40.220                                          0.218ms pmtu 1500
 1:  10.74.40.1                                            3.660ms 
 1:  10.74.40.1                                            6.237ms 
 2:  10.74.40.1                                            3.085ms pmtu 1350
 2:  192.168.17.254                                      333.910ms 
 3:  172.16.221.252                                      2964.352ms 
 3:  172.16.221.252                                      10977.351ms 
 4:  70.42.157.253                                       164.454ms 
 4:  70.42.157.253                                       6192.078ms 
 5:  core2.te5-1-bbnet1.wdc002.pnap.net                  166.317ms 
 6:  TenGigE0-3-4-0.GW1.IAD8.ALTER.NET                   320.926ms 
 7:  0.xe-0-0-3.XL4.IAD8.ALTER.NET                       272.575ms asymm  8 
 8:  0.ae4.BR1.IAD8.ALTER.NET                            379.697ms asymm  9 
 9:  xe-2-1-0.er2.iad10.us.above.net                     201.855ms 
10:  64.124.196.214.allocated.above.net                  242.156ms asymm 15 
11:  69.63.249.241                                       183.660ms asymm 13 
12:  69.63.251.241                                       189.010ms 
13:  69.63.249.222                                       669.773ms 
14:  69.63.249.225                                       202.903ms 
15:  66.185.91.54                                        223.667ms 
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
