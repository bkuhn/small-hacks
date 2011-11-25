$ tracepath polarmobile.com
 1:  10.81.40.87                                           0.192ms pmtu 1500
 1:  10.81.40.1                                            3.390ms 
 1:  10.81.40.1                                            6.062ms 
 2:  10.81.40.1                                           69.168ms pmtu 1350
 2:  192.168.20.254                                      520.149ms 
 3:  172.16.221.252                                      172.306ms 
 4:  70.42.157.253                                       349.061ms 
 5:  core1.te5-2-bbnet2.wdc002.pnap.net                  361.338ms 
 6:  xe-0-5-0-4.r01.asbnva02.us.bb.gin.ntt.net           374.750ms 
 7:  ae-3.r02.asbnva02.us.bb.gin.ntt.net                 285.345ms 
 8:  xe-2.level3.asbnva02.us.bb.gin.ntt.net              546.413ms asymm  9 
 9:  vlan90.csw4.Washington1.Level3.net                  364.952ms 
 6:  xe-0-5-0-4.r01.asbnva02.us.bb.gin.ntt.net           3505.919ms 
10:  ae-62-62.ebr2.Washington1.Level3.net                1305.146ms 
10:  ae-62-62.ebr2.washington1.level3.net                395.383ms 
12:  ae-1-100.ebr2.NewYork2.Level3.net                   279.641ms asymm 11 
13:  ae-6-6.ebr2.NewYork1.Level3.net                     617.199ms asymm 12 
14:  ae-1-7.bar2.Toronto1.Level3.net                     727.224ms 
15:  ae-3-3.car2.Toronto2.Level3.net                     614.800ms asymm 14 
16:  no reply
17:  no reply
16:  PEER-1-NETW.car2.Toronto2.Level3.net                4410.960ms 
11:  ae-3-3.ebr1.NewYork2.Level3.net                     20840.316ms 
12:  ae-1-100.ebr2.newyork2.level3.net                   20538.333ms asymm 11 
15:  ae-3-3.car2.toronto2.level3.net                     17067.569ms asymm 14 
16:  peer-1-netw.car2.toronto2.level3.net                11363.128ms 
16:  peer-1-netw.car2.toronto2.level3.net                14370.736ms 
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
