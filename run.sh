#!/bin/bash
set -e

echo $PUB_KEY >> /home/vagrant/.ssh/authorized_keys
chown -R vagrant:vagrant /home/vagrant/.ssh/authorized_keys; chmod 600 /home/vagrant/.ssh/authorized_keys

mkdir -p /root/.ssh
echo $PUB_KEY >> /root/.ssh/authorized_keys
chown -R root:root /root/.ssh/authorized_keys; chmod 600 /root/.ssh/authorized_keys
sed -i -e '/$ModLoad imjournal/s/^/#/' /etc/rsyslog.conf
sed -i -e 's/$OmitLocalLogging on/$OmitLocalLogging off/' /etc/rsyslog.conf
sed -i -e '/$IMJournalStateFile/s/^/#/' /etc/rsyslog.conf
sed -i -e '/$SystemLogSocketName/s/^/#/' /etc/rsyslog.d/listen.conf
sed -i -r 's/TD_AGENT_USER=td-agent/TD_AGENT_USER=root/' /etc/init.d/td-agent
sed -i -r 's/TD_AGENT_GROUP=td-agent/TD_AGENT_GROUP=root/' /etc/init.d/td-agent
