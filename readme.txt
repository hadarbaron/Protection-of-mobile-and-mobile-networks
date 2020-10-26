Install Kali on VirtualBox:
1. Install VirtualBox and Extension Pack https://www.virtualbox.org/wiki/Downloads
- Windows hosts
- VM VirtualBox Extension Pack
2. Download Kali VirtualBox OVA Template https://www.offensive-security.com/kali-linux-vmware-virtualbox-image-download/
3. Install Kali VirtualBox OVA Template
4. Run the Kali and login kali/kali
5. Run in terminal:
sudo passwd root
enter kali than new password for root
root/root
6. Logout and login as root/root

Enable .htaccess for apache2 http server:
1. Open /etc/apache2/sites-enabled/000-default.conf and replace to:
<VirtualHost *:80>
	#ServerName www.example.com
	ServerAdmin webmaster@localhost
	DocumentRoot /var/www/html
	# Available loglevels: trace8, ..., trace1, debug, info, notice, warn...
	ErrorLog ${APACHE_LOG_DIR}/error.log
	CustomLog ${APACHE_LOG_DIR}/access.log combined
	# Enable .htaccess for /var/www/html directory and its subdirectories
	 <Directory "/var/www/html">
	 Allowoverride all
	 </Directory>
</VirtualHost>
2. Run in terminal:
sudo a2enmod rewrite

Install fake AP:
1. Copy html folder to var/www/ with replace
2. Open /etc/sudoers and add line:
%www-data ALL=(ALL:ALL) NOPASSWD: /sbin/iptables, /usr/sbin/arp
3. Run in terminal:
chown www-data:www-data ./*
apt update
apt-get install hostapd dnsmasq
4. Done

Start the fake AP bash script:
1. Go to var/www/html folder and open terminal by right click or use in terminal
cd /var/www/html/
2. Run in terminal:
bash ap.sh
3. Config the ap.conf to you network cards
4. You done now you can use it! ;)

* Install wireshark for snipping post, get and other data from http protocol https://www.wireshark.org/download.html