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

WORKDIR /usr/local/src
RUN wget -c -t 10 http://files.freeswitch.org/releases/freeswitch/freeswitch-1.6.5.tar.gz
RUN tar -xvzf freeswitch-1.6.5.tar.gz

WORKDIR /usr/local/src/freeswitch-1.6.5

RUN ./rebootstrap.sh
RUN ./configure --enable-core-odbc-support

# enable compile of mod_av, mod_vlc
RUN perl -i -pe 's/#formats\/mod_vlc/formats\/mod_vlc/g' modules.conf
RUN perl -i -pe 's/#applications\/mod_av/applications\/mod_av/g' modules.conf

# Compiling the code
RUN make
RUN make install
RUN make cd-sounds-install cd-moh-install samples

# RUN cp -f ./html5/verto/video_demo/dp/dp.xml /usr/local/freeswitch/conf/dialplan/default/0000_dp.xml

ENV FREESWITCH_PATH /usr/local/freeswitch

# create user 'freeswitch', add it to group 'daemon' and change owner/group right of the freeswitch installation
RUN adduser --gecos "FreeSWITCH Softswitch" --disabled-login --disabled-password --system --ingroup daemon --home ${FREESWITCH_PATH} freeswitch && \
    chown -R freeswitch:daemon ${FREESWITCH_PATH} && \
    chmod -R ug=rwX,o= ${FREESWITCH_PATH} && \
    chmod -R u=rwx,g=rx ${FREESWITCH_PATH}/bin/*

# Create the log file.
RUN touch /usr/local/freeswitch/log/freeswitch.log
RUN chown freeswitch:daemon /usr/local/freeswitch/log/freeswitch.log

EXPOSE 5060/tcp 5060/udp 5080/tcp 5080/udp
EXPOSE 5066/tcp 7443/tcp
EXPOSE 8021/tcp
EXPOSE 64535-65535/udp

# Start the container.
CMD ${FREESWITCH_PATH}/bin/freeswitch -ncwait -nonat && tail -f ${FREESWITCH_PATH}/log/freeswitch.log
