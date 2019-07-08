FROM centos:7.6.1810
ENV container docker
ENV PYTHON_VERSION "3.6.5"
ENV SUDOFILE /etc/sudoers
ENV nginxversion="1.16.0-1" \
    os="centos" \
    osversion="7" \
    elversion="7"

RUN yum update -y &&\
    yum -y install \
           https://rpm.nodesource.com/pub_10.x/el/7/x86_64/nodesource-release-el7-1.noarch.rpm \
           https://download.postgresql.org/pub/repos/yum/reporpms/EL-7-x86_64/pgdg-redhat-repo-latest.noarch.rpm \
           https://centos7.iuscommunity.org/ius-release.rpm \
           http://nginx.org/packages/centos/7/noarch/RPMS/nginx-release-centos-7-0.el7.ngx.noarch.rpm \
           gcc \
           systemd \
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
           openssl \
           dstat \
           sed &&\
           yum clean all


RUN yum -y install \
           nodejs-10.16.0 \
           nginx \
           python36u \
           python36u-libs \
           python36u-devel \
           python36u-pip \
           postgresql10 \
           postgresql10-server &&\
           curl -L https://toolbelt.treasuredata.com/sh/install-redhat-td-agent3.sh | sh &&\
            yum clean all &&\
            (cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == systemd-tmpfiles-setup.service ] || rm -f $i; done); \
            rm -f /lib/systemd/system/multi-user.target.wants/*;\
            rm -f /etc/systemd/system/*.wants/*;\
            rm -f /lib/systemd/system/local-fs.target.wants/*; \
            rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
            rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
            rm -f /lib/systemd/system/basic.target.wants/*;\
            rm -f /lib/systemd/system/anaconda.target.wants/*;

RUN pip3.6 install --upgrade pip setuptools ansible virtualenv circus tox passlib &&\
    td-agent-gem install \
                 fluent-plugin-dstat \
                 fluent-plugin-elasticsearch \
                 fluent-plugin-filter_typecast \
                 fluent-plugin-filter-object-flatten \
                 fluent-plugin-aliyun-odps \
                 fluent-plugin-grep &&\
    systemctl enable \
              nginx \
              rsyslog \
              td-agent

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
ENTRYPOINT ["/usr/sbin/sshd"]
CMD ["-D"]
