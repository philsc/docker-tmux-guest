FROM debian:wheezy
MAINTAINER Philipp Schrader <philipp.schrader@gmail.com>

RUN echo LANG=C >> /etc/profile

RUN DEBIAN_FRONTEND=noninteractive apt-get -yq update
RUN DEBIAN_FRONTEND=noninteractive apt-get -yq upgrade
RUN DEBIAN_FRONTEND=noninteractive apt-get -yq install openssh-server
RUN DEBIAN_FRONTEND=noninteractive apt-get -yq install tmux

RUN adduser --system --group --shell /usr/bin/guest-login guest
RUN passwd -d guest

RUN mkdir -p /var/run/sshd
ADD sshd_config /etc/ssh/sshd_config
ADD guest-login /usr/bin/guest-login

RUN chmod +x /usr/bin/guest-login

CMD ["/usr/sbin/sshd", "-D"]
EXPOSE 22
