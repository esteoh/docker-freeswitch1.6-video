# ref: https://freeswitch.org/confluence/display/FREESWITCH/Debian+8+Jessie
# ref: https://github.com/ianblenke/docker-freeswitch-video/blob/master/Dockerfile
# ref: https://github.com/BetterVoice/freeswitch-container/blob/master/Dockerfile

FROM debian:8.2
MAINTAINER ESTeoh <esteoh@gmail.com>

RUN perl -pi -e 's/httpredir.debian.org/cloudfront.debian.net/g' /etc/apt/sources.list
RUN apt-get update -y
RUN DEBIAN_FRONTEND=none APT_LISTCHANGES_FRONTEND=none apt-get install -y wget curl git build-essential unixodbc unixodbc-dev

RUN curl http://files.freeswitch.org/repo/deb/debian/freeswitch_archive_g0.pub | apt-key add -
RUN echo "deb http://files.freeswitch.org/repo/deb/freeswitch-1.6/ jessie main" > /etc/apt/sources.list.d/freeswitch.list
RUN apt-get update -y

RUN DEBIAN_FRONTEND=none APT_LISTCHANGES_FRONTEND=none apt-get install -y --force-yes freeswitch-video-deps-most
