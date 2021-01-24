FROM debian:latest

RUN apt update \
	&& apt install -y build-essential pkg-config automake libtool python3-pip libboost-dev libboost-system-dev libboost-chrono-dev libboost-random-dev libboost-python-dev libssl-dev libgeoip-dev wget git

RUN wget https://github.com/arvidn/libtorrent/releases/download/libtorrent-1_1_14/libtorrent-rasterbar-1.1.14.tar.gz \
	&& tar xf libtorrent-rasterbar-1.1.14.tar.gz \
	&& cd libtorrent-rasterbar-1.1.14 \
	&& ./configure --enable-encryption --enable-python-binding --with-libiconv CXXFLAGS=-std=c++11 PYTHON=/usr/bin/python3 \
	&& make -j$(nproc) \
	&& make install \
	&& ldconfig

RUN pip3 install twisted pyopenssl simplejson pyxdg chardet geoip setproctitle pillow mako service_identity \
	&& git clone --branch deluge-2.0.3 https://github.com/deluge-torrent/deluge/ \
	&& cd deluge \
	&& python3 setup.py build \
	&& python3 setup.py install --install-layout=deb

RUN rm -rf /var/lib/apt/lists/* /libtorrent* /deluge \
	&& apt-get clean

RUN mkdir -p /root/download

COPY ./deluge /root/.config/deluge/

EXPOSE 8112 15050 15051 58846

CMD deluged && deluge-web