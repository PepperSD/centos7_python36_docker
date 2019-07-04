FROM centos:centos7
ENV container docker
ENV PYTHON_VERSION "3.6.5"
ENV SUDOFILE /etc/sudoers
ENV nginxversion="1.16.0-1" \
    os="centos" \
    osversion="7" \
    elversion="7"
RUN yum -y install \
           https://rpm.nodesource.com/pub_10.x/el/7/x86_64/nodesource-release-el7-1.noarch.rpm \
           https://download.postgresql.org/pub/repos/yum/reporpms/EL-7-x86_64/pgdg-redhat-repo-latest.noarch.rpm \
           https://centos7.iuscommunity.org/ius-release.rpm

RUN yum -y install \
           gcc \
           rsyslog \
           libffi-dev \
           libyaml-dev \
           libssl-dev \
           libpython-dev \
           python \
           python-devel \
           python-virtualenv \
           python-setuptools   \
           python-pip \
           aptitude \
           passwd \
           openssh \
           openssh-server \
           openssh-clients \
           sudo \
           wget \
           gcc make \
           openssl-devel \
           sqlite-devel \
           bzip2-devel \
           git \
           freetds-devel \
           nodejs-10.16.0 \
           postgresql10 \
           postgresql10-server \
           openssl \
           dstat \
           sed &&\
           wget http://nginx.org/packages/$os/$osversion/x86_64/RPMS/nginx-$nginxversion.el$elversion.ngx.x86_64.rpm &&\
           rpm -iv nginx-$nginxversion.el$elversion.ngx.x86_64.rpm &&\
           curl -L https://toolbelt.treasuredata.com/sh/install-redhat-td-agent3.sh | sh &&\
           rm -f nginx-$nginxversion.el$elversion.ngx.x86_64.rpm

#Install python3.6
RUN yum -y install \
           python36u \
           python36u-libs \
           python36u-devel \
           python36u-pip
RUN pip3.6 install --upgrade pip setuptools ansible virtualenv circus tox &&\
    td-agent-gem install \
                 fluent-plugin-dstat \
                 fluent-plugin-elasticsearch \
                 fluent-plugin-filter_typecast \
                 fluent-plugin-filter-object-flatten \
                 fluent-plugin-grep

## setup sshd and generate ssh-keys by init script
RUN mkdir -p /var/run/sshd &&\
    ssh-keygen -A &&\
    useradd -m -s /bin/bash vagrant &&\
    echo -e "vagrant:vagrant" | (passwd --stdin vagrant) &&\
    echo 'vagrant ALL = NOPASSWD: ALL' > /etc/sudoers.d/vagrant &&\
    chmod 440 /etc/sudoers.d/vagrant &&\
    mkdir -p /home/vagrant/.ssh &&\
    chmod 700 /home/vagrant/.ssh

ADD https://raw.githubusercontent.com/hashicorp/vagrant/master/keys/vagrant.pub /home/vagrant/.ssh/authorized_keys
ADD run.sh /home/vagrant/run.sh
RUN chmod 600 /home/vagrant/.ssh/authorized_keys &&\
    chown -R vagrant:vagrant /home/vagrant/.ssh &&\
    chmod u+w ${SUDOFILE} &&\
    echo '%sudo   ALL=(ALL:ALL) NOPASSWD: ALL' >> ${SUDOFILE} &&\
    chmod u-w ${SUDOFILE} &&\
    localedef -f UTF-8 -i ja_JP ja_JP.utf8 &&\
    chmod +x /home/vagrant/run.sh &&\
    /home/vagrant/run.sh
VOLUME [ "/sys/fs/cgroup" ]
ENTRYPOINT ["/usr/sbin/sshd", "-D"]
