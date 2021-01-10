FROM ubuntu:focal

ADD . /opt/envsetup-lite
ENV LANG=C.UTF-8 LC_ALL=C.UTF-8
ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update --fix-missing
RUN apt-get install --yes curl wget sudo
RUN apt-get clean
RUN useradd -m testuser -s /bin/bash \
    && adduser testuser sudo \
    && echo "testuser ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

USER testuser
RUN whoami
RUN sudo whoami
RUN echo "Build date: 10/01/2020"
RUN cd /home/testuser \
    && cp -r /opt/envsetup-lite . \
    && cd envsetup-lite \
    && DO_ALL=true /bin/bash set_up.sh

