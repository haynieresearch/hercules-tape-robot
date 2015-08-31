#!/bin/bash
#**********************************************************
#* CATEGORY    APPLICATIONS                               
#* GROUP       MAINFRAME                                  
#* AUTHOR      LANCE HAYNIE <LHAYNIE@HAYNIEMAIL.COM>       
#* DATE        2015-08-28                                  
#* PURPOSE     TAPE ROBOT                      
#**********************************************************
#* MODIFICATIONS                                           
#* 2015-08-28 - LHAYNIE - INITIAL VERSION                  
#**********************************************************

#**********************************************************
# GLOBAL VARIABLES/INCLUDES/MISC
#**********************************************************
source conf/config.cfg

pid=$$
space="+" #This is important, I tried an actual space as well as %20... Both don't work!
cmdurl="http://$hostserver:$hercport/cgi-bin/tasks/syslog?command="
herccmd="devinit"
pgmname="Hercules Tape Robot"
pgmver="0.0.1"

#Send some info to the syslog
logger $pgmname" v"$pgmver" Initializing"
logger $pgmname" v"$pgmver" Process ID: "$pid
logger $pgmname" v"$pgmver" Mainframe Host: "$hostserver
logger $pgmname" v"$pgmver" Socket Port: "$socketport

#**********************************************************
# GLOBAL FUNCTIONS
#**********************************************************

headerRow (){
echo -e "\e[31m-------------------------------------------------------------------------------\e[0m"
}

header () {
clear      
               
echo -e $pgmname
echo -e "Version.....: \e[34m"$pgmver"\e[0m"
echo -e "Process ID..: \e[34m"$pid"\e[0m"
echo -e "Host Server.: \e[34m"$hostserver"\e[0m"
echo -e "Console Port: \e[34m"$socketport"\e[0m"
echo "Press Q at anytime to exit"
headerRow
echo "Waiting for instructions..."
}	

#Small function to echo and log at the same time
message () {
	echo -e $1

	#I prefix the logger so its easy to find
	logger $pgmname" v"$pgmver" "$1
}

#Function to send devinit commands to Hercules
devinit () {
header

#I am fond of printing informational messages...
echo ""
message "Tape Robot Received Command \e[31m"$1"\e[0m"
message "Address Requested: \e[31m"$addr"\e[0m"
message "Volume Requested.: \e[31m"$vol"\e[0m"
message "Tape Directory...: \e[31m"$tapedir"\e[0m"
echo "-------------------------------------------"

if [[ ! -f $tapedir$vol$ext ]]; then
	message "\e[93mOops, volume \e[31m"$vol"\e[0m\e[93m does not exist!\e[0m"
	message "Creating new tape volume: \e[31m"$vol"\e[0m"
	echo "-------------------------------------------"
	hetinit -i $tapedir$vol$ext $vol >/dev/null 2>&1
fi

#Setup command to be sent to Hercules
cmd=$cmdurl$herccmd$space$addr$space$tapedir$vol$ext

#Use Lynx to send command
lynx -dump "$cmd" >/dev/null 2>&1
message "Device intilization command sent!"
sleep 5 
header
}

#Check to see if the socket is open yet
while true; do
	nc $hostserver $socketport < /dev/null
	if [ $? -eq 0 ]; then
		break
	fi
	sleep 1
	clear
	echo "Waiting for Hercules socket..."
done

#Open up the socket to the mainframe printer
exec 3<>/dev/tcp/$hostserver/$socketport

#Just incase I need it, create a pid file
echo $pid > /tmp/taperobot.pid

#**********************************************************
# MAIN PROGRAM
#**********************************************************
header

#Start the primary loop!
while true;
	do

		read -t 1 -n 1 key
		if [[ $key = q ]] || [[ $key = Q ]]; then
			echo ""
			echo ""
			message "Tape Robot Received Shutdown Command..." 
			echo ""
			echo ""
			break
			fi
		#Here we read from the console
		if read line <&3; then

			#Log console messages
			logger $pgmname" v"$pgmver" Console message: "$line	

			#If the first char of the console line is I, do something
			if [[ "${line:0:1}" == 'I' ]]; then

				#Setup the message codes, and potential addr and vol
				msgcode1=${line:0:7}
				msgcode2=${line:8:1}
				addr=${line:10:4}
				vol=${line:15:6}
			fi

			#Same as what we did for I, just for an *
			if [[ "${line:0:1}" == '*' ]]; then

				#Same as above, just +1 (think about it...)
				msgcode1=${line:1:7}
				msgcode2=${line:9:1}
				addr=${line:11:4}
				vol=${line:16:6}
			fi

			#If the message code is a command for tape, start doing stuff!
			if [[ "$msgcode1" == 'IEF233A' && "$msgcode2" == 'M' ]]; then
				devinit $msgcode1
			fi
	
			if [[ "$msgcode1" == 'IEF233D' && "$msgcode2" == 'M' ]]; then
				devinit $msgcode1		
			fi
	
			if [[ "$msgcode1" == 'IEC501A' && "$msgcode2" == 'M' ]]; then
				devinit $msgcode1
			fi

			#Shutdown the tape robot after a EOD command has been sent	
			if [[ "${line:0:16}" == 'IEE334I HALT EOD' ]]; then
				message "Tape Robot Received Shutdown Command..."
				break
			fi
		fi
	done
message "Tape Robot Terminating..."
rm -f /tmp/taperobot.pid
exit 1
