$ tracepath pocketmatrix.com
 1:  10.74.40.220                                          0.196ms pmtu 1500
 1:  10.74.40.1                                           20.243ms 
 1:  10.74.40.1                                           14.672ms 
 2:  10.74.40.1                                            2.157ms pmtu 1350
 2:  192.168.19.254                                      124.809ms 
 3:  172.16.221.252                                      197.685ms 
 4:  70.42.157.253                                       120.971ms 
 5:  core1.te5-2-bbnet2.wdc002.pnap.net                   98.277ms 
 6:  no reply
 7:  cr2-tengig0-7-3-0.washington.savvis.net             207.741ms 
 8:  cr2-pos-0-7-3-2.chicago.savvis.net                  214.082ms 
 9:  no reply
10:  ber2-pos-1-0-0.Chicago.savvis.net                   192.224ms 
11:  vl37.dsw3.chi2.wiredtree.com                        168.007ms asymm 12 
12:  96.30.18.81                                         178.594ms asymm 13 
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
