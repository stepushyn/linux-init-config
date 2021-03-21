#! /bin/bash

# Create a new user
echo ""
read -p "Enter username: " username
sudo adduser "$username" -q --gecos ""
echo -e "\nNew user created \n"



# Add a new user to the sudo group
usermod -aG sudo $username
echo -e "User added to sudo group \n"



# Create a .ssh folder
if [ ! -d "/home/$username/.ssh" ]
then
	mkdir /home/$username/.ssh
	echo -e ".ssh folder created \n"
fi



# Writing the public key to authorized_keys
read -p "Add a public key? (y/n) " pubkey
if [[ $pubkey = "y" || $pubkey = "Y" ]]
then
	read -p "\nEnter pub key: " pubkey
	echo "$pubkey" > /home/$username/.ssh/authorized_keys
	echo -e "\nPub key saved to authorized_keys \n"
fi



# Change access rights
chmod -R go= /home/$username/.ssh/
chown -R $username:$username /home/$username/.ssh/
echo -e "Access rights changed \n"


###################################
# SSH config
###################################
read -p "\nBan root login (y/n) " rootlogin
if [[ $rootlogin = "y" || $rootnogin = "Y" ]]
then
	echo -e "PermitRootLogin no\n" > /etc/ssh/sshd_config.d/my-config.conf
	echo -e "\nRoot login banned"
fi


read -p "\nBan password Authentication (y/n)" passwordauth
if [[ $passwordauth = "y" || $passwordauth = "Y" ]]
then
	echo -e "PasswordAuthentication no\n" >> /etc/ssh/sshd_config.d/my-config.conf
	echo -e "Password Authentication banned"
fi


read -p "\nChange SSH port? (y/n) " port
if [[ $port = "y" || $port = "Y" ]]
then
	read -p "Enter SSH port (default 22): " port
	echo "Port $port" >> /etc/ssh/sshd_config.d/my-config.conf
	echo -e "SSH port changed to $port"
fi


read -p "Restart SSH daemon? (y/n) " restart
if [[ $restart = "y" || $restart = "Y" ]]
then
	systemctl restart sshd
	echo -e "\nSSH restarted \n"
fi


####################################
# UFW configuration
####################################
ufw allow $port
read -p "\nBan IPv6? (y/n) " banipv6
if [[ $banipv6 = "y" || $banipv6 = "Y" ]]
then
	cp /etc/default/ufw /etc/default/ufw.old
	cp ufw_ipv6_no /etc/default/ufw
fi

read -p "\nEnable UFW? (y/n) " enableufw
if [[ $enableufw = "y" || $enableufw = "Y" ]]
then
	ufw enable
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
