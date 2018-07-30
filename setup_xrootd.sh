#!/bin/bash


node="server"
redirector_hostname=""
if [[ $(hostname -s) = *mn ]]; then
    echo "This machie is a \"Master Node\". Setup XrootD redirector."
    node="redirector"
else
    echo "This machie is a \"Work Node\". Setup XrootD server."
    node="server"
fi


hostname=`hostname -s`
redirector_hostname=${hostname/wn*/mn}

### Common 
sudo wget http://xrootd.org/binaries/xrootd-stable-slc7.repo -P /etc/yum.repos.d/
sudo yum install -y xrootd-server
sudo yum install -y git
sudo systemctl start firewalld
sudo firewall-cmd --permanent --add-port=1094/tcp
sudo firewall-cmd --permanent --add-port=3121/tcp
sudo firewall-cmd --reload

if [ "$node" == "redirector" ]; then
echo "all.export /data
set xrdr=${redirector_hostname}
all.manager \$(xrdr) 3121
all.role manager
" > /tmp/xrootd-test.cfg
sudo cp /tmp/xrootd-test.cfg /etc/xrootd
else 
sudo echo "all.export /data
set xrdr=${redirector_hostname}
all.manager \$(xrdr) 3121
all.role server
cms.space min 2g 5G
" > /tmp/xrootd-test.cfg
sudo cp /tmp/xrootd-test.cfg /etc/xrootd
fi

sudo mkdir /data
sudo touch /data/${hostname}
sudo chown -R xrootd.xrootd /data

sudo systemctl start cmsd@test.service
sudo systemctl start xrootd@test.service


sudo yum install -y xrootd-fuse

if [ "$node" == "redirector" ]; then
    sudo mkdir /xrootdfs
    sudo chown xrootd.xrootd /xrootdfs
    sudo xrootdfs -o rdr=root://$redirector_hostname:1094//data,uid=xrootd /xrootdfs
fi
