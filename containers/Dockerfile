FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update \
    && apt-get install --yes --no-install-recommends openssh-server python3 sudo ca-certificates \
    && rm -rf /var/lib/apt/lists/* \
    && groupadd ansible-admins \
    && useradd --create-home --shell /bin/bash --groups ansible-admins ansible \
    && install -d -m 0755 /run/sshd \
    && install -d -o ansible -g ansible -m 0700 /home/ansible/.ssh \
    && printf '%s\n' 'ansible ALL=(root) NOPASSWD: ALL' > /etc/sudoers.d/90-ansible-lab \
    && chmod 0440 /etc/sudoers.d/90-ansible-lab \
    && printf '%s\n' 'PasswordAuthentication no' 'PermitRootLogin no' > /etc/ssh/sshd_config.d/90-container.conf

COPY entrypoint.sh /usr/local/bin/container-entrypoint
RUN chmod 0755 /usr/local/bin/container-entrypoint
EXPOSE 22
ENTRYPOINT ["/usr/local/bin/container-entrypoint"]

