ARG P4_BASEIMAGE=centos:8
FROM $P4_BASEIMAGE AS perforce-base
MAINTAINER Jonas Haberkorn

ENV container docker

# Enabling systemd
# See: https://hub.docker.com/_/centos/
RUN cd /lib/systemd/system/sysinit.target.wants/ && \
	for i in *; do \
		[ $i == systemd-tmpfiles-setup.service ] || rm -vf $i ; \
	done ; \
	rm -vf /lib/systemd/system/multi-user.target.wants/* && \
	rm -vf /etc/systemd/system/*.wants/* && \
	rm -vf /lib/systemd/system/local-fs.target.wants/* && \
	rm -vf /lib/systemd/system/sockets.target.wants/*udev* && \
	rm -vf /lib/systemd/system/sockets.target.wants/*initctl* && \
	rm -vf /lib/systemd/system/basic.target.wants/* && \
	rm -vf /lib/systemd/system/anaconda.target.wants/* && \
	mkdir -p /etc/selinux/targeted/contexts/ && \
	echo '<busconfig><selinux></selinux></busconfig>' > /etc/selinux/targeted/contexts/dbus_contexts

ARG GOSU_VERSION=1.11
ARG S6_OVERLAY_VERSION=1.22.1.0
ARG TINI_VERSION=0.18.0
ARG SYSTEMCTL_GITSHA1=73b5aff2ba6abfd254d236f1df22ff4971d44660


# Update the perforce repo url with the right version (currently using centos 8 so we have '.../rhel/8/x86_64')
# You can find the index of all packages at: https://package.perforce.com/yum/
RUN yum install -y epel-release cronie-anacron tar gzip curl openssl which sudo initscripts at && \
    rpm --import https://package.perforce.com/perforce.pubkey && \
    echo -ne '[perforce]\nname=Perforce\nbaseurl=http://package.perforce.com/yum/rhel/8/x86_64\nenabled=1\ngpgcheck=1\n' > /etc/yum.repos.d/perforce.repo && \
    yum clean all --enablerepo='*' && \
    rm -rf /var/cache/yum

RUN curl -fsSL https://raw.githubusercontent.com/gdraheim/docker-systemctl-replacement/${SYSTEMCTL_GITSHA1}/files/docker/systemctl.py -o /bin/systemctl && \
    curl -fsSL https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-amd64.tar.gz | tar zxf - -C / --keep-directory-symlink --exclude ./usr/bin/execlineb && \
    curl -fsSL https://github.com/krallin/tini/releases/download/v${TINI_VERSION}/tini-amd64 -o /usr/bin/tini && \
    curl -fsSL https://github.com/tianon/gosu/releases/download/${GOSU_VERSION}/gosu-amd64 -o /usr/bin/gosu && \
    chmod +x /bin/systemctl /usr/bin/gosu /usr/bin/tini

ENTRYPOINT ["/init"]


FROM perforce-base AS perforce-server
MAINTAINER Jonas Haberkorn

ARG P4_VERSION=21.1

RUN yum clean all --enablerepo='*' \
    && yum clean metadata --enablerepo='*' \
    && yum install --enablerepo=perforce -y helix-p4d-20${P4_VERSION} helix-cli-20${P4_VERSION} \
    && yum clean all --enablerepo='*' \
    && rm -rf /var/cache/yum


EXPOSE 1666
ENV NAME p4depot
ENV P4CONFIG .p4config
ENV DATAVOLUME /data
ENV P4PORT 1666
ENV P4USER p4admin
VOLUME ["$DATAVOLUME"]

ADD ./p4-users.txt /root/
ADD ./p4-groups.txt /root/
ADD ./p4-protect.txt /root/
ADD ./setup-perforce.sh /usr/local/bin/
ADD ./run.sh  /

CMD ["/run.sh"]
