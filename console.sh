#!/bin/bash
#**********************************************************
#* CATEGORY    APPLICATIONS                               
#* GROUP       MAINFRAME                                  
#* AUTHOR      LANCE HAYNIE <LHAYNIE@HAYNIEMAIL.COM>       
#* DATE        2015-08-28                                  
#* PURPOSE     CONSOLE STARTUP & NETWORKING                
#**********************************************************
#* MODIFICATIONS                                           
#* 2015-08-28 - LHAYNIE - INITIAL VERSION
#**********************************************************

#**********************************************************
# GLOBAL VARIABLES/INCLUDES/MISC
#**********************************************************
source conf/config.cfg

pid=$$
echo $pid > /tmp/mainframeconsole.pid

#**********************************************************
# MAIN PROGRAM
#**********************************************************
clear

#Do some networking stuff
echo "1" > /proc/sys/net/ipv4/ip_forward
echo "1" > /proc/sys/net/ipv4/conf/eth0/proxy_arp
echo "1" > /proc/sys/net/ipv4/conf/tun1/proxy_arp
echo "1" > /proc/sys/net/ipv4/conf/tun2/proxy_arp
echo "1" > /proc/sys/net/ipv4/conf/tun3/proxy_arp
echo "1" > /proc/sys/net/ipv4/conf/tun4/proxy_arp

#Add the route so you can access your mainframe
ip route add $mainframeip via $tunnelip >/dev/null 2>&1

#Start a 3270 session to the console
c3270 $hostserver:$consoleport
rm -f /tmp/mainframeconsole.pid
exit 1
