#!/bin/bash
#**********************************************************
#* CATEGORY    APPLICATIONS                               
#* GROUP       MAINFRAME                                  
#* AUTHOR      LANCE HAYNIE <LHAYNIE@HAYNIEMAIL.COM>       
#* DATE        2015-08-28                                  
#* PURPOSE     MAINFRAME INIT WITH NETWORKING AND TAPE ROBOT                    
#**********************************************************
#* MODIFICATIONS                                           
#* 2015-08-28 - LHAYNIE - INITIAL VERSION 
#**********************************************************

#**********************************************************
# GLOBAL VARIABLES/INCLUDES/MISC
#**********************************************************
source conf/config.cfg

pid=$$
echo $pid > /tmp/mainframestart.pid

#**********************************************************
# MAIN PROGRAM
#**********************************************************
clear

#Setup networking, it may not exist but if it does it needs to be removed
ip route delete $mainframeip via $tunnelip >/dev/null 2>&1

#Start up Hercules
$hercbin -f $herconfig > $logdir$lparname."$(date +"%Y.%m.%d-%H%M")".log
rm -f /tmp/mainframestart.pid
exit 1
