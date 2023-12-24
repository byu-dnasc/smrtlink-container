FROM ubuntu:20.04

ENV SMRT_ROOT=/opt/pacbio/smrtlink
ENV SMRT_USER=smrtanalysis
ENV INSTALL_CMD='su smrtanalysis -c "./smrtlink_12.0.0.177059.run --rootdir $SMRT_ROOT"'

RUN adduser --disabled-password smrtanalysis
RUN mkdir -p /opt/pacbio
RUN chown smrtanalysis:smrtanalysis /opt/pacbio
RUN apt-get update \
 && apt-get install -y rsync \
 && apt-get install -y locales \
 && localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8
RUN apt-get clean

# also needs ss
# also had to fix some file permissions

ENV LANG en_US.utf8

COPY smrtlink_12.0.0.177059.run /opt/pacbio/smrtlink_12.0.0.177059.run

CMD ["/bin/bash", "-c", "exec bash"] # doing it this way makes it so that exit the shell will cause the container to exit
