#Скрипт находится в разработке. Подразумевается, что настройка машины от и до будет выполнена с помощью данного скрипта
#На сервер копируются файлы installing.sh rsa_pub users и дериктория user_keys

#!/bin/bash

install_packages()
{
    mount /dev/sd0 /mnt
    dpkg /mnt/*
    umount /mnt
}

create_users()
{
    useradd $USER -m -g admin -s /bin/bash; echo $USER:$USER | chpasswd
}

create_ssh_keys()
{
    #if I understood task correctly
    mkdir /home/$USER/.ssh
    cat ./user_keys/$USER/id_rsa.pub >> /home/$USER/.ssh/authorized_keys
}

add_admin_group_sudoers()
{
    echo '%admin ALL=(ALL:ALL) ALL' >> /etc/sudoers
}

 add_admini_role()
 {
    usermod -aG admin admini
 }

restrict_login_password()
{
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config
    sed -i 's/PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config
    systemctl restart ssh
}

add_rsa_pub()
{
    mkdir /home/admini/.ssh
    cat ./rsa_pub >> /home/admini/.ssh/authorized_keys
}

no_more_root_login()
{
    sed -i 's|PermitRootLogin yes|PermitRootLogin no|g' /etc/ssh/sshd_config
}

add_second_disk()
{
    pvcreate /dev/sdb
    vgextend vgKVM /dev/sdb
}

iptables_rules()
{
    iptables -A INPUT -s 192.168.0.0/16 -j ACCEPT
    iptables -A INPUT -p tcp --dport 22 -m state --state NEW -j ACCEPT
    iptables -A INPUT -p icmp --icmp-type 8 -j REJECTiptables -A INPUT -s 11.22.121.0/24 -j REJECT
    iptables-save
}

make_log_dir()
{
    mkdir /var/log/customlogs
}

only_4096_connections()
{
    echo "net.netfilter.nf_conntrack_max=4096" >> /etc/sysctl.conf
    sysctl -p
}

echo "------------------------"
echo "Welcome to setup script!"
echo "------------------------"
mkdir /sbin
echo "You need to insert first iso with utils into CDROM"
echo "Press any key to continue after inserting disk"
read
install_packages
echo "You need to insert second iso with utils into CDROM"
echo "Press any key to continue after inserting disk"
install_packages
add_admin_group_sudoers
add_admini_role
no_more_root_login
add_rsa_pub
echo "Please check ssh login with rsa"
echo "Login successful? (y/n)"
read LOGIN_DECISION
if [ LOGIN_DECISION -eq "n" ]
then
    echo "Aborting installation"
    exit 1
fi
restrict_login_password
create_users
create_ssh_keys
iptables_rules
only_4096_connections
systemctl restart ssh