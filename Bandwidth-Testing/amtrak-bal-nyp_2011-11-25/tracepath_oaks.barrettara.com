$ tracepath oaks.barrettara.com
 1:  10.81.40.87                                           0.200ms pmtu 1500
 1:  10.81.40.1                                            3.115ms 
 1:  10.81.40.1                                            3.578ms 
 2:  10.81.40.1                                            3.080ms pmtu 1350
 2:  192.168.17.254                                      111.722ms 
 2:  192.168.16.254                                      6350.082ms 
 3:  172.16.221.252                                      418.449ms 
 4:  70.42.157.253                                       119.249ms 
 5:  core2.te5-1-bbnet1.wdc002.pnap.net                   94.281ms 
 6:  TenGigE0-3-4-0.GW1.IAD8.ALTER.NET                   101.066ms 
 7:  0.xe-3-1-2.XL4.IAD8.ALTER.NET                       273.048ms asymm  8 
 8:  0.ae4.BR1.IAD8.ALTER.NET                            247.758ms asymm  9 
 9:  xe-2-1-0.er2.iad10.us.above.net                     293.280ms 
10:  64.124.196.214.allocated.above.net                  374.779ms asymm 15 
11:  64.71.241.109                                       562.822ms asymm 13 
12:  so-1-0-0.gw02.mtnk.phub.net.cable.rogers.com        647.182ms 
13:  69.63.249.222                                       175.789ms 
14:  69.63.248.61                                        573.451ms 
15:  66.185.91.54                                        401.702ms 
16:  no reply
17:  no reply
18:  no reply
19:  no reply
20:  no reply
21:  no reply
22:  10.81.40.1                                            6.064ms !N
     Resume: pmtu 1350 
