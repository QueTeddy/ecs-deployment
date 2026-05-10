FROM b0nam/debian-novnc:base

ENV TIGER_VNC_PASSWORD=PASSWORD
ENV DISPLAY=:1
ENV HOME=/root

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
    git \
    ca-certificates \
    curl \
    wget \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /opt
RUN git clone https://github.com/fabiangreffrath/crispy-doom.git

WORKDIR /opt/crispy-doom
RUN autoreconf -fiv && \
    ./configure && \
    make && \
    make install

RUN wget -O doom_wad.tar.gz http://ftp.debian.org/debian/pool/non-free/d/doom-wad-shareware/doom-wad-shareware_1.9.fixed.orig.tar.gz && \
    tar -xzvf doom_wad.tar.gz && \
    mv doom-wad-shareware-1.9.fixed/doom1.wad /opt/crispy-doom/ && \
    rm -rf doom-wad-shareware-1.9.fixed doom_wad.tar.gz

WORKDIR /src

COPY . .

RUN chmod +x /src/entrypoint.sh /src/startdoom.sh

EXPOSE 8080

ENTRYPOINT ["/src/entrypoint.sh"]