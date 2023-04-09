#!/bin/bash

install_packages()
{
    mount /dev/sd0 /mnt
    dpkg /mnt/*
    umount /mnt
}

create_iso_package()
{
    #loop whith reading iso_create
    mkdir /tmp/iso
    cp /var/cache/apt/archives/net-tools.deb /tmp/iso/net-tools.deb
    cp /var/cache/apt/archives/bird.deb /tmp/iso/bird.deb
    cp /var/cache/apt/archives/bird-bgp.deb /tmp/iso/bird-bgp.deb
    cp /var/cache/apt/archives/lldpd.deb /tmp/iso/lldpd.deb
    tar #дописать
}

create_users()
{
    useradd $USER -m -g sudo -s /bin/bash; echo $USER:$USER | chpasswd
}

create_ssh_keys()
{
    #if I understood task correctly
    mkdir /home/$USER/.ssh
    #ssh-keygen -f /home/$USER/.ssh/id_rsa
    echo ./user_keys/$USER/id_rsa.pub >> /home/$USER/.ssh/authorized_keys
}

 add_admini_sudo()
 {
    usermod -aG sudo admini
 }

restrict_login_password()
{
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config
    systemctl restart ssh
}

add_rsa_pub()
{
    mkdir /home/admini/.ssh
    echo ./rsa_pub >> /home/admini/.ssh/authorized_keys
}

no_more_root_login()
{
    sed -i 's|/root:/bin/bash|/root:/sbin/nologin|g' /etc/passwd
}

add_second_disk()
{
    pvcreate /dev/sdb
    vgextend vgKVM /dev/sdb
}
echo "You need to insert first iso with utils into CDROM"
echo "Press any key to continue after inserting disk"
read
install_packages
echo "You need to insert second iso with utils into CDROM"
echo "Press any key to continue after inserting disk"
install_packages
add_admini_sudo
add_rsa_pub
echo "Please check ssh login with rsa"
echo "Login successful? (y/n)"
read LOGIN_DECISION
if [ LOGIN_DECISION -eq "n" ]
then
    echo "Aborting installation"
    exit 1
fi
create_users
