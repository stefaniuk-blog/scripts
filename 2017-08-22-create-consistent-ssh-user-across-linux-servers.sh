#!/bin/bash

id=1000
username="dan"
password="s3cr3t"
ssh_pk="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDGA++RFH4MfQ+697dSNS+p2Hx0a4X56pnDrMIbDozYUPcbY6rictsJvsakaF2yMlR9xW0nEWichdwB5dFxoVQ9E6n6ygRB5Q88j+SOsvVA+wjCJ0+Ittfrb9/dTrnuSWT58p1HKaCDOJdx402P41DZGw4Fq+JKTEvP+H0AbOdUifNMrZBPZ0kOv/0bNT839ytI6rKGi+3w42TN37k7H02TmAFPnip3YpLrUMNxMHulxyzaQ2ueAILGmPac2pz6hU6OflSCkptiV7yDYv/LnjFDSzagFP0dIr5jkT+XenpJOXgdXA/g3/4aOUHfo9tEQngC9ANKbaB3pRwAfGM35V35 my-key"

uname=$(grep $id /etc/passwd | cut -f1 -d:)
gname=$(grep $id /etc/group | cut -f1 -d:)
ps -o pid -u $uname | xargs kill -9
if [ -n "$uname" ]; then
    usermod -u 1111 $uname
    find / -user $id -exec chown -h 1111 {} \;
fi
if [ -n "$gname" ]; then
    groupmod -g 1111 $gname
    find / -group $id -exec chgrp -h 1111 {} \;
fi

groupadd -g $id $username
useradd -m -s /bin/bash -u $id -g $username -G sudo,docker $username
echo "$username:$password" | chpasswd

mkdir -p /home/$username/.ssh
echo "$ssh_pk" >> /home/$username/.ssh/authorized_keys
chmod 600 /home/$username/.ssh/authorized_keys
chown -R $username:$username /home/$username

echo "$username ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/$username

sed -i "s/^PasswordAuthentication yes/#PasswordAuthentication yes/g" \
    /etc/ssh/sshd_config
