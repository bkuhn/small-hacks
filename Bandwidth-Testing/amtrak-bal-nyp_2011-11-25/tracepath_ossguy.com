$ tracepath ossguy.com
 1:  10.81.40.87                                           0.192ms pmtu 1500
 1:  10.81.40.1                                            2.519ms 
 1:  10.81.40.1                                            4.899ms 
 2:  10.81.40.1                                            3.527ms pmtu 1350
 2:  192.168.19.254                                      179.326ms 
 3:  172.16.221.252                                      1828.013ms 
 3:  172.16.221.252                                      5934.189ms 
 4:  70.42.157.253                                       353.005ms 
 5:  core1.te5-1-bbnet1.wdc002.pnap.net                  972.899ms 
 6:  xe-0-5-0-4.r01.asbnva02.us.bb.gin.ntt.net           302.764ms 
 7:  ae-3.r02.asbnva02.us.bb.gin.ntt.net                 1096.436ms 
 7:  ae-3.r02.asbnva02.us.bb.gin.ntt.net                 836.164ms 
 8:  4.68.63.185                                         644.701ms 
 9:  vlan70.csw2.Washington1.Level3.net                  5500.338ms 
10:  ae-72-72.ebr2.Washington1.Level3.net                250.437ms 
11:  ae-3-3.ebr1.NewYork2.Level3.net                     290.760ms 
12:  ae-1-100.ebr2.NewYork2.Level3.net                   331.546ms asymm 11 
13:  ae-6-6.ebr2.NewYork1.Level3.net                     469.057ms asymm 12 
14:  ae-5-5.car1.Montreal2.Level3.net                    1131.790ms asymm 13 
14:  ae-5-5.car1.montreal2.level3.net                    1155.744ms asymm 13 
16:  singpolyma.net                                      1321.426ms reached
     Resume: pmtu 1350 hops 16 back 54 
