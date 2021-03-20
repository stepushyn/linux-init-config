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
read -p "Enter pub key: " pubkey
echo "$pubkey" > /home/$username/.ssh/authorized_keys
echo -e "\nPub key saved to authorized_keys \n"



# Change access rights
chmod -R go= /home/$username/.ssh/
chown -R $username:$username /home/$username/.ssh/
echo -e "Access rights changed \n"


mv /etc/ssh/sshd_config /etc/ssh/sshd_config.old
cp $(pwd)/sshd_config /etc/ssh/sshd_config
echo "" >> /etc/ssh/sshd_config


read -p "Enter SSH port: " port
echo "Port $port" >> /etc/ssh/sshd_config
systemctl restart sshd
