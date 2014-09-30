FROM debian:wheezy
MAINTAINER Philipp Schrader <philipp.schrader@gmail.com>

RUN echo LANG=C >> /etc/profile

RUN apt-get update
RUN apt-get -y install openssh-server
RUN apt-get -y install tmux

RUN mkdir -p /var/run/sshd
#ADD sshd_config /etc/ssh/sshd_config

RUN adduser --system --group --shell /usr/bin/guest-login

CMD ["/usr/sbin/sshd", "-D"]
EXPOSE 22
