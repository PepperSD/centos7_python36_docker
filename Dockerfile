FROM centos:latest
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
RUN rpm -ivh http://nginx.org/packages/centos/7/noarch/RPMS/nginx-release-centos-7-0.el7.ngx.noarch.rpm
RUN yum -y update nginx-release-centos
RUN yum -y --enablerepo=nginx install nginx
RUN yum -y install -y https://centos7.iuscommunity.org/ius-release.rpm
RUN yum -y install python36u python36u-libs python36u-devel python36u-pip
RUN export PATH=~/.local/bin:$PATH
RUN ln -fs /usr/bin/pip3.6 usr/local/bin/pip
RUN alias pip="/usr/bin/pip3.6"
RUN pip install --upgrade setuptools
RUN pip install ansible
RUN pip install tox
RUN pip install readline
RUN pip install virtualenv
RUN yum -y install initscripts MAKEDEV
RUN sed -ri 's/^#PermitEmptyPasswords no/PermitEmptyPasswords yes/' /etc/ssh/sshd_config
RUN sed -ri 's/^#PermitRootLogin yes/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN sed -ri 's/^UsePAM yes/UsePAM no/' /etc/ssh/sshd_config
RUN useradd vagrant
RUN echo 'vagrant:' | chpasswd
EXPOSE 22
ENTRYPOINT ["/usr/sbin/sshd", "-D"]
