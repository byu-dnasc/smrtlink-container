FROM ubuntu.20.04

RUN adduser --disabled-password smrtanalysis
RUN mkdir -p /opt/pacbio

ENV SMRT_ROOT=/opt/pacbio/smrtlink
ENV SMRT_USER=smrtanalysis