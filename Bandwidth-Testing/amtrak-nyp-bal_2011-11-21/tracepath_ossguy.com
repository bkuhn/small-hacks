$ tracepath ossguy.com
 1:  10.74.40.220                                          0.178ms pmtu 1500
 1:  10.74.40.1                                            2.385ms 
 1:  10.74.40.1                                           22.568ms 
 2:  10.74.40.1                                           16.359ms pmtu 1350
 2:  no reply
 3:  172.16.221.252                                      501.911ms 
 2:  192.168.23.254                                      12540.320ms 
 2:  192.168.23.254                                      17482.058ms 
 2:  192.168.20.254                                      24499.958ms 
 4:  70.42.157.253                                       386.983ms 
 5:  216.52.127.96                                       143.709ms 
 6:  ash-bb1-link.telia.net                              195.680ms asymm  7 
 7:  level3-ic-126699-ash-bb1.c.telia.net                166.883ms asymm  9 
 8:  vlan70.csw2.Washington1.Level3.net                  185.287ms asymm  9 
 9:  ae-72-72.ebr2.Washington1.Level3.net                219.990ms asymm 10 
10:  ae-3-3.ebr1.NewYork2.Level3.net                     537.749ms asymm 11 
11:  ae-1-100.ebr2.NewYork2.Level3.net                   235.859ms 
12:  ae-6-6.ebr2.NewYork1.Level3.net                     162.012ms 
13:  ae-5-5.car1.Montreal2.Level3.net                    213.361ms 
14:  te6-2.cl-core05.level3.mtl.iweb.com                 173.836ms asymm 10 
15:  singpolyma.net                                      191.779ms reached
     Resume: pmtu 1350 hops 15 back 54 
