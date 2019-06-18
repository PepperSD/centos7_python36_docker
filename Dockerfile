FROM centos:centos7
ENV container docker
ENV PYTHON_VERSION "3.6.5"
ENV SUDOFILE /etc/sudoers
ENV nginxversion="1.16.0-1" \
    os="centos" \
    osversion="7" \
    elversion="7"
RUN yum -y install \
           gcc \
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
           freetds-devel
RUN yum install -y https://centos7.iuscommunity.org/ius-release.rpm
RUN yum install -y python36u python36u-libs python36u-devel python36u-pip
RUN pip3.6 install --upgrade pip
RUN pip3.6 install --upgrade setuptools
RUN pip3.6 install ansible
RUN pip3.6 install virtualenv
RUN pip3.6 install circus
RUN pip3.6 install tox

#install nginx
RUN yum install -y wget openssl sed &&\
    yum -y autoremove &&\
    wget http://nginx.org/packages/$os/$osversion/x86_64/RPMS/nginx-$nginxversion.el$elversion.ngx.x86_64.rpm &&\
    rpm -iv nginx-$nginxversion.el$elversion.ngx.x86_64.rpm
RUN rm nginx-$nginxversion.el$elversion.ngx.x86_64.rpm

#Install nodejs
RUN     yum install -y https://rpm.nodesource.com/pub_10.x/el/7/x86_64/nodesource-release-el7-1.noarch.rpm
RUN     yum install -y nodejs-10.16.0
#clear
RUN yum clean all

## setup sshd and generate ssh-keys by init script
RUN mkdir -p /var/run/sshd
RUN ssh-keygen -A
# Add vagrant user and key
RUN useradd -m -s /bin/bash vagrant
RUN echo -e "vagrant:vagrant" | (passwd --stdin vagrant)
RUN echo 'vagrant ALL = NOPASSWD: ALL' > /etc/sudoers.d/vagrant
RUN chmod 440 /etc/sudoers.d/vagrant
RUN mkdir -p /home/vagrant/.ssh
RUN chmod 700 /home/vagrant/.ssh
ADD https://raw.githubusercontent.com/hashicorp/vagrant/master/keys/vagrant.pub /home/vagrant/.ssh/authorized_keys
RUN chmod 600 /home/vagrant/.ssh/authorized_keys
RUN chown -R vagrant:vagrant /home/vagrant/.ssh
# Enable password-less sudo for all user (including the 'vagrant' user)
RUN chmod u+w ${SUDOFILE}
RUN echo '%sudo   ALL=(ALL:ALL) NOPASSWD: ALL' >> ${SUDOFILE}
RUN chmod u-w ${SUDOFILE}
VOLUME [ "/sys/fs/cgroup" ]
# LANG
RUN localedef -f UTF-8 -i ja_JP ja_JP.utf8
ADD run.sh /home/vagrant/run.sh
RUN chmod +x /home/vagrant/run.sh
RUN /home/vagrant/run.sh
ENTRYPOINT ["/usr/sbin/sshd", "-D"]
