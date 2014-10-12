FROM ubuntu:14.04
MAINTAINER Philipp Schrader <philipp.schrader@gmail.com>

RUN echo LANG=C >> /etc/profile

# Install the necessary software components.
RUN DEBIAN_FRONTEND=noninteractive apt-get -yq update
RUN DEBIAN_FRONTEND=noninteractive apt-get -yq upgrade
RUN DEBIAN_FRONTEND=noninteractive apt-get -yq --no-install-recommends \
    install openssh-server tmux

# Add a guest user that people will use to SSH into the container.
RUN adduser --system --group --shell /usr/bin/guest-login guest
RUN passwd -d guest

# Add necessary run-time folders.
RUN mkdir -p /var/run/sshd
RUN mkdir -p /var/lib/tmux-sessions

# Copy in the appropriate files.
ADD sshd_config /etc/ssh/sshd_config
ADD guest-login /usr/bin/guest-login
RUN chmod +x /usr/bin/guest-login

# Enable standard SSH in the container.
CMD ["/usr/sbin/sshd", "-D"]
EXPOSE 22
