FROM phusion/baseimage:0.9.11
MAINTAINER needo <needo@superhero.org>
ENV DEBIAN_FRONTEND noninteractive

# Set correct environment variables
ENV HOME /root

# Use baseimage-docker's init system
CMD ["/sbin/my_init"]

# Fix a Debianism of the nobody's uid being 65534
RUN usermod -u 99 nobody
RUN usermod -g 100 nobody

RUN add-apt-repository "deb http://us.archive.ubuntu.com/ubuntu/ trusty universe multiverse" && \
    add-apt-repository "deb http://us.archive.ubuntu.com/ubuntu/ trusty-updates universe multiverse" && \
    apt-get update -q && \
    apt-get upgrade -y

# Install Dependencies
RUN apt-get install -qy python-pip python-dev git-core libssl-dev libxslt1-dev libxslt1.1 libxml2-dev libxml2 libssl-dev libffi-dev

RUN pip install pyopenssl

RUN git clone https://github.com/SickRage/SickRage.git /opt/sickrage

RUN chown nobody:users /opt/sickrage
RUN chmod -R +rw /opt/sickrage

# clean up
RUN apt-get clean && \
rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
/usr/share/man /usr/share/groff /usr/share/info \
/usr/share/lintian /usr/share/linda /var/cache/man && \
(( find /usr/share/doc -depth -type f ! -name copyright|xargs rm || true )) && \
(( find /usr/share/doc -empty|xargs rmdir || true ))

EXPOSE 8081

# Directories
VOLUME ["/config", "/downloads", "/tv"]

# Add edge.sh to execute during container startup
RUN mkdir -p /etc/my_init.d
ADD edge.sh /etc/my_init.d/edge.sh
RUN chmod +x /etc/my_init.d/edge.sh

# Add SickRage to runit
RUN mkdir /etc/service/sickrage
ADD sickrage.sh /etc/service/sickrage/run
RUN chmod +x /etc/service/sickrage/run
