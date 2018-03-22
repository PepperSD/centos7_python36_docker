FROM centos:latest
ENV SUDOFILE /etc/sudoers
RUN yum -y update
RUN yum -y groupinstall "Development Tools"
RUN yum -y install \
           kernel-devel \
           openssh-server \
           openssh-clients \
           passwd \
           sudo \
           kernel-headers \
           gcc-c++ \
           patch \
           libyaml-devel \
           libffi-devel \
           autoconf \
           automake \
           make \
           libtool \
           bison \
           tk-devel \
           zip \
           wget \
           tar \
           gcc \
           zlib \
           zlib-devel \
           bzip2 \
           bzip2-devel \
           readline \
           readline-devel \
           sqlite \
           sqlite-devel \
           openssl \
           openssl-devel \
           git \
           gdbm-devel \
           python-devel
RUN yum -y install http://yum.puppetlabs.com/puppetlabs-release-pc1-el-7.noarch.rpm
RUN yum -y install puppet-agent hostname ansible
# Add vagrant user and key
RUN yum -y install sudo
RUN useradd --create-home -s /bin/bash vagrant
RUN echo -n 'vagrant:vagrant' | chpasswd
RUN echo 'vagrant ALL = NOPASSWD: ALL' > /etc/sudoers.d/vagrant
RUN \
      # we permit sshd to be started
      rm -f /etc/service/sshd/down && \
      # we activate empty password with ssh (to simplify login \
      # as it's only a dev machine, it will never be used in production (right?) \
      echo 'PermitEmptyPasswords yes' >> /etc/ssh/sshd_config && \
      echo 'PasswordAuthentication yes' >> /etc/ssh/sshd_config && \
      mkdir -p /home/vagrant/.ssh && \
      chown -R vagrant:vagrant /home/vagrant/.ssh && \
      # Enable password-less sudo for all user (including the 'vagrant' user) \
      chmod u+w ${SUDOFILE} && \
      echo '%sudo   ALL=(ALL:ALL) NOPASSWD: ALL' >> ${SUDOFILE} && \
      chmod u-w ${SUDOFILE}
RUN rpm -ivh http://nginx.org/packages/centos/7/noarch/RPMS/nginx-release-centos-7-0.el7.ngx.noarch.rpm
RUN yum -y update nginx-release-centos
RUN yum -y --enablerepo=nginx install nginx
RUN yum -y install -y https://centos7.iuscommunity.org/ius-release.rpm
RUN yum -y install python36u python36u-libs python36u-devel python36u-pip
RUN export PATH=~/.local/bin:$PATH
RUN ln -fs /usr/bin/pip3.6 usr/local/bin/pip
RUN alias pip="/usr/bin/pip3.6"
RUN pip install --upgrade pip
RUN pip install --upgrade setuptools
RUN pip install ansible
RUN pip install tox
RUN pip install readline
RUN pip install virtualenv
RUN rm -f /etc/service/sshd/down
RUN systemctl enable sshd.service
CMD ["/usr/sbin/init"]
