FROM centos:centos7
ENV SUDOFILE /etc/sudoers
RUN yum -y swap -- remove fakesystemd -- install systemd systemd-libs initscripts
RUN yum -y update; yum clean all; \
(cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == systemd-tmpfiles-setup.service ] || rm -f $i; done); \
rm -f /lib/systemd/system/multi-user.target.wants/*;\
rm -f /etc/systemd/system/*.wants/*;\
rm -f /lib/systemd/system/local-fs.target.wants/*; \
rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
rm -f /lib/systemd/system/basic.target.wants/*;\
rm -f /lib/systemd/system/anaconda.target.wants/*;
RUN yum -y groupinstall "Development Tools"
RUN yum -y install \
           kernel-devel \
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
RUN yum -y install openssh-server openssh-clients
RUN mkdir -p /var/run/sshd
RUN ssh-keygen -t rsa -f /etc/ssh/ssh_host_rsa_key -N ''
RUN ssh-keygen -t ed25519 -f /etc/ssh/ssh_host_ed25519_key -N ''
RUN ssh-keygen -f /etc/ssh/ssh_host_ecdsa_key -t ecdsa -N ''
RUN systemctl enable sshd.service
# Add vagrant user and key
RUN yum -y install sudo
RUN rm -f /etc/service/sshd/down
RUN useradd -m -s /bin/bash vagrant
RUN echo -e "vagrant\nvagrant" | (passwd --stdin vagrant)
RUN echo 'vagrant ALL = NOPASSWD: ALL' > /etc/sudoers.d/vagrant
RUN chmod 440 /etc/sudoers.d/vagrant
RUN mkdir -p /home/vagrant/.ssh
RUN chmod 700 /home/vagrant/.ssh
ADD https://raw.githubusercontent.com/hashicorp/vagrant/master/keys/vagrant.pub /home/vagrant/.ssh/authorized_keys
RUN chmod 600 /home/vagrant/.ssh/authorized_keys
RUN chown -R vagrant:vagrant /home/vagrant/.ssh
RUN sed -i -e 's/Defaults.*requiretty/#&/' /etc/sudoers
RUN echo 'PermitEmptyPasswords yes' >> /etc/ssh/sshd_config
RUN echo 'PasswordAuthentication yes' >> /etc/ssh/sshd_config
# Enable password-less sudo for all user (including the 'vagrant' user)
RUN chmod u+w ${SUDOFILE}
RUN echo '%sudo   ALL=(ALL:ALL) NOPASSWD: ALL' >> ${SUDOFILE}
RUN chmod u-w ${SUDOFILE}
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
ENTRYPOINT ["/usr/sbin/sshd", "-D"]
