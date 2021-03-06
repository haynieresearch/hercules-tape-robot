# Hercules Tape Robot
You will need to read this section completely before using this script
to ensure that everything works as designed. There is no other documentation
other than this README file. Please note: this script comes with no support.
Furthermore, this script is released under the GNU General Public License v2.0.
License text is provided in the LICENSE file.

### Assumptions
This script makes a couple of assumptions, I will list them below and you can
either update/install what is needed on your system or make the required changes.

* This script will live in the root directory of your host operating system.
* That your configuration file is located in conf/ relative to the script.
* That you have a directory dedicated to emulated tape files.
* You have the logger application to interface with the syslog installed.
* You have the HTTPPORT set to 8081 and with NOAUTH enabled in Hercules.
* You have Lynx installed on your system.
* You have Netcat installed on your system.

Note: I am going to include my current setup and layout as an example. There are
two other scripts (startup.sh and console.sh) that I use for starting up my system
and making sure networking is active. You can use or not use these if you wish, just
take note that some of the variables in the config.cfg file are not applicable to the 
tape robot. Also, I compile my scripts for this with SHC. Not because I want to encrypt them,
as realistically SHC would be a very poor method for encryption. More or less so I avoid 
the bad habit of modifying code that works and breaking things. You will see where I do this in
source/compile.sh.

P.S.: This system is far from perfect, if you make some enhancements or have any ideas please
feel free to share them.

### Setup
#### Step 1
You will need a line printer setup in Hercules to read the mount commands from
your host operating system. This script uses a sockdev printer, and I default my 
port to 1403. You can assign any hardware address that fits your setup, but for 
the purposes of this script we will assume 000E. Place the following text in your 
Hercules configuration file: 
```
"000E	1403	1403 sockdev"
```

#### Step 2
Setup some hardware addresses for your tape, here is what I have in my Hercules
configuration file: 
```
"0580.10	3490	*"
```

#### Step 3
You will need to setup a new console in your host operating system. It will need
to be set to ROUTCODE(3), unless you want a ton of messages sent to your log.
This particular route code will send all the tape messages to the 1403 printer.
In MVS, navigate to your PARMLIB PDS and edit the CONSOL00 member. Here is what I
added to my system:

```
CONSOLE
  DEVNUM(000E)
  NAME(L00E)
  ROUTCODE(3)
  UNIT(1403)
```

#### Step 4
Update and set the configuration file accordingly, here are the variables to set:
```
	hostserver:	this is the server that Hercules is running in. You can set 
			this to your FQDN or localhost in most cases.
	consoleport:	N/A
	hercport:	This is the web port that you set in your Hercules config.
	socketport:	The 1403 line printer port Hercules is set to listen on.
	tapedir:	Should be self explanatory, the directory where your tapes are.
	ext:		The extension the script should expect for your tape files.
	mainframeip:	N/A
	tunnelip:	N/A
	robotdir:	The root directory where the script will live.
	herconifg:	N/A
	hercbin:	N/A
	lparname:	N/A
	logdir:		N/A
```

#### Step 5
Once you have everything configured, you will need to re-IPL your system to enable the
new console. After Hercules is running you can activate the tape robot and give it a try.
Here is how I startup my system so you have an idea of what I am doing:
```
	First:	Login to a terminal session (TTY1) and fire up Hercules
	Second:	Start a second terminal session (TTY2) and get a console connected as my
		primary console.
	Third:	Start a third terminal session (TTY3) and start the tape robot only after
		Hercules is running and can accept connections to the printer port.
	Last:	IPL the system!
```

### Notes
The script is pretty simple in what it does. When it receives a message from the console
mount a tape, it sends a command to Hercules via the integrated web page to mount the VOLSER
at the proper hardware address. If the VOLSER that is requested does not exist, it will
create it on the fly. However, if there are any issues with the emulated tape there is no
way for my script (currently) to let the host operating system know.
	



