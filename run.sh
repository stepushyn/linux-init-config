#! /bin/bash

# Create a new user
read -p "Enter username: " username
sudo adduser "$username" -q --gecos ""
echo "New user created"



# Add a new user to the sudo group
usermod -aG sudo $username
echo "User added to sudo group"



# Create a .ssh folder
if [ ! -d "/home/$username/.ssh" ]
then
	mkdir /home/$username/.ssh
	echo ".ssh folder created"
fi



# Writing the public key to authorized_keys
read -p "Add a public key? (y/n) " pubkey
if [[ $pubkey = "y" || $pubkey = "Y" ]]
then
	read -p "Enter pub key: " pubkey
	echo "$pubkey" > /home/$username/.ssh/authorized_keys
	echo "Pub key saved to authorized_keys"
fi



# Change access rights
chmod -R go= /home/$username/.ssh/
chown -R $username:$username /home/$username/.ssh/
echo "Access rights changed"


###################################
# SSH config
###################################
if [ ! -d "/etc/ssh/sshd_config.d" ]
then
	mkdir /etc/ssh/sshd_config.d
fi



read -p "Ban root login (y/n) " rootlogin
if [[ $rootlogin = "y" || $rootnogin = "Y" ]]
then
	echo "PermitRootLogin no" > /etc/ssh/sshd_config.d/my-config.conf
	echo "Root login banned"
fi



read -p "Ban password Authentication (y/n) " passwordauth
if [[ $passwordauth = "y" || $passwordauth = "Y" ]]
then
	echo "PasswordAuthentication no" >> /etc/ssh/sshd_config.d/my-config.conf
	echo "Password Authentication banned"
fi



read -p "Enter SSH port (default 22): " port
if [ $port -ne 22 ]
then
	echo "Port $port" >> /etc/ssh/sshd_config.d/my-config.conf
	echo "SSH port changed to $port"
fi



read -p "Restart SSH daemon? (y/n) " restartssh
if [[ $restartssh = "y" || $restartssh = "Y" ]]
then
	systemctl restart sshd
	echo "SSH restarted"
fi


####################################
# UFW configuration
####################################
ufw allow $port



read -p "Ban IPv6? (y/n) " banipv6
if [[ $banipv6 = "y" || $banipv6 = "Y" ]]
then
	sed -i -e 's/IPV6=yes/IPV6=no/g' /etc/default/ufw
fi



read -p "Enable UFW? (y/n) " enableufw
if [[ $enableufw = "y" || $enableufw = "Y" ]]
then
	ufw enable
	echo "UFW enabled"
fi



# to do:
#
# ufw config & enable
# ban ipv6
# apt update & upgrade
# apt-get install -y mc htop tree net-tools
# запит дозволів (перезагрузити ssh?)
# http://wiki.metawerx.net/wiki/LBSA
# https://www.digitalocean.com/community/tutorials/automating-initial-server-setup-with-ubuntu-18-04

# https://ostechnix.com/ubuntu-server-secure-script-secure-harden-ubuntu/
