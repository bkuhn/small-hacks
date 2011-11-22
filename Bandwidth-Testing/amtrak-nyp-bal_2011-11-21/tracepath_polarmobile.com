$ tracepath polarmobile.com
 1:  10.74.40.220                                          0.203ms pmtu 1500
 1:  10.74.40.1                                            4.861ms 
 1:  10.74.40.1                                            4.720ms 
 2:  10.74.40.1                                            2.516ms pmtu 1350
 2:  192.168.19.254                                      162.621ms 
 3:  172.16.221.252                                      232.598ms 
 4:  70.42.157.253                                       133.215ms 
 5:  core1.te5-1-bbnet1.wdc002.pnap.net                  1015.460ms 
 5:  core1.te5-1-bbnet1.wdc002.pnap.net                  293.349ms 
 7:  192.205.36.81                                       156.922ms asymm  9 
 8:  cr2.wswdc.ip.att.net                                169.822ms asymm 13 
 9:  cr1.cgcil.ip.att.net                                522.283ms asymm 12 
10:  cr83.cgcil.ip.att.net                               228.109ms asymm 11 
11:  gar3.chail.ip.att.net                               240.901ms asymm 10 
12:  12.86.65.42                                         177.131ms 
13:  no reply
14:  no reply
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
