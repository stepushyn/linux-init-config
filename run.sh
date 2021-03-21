#! /bin/bash


###################################
# Create a new user
###################################
read -p "Enter username: " username

read -p "Copy password from root? " copypassword
if [[ $copypassword = "y" || $copypassword = "Y" ]]
then
	password="$(grep root /etc/shadow | cut --delimiter=: --fields=2)"
	adduser $username --quiet --disabled-password --gecos ""
	usermod -aG sudo $username
	echo "$username:$password" | chpasswd --encrypted 

else
	adduser $username --quiet --gecos ""
	usermod -aG sudo $username
fi

echo "User creted and added to sudo group"



###################################
# SSH config
###################################

# Create a .ssh folder
if [ ! -d "/home/$username/.ssh" ]
then
	mkdir /home/$username/.ssh
	echo ".ssh folder created"
fi



read -p "Copy root pub key to user authorized_keys (y/n) " rootkey
if [[ $rootkey = "y" || $rootkey = "Y" ]]
then
	cp /root/.ssh/authorized_keys /home/$username/.ssh/authorized_keys
	echo "Root pub key copied"
fi



read -p "Add a new pub key? (y/n) " pubkey
if [[ $pubkey = "y" || $pubkey = "Y" ]]
then
	read -p "Enter pub key: " pubkey
	echo "$pubkey" >> /home/$username/.ssh/authorized_keys
	echo "Pub key saved to authorized_keys"
fi



# Change access rights to .ssh
chmod -R go= /home/$username/.ssh/
chown -R $username:$username /home/$username/.ssh/
echo "Access rights changed"



# Create a dir for SSH config
if [ ! -d "/etc/ssh/sshd_config.d" ]
then
	mkdir /etc/ssh/sshd_config.d
fi



read -p "Ban root login (y/n) " rootlogin
if [[ $rootlogin = "y" || $rootnogin = "Y" ]]
then
	echo "PermitRootLogin no" > /etc/ssh/sshd_config.d/my-config.conf
	passwd --lock root
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



# https://www.digitalocean.com/community/tutorials/automating-initial-server-setup-with-ubuntu-18-04

