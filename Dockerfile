# USE ALPINE AS BASE IMAGE
FROM b0nam/debian-novnc:base

ENV TIGER_VNC_PASSWORD PASSWORD

# INSTALL DEPENDENCIES
RUN apt-get update && \
    apt-get install --no-install-recommends -y \
    build-essential \
    libsdl2-dev \
    libsdl2-net-dev \
    libsdl2-mixer-dev \
    python3-pil \
    automake \
    autoconf \
    libtool \
    pkg-config \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# CLONE CRISPY-DOOM REPOSITORY
WORKDIR /opt
RUN git clone https://github.com/fabiangreffrath/crispy-doom.git

# RUN COMPILATION COMMANDS
WORKDIR /opt/crispy-doom
RUN autoreconf -fiv && \
    ./configure && \
    make && \
    make install

# GET DOOM1 WAD FILE
RUN wget -O doom1.wad http://ftp.debian.org/debian/pool/non-free/d/doom-wad-shareware/doom-wad-shareware_1.9.fixed.orig.tar.gz && \
    tar -xzvf doom1.wad && \
    mv /opt/crispy-doom/doom-wad-shareware-1.9.fixed/doom1.wad /opt/crispy-doom && \
    rm -rf /opt/crispy-doom/doom-wad-shareware-1.9.fixed

COPY . /src