#!/bin/bash
set -e

echo $PUB_KEY >> /home/vagrant/.ssh/authorized_keys
chown -R vagrant:vagrant /home/vagrant/.ssh/authorized_keys; chmod 600 /home/vagrant/.ssh/authorized_keys

mkdir -p /root/.ssh
echo $PUB_KEY >> /root/.ssh/authorized_keys
chown -R root:root /root/.ssh/authorized_keys; chmod 600 /root/.ssh/authorized_keys
