#!/bin/bash


node="server"
redirector_hostname=""
if [[ $(hostname -s) = *mn ]]; then
    echo "This machie is a \"Master Node\".\nSetup the node as XrootD redirector."
    node="redirector"
else
    echo "This machie is a \"Work Node\".\nSetup the node as XrootD server."
    node="server"
fi


hostname=`hostname -s`
redirector_hostname=${hostname/wn*/mn}

### Common 

## No longer to download xrootd repository if the epel release is installed, but
#sudo yum install -y epel-release
sudo wget http://xrootd.org/binaries/xrootd-stable-slc7.repo -P /etc/yum.repos.d/

## Package Installation.
sudo yum install -y xrootd
sudo yum install -y git

sudo groupmod -g 1094 xrootd
sudo usermod -u 1094 -g 1094 xrootd

## Firewall Setting.
sudo systemctl restart firewalld
sudo firewall-cmd --permanent --add-port=1094/tcp
sudo firewall-cmd --permanent --add-port=3121/tcp
sudo firewall-cmd --reload


## Create xrootd configuration file.
if [ "$node" == "redirector" ]; then
cat << EOF > /tmp/xrootd-myconf.cfg
all.export /data
set xrdr=${redirector_hostname}
all.manager \$(xrdr) 3121
all.role manager
EOF
else 
cat << EOF > /tmp/xrootd-myconf.cfg
all.export /data
set xrdr=${redirector_hostname}
all.manager \$(xrdr) 3121
all.role server
cms.space min 200m 500m
EOF
fi

## Copy the conf file to /etc/xrootd
sudo cp /tmp/xrootd-myconf.cfg /etc/xrootd

## Prepare mounting point.
sudo mkdir /data
sudo touch /data/${hostname}
sudo chown -R xrootd.xrootd /data

## Start the services.
sudo systemctl start cmsd@myconf.service
sudo systemctl start xrootd@myconf.service

## Install the client packages.
sudo yum install -y xrootd-fuse xrootd-client

if [ "${node}" == "redirector" ]; then
    sudo mkdir /xrootdfs
    sudo chown xrootd.xrootd /xrootdfs
    sudo xrootdfs -o rdr=root://${redirector_hostname}:1094//data,uid=xrootd /xrootdfs
fi
