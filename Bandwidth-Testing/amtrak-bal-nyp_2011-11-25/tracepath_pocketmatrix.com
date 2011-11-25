$ tracepath pocketmatrix.com
 1:  10.81.40.87                                           0.193ms pmtu 1500
 1:  10.81.40.1                                            2.474ms 
 1:  10.81.40.1                                            9.704ms 
 2:  10.81.40.1                                            7.071ms pmtu 1350
 2:  192.168.16.254                                      209.698ms 
 3:  172.16.221.252                                      352.139ms 
 2:  192.168.22.254                                      11594.270ms 
 4:  70.42.157.253                                       793.894ms 
 5:  216.52.127.96                                       207.710ms 
 4:  70.42.157.253                                       14014.304ms 
 5:  core3.te4-1-bbnet1.wdc002.pnap.net                  11299.201ms 
 6:  ash-bb1-link.telia.net                              214.847ms asymm  7 
 6:  ash-bb1-link.telia.net                              1395.924ms asymm  7 
 7:  level3-ic-130870-ash-bb1.c.telia.net                272.197ms asymm  9 
 8:  vlan60.csw1.Washington1.Level3.net                  479.913ms asymm  9 
 9:  ae-62-62.ebr2.Washington1.Level3.net                126.446ms asymm 10 
10:  ae-5-5.ebr2.Washington12.Level3.net                 152.365ms 
11:  no reply
12:  ae-2-52.edge4.Chicago2.Level3.net                   207.215ms asymm 10 
11:  ae-6-6.ebr2.Chicago2.Level3.net                     4317.979ms asymm 12 
11:  ae-6-6.ebr2.chicago2.level3.net                     6491.494ms asymm 12 
11:  ae-6-6.ebr2.chicago2.level3.net                     5492.581ms asymm 12 
 5:  core3.te4-1-bbnet1.wdc002.pnap.net                  24118.893ms 
13:  WiredTree.edge4.Chicago2.Level3.net                 154.176ms asymm 11 
14:  vl38.dsw3.chi2.wiredtree.com                        191.990ms asymm 11 
15:  96.30.18.81                                         302.983ms asymm 12 
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
