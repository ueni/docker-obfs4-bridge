# Base docker image
# platform -flag isn't supported by docker hub
# FROM --platform="linux/arm" debian:stable-slim

FROM arm32v7/debian:stable-slim

# This the original maintainer
# LABEL maintainer="Philipp Winter <phw@torproject.org>"
LABEL maintainer="ueni, ueniueni"

COPY qemu-arm-static /usr/bin

# Install dependencies to add Tor's repository.
RUN apt-get update && apt-get install -y \
    libcap2-bin \
    curl \
    gpg \
    gpg-agent \
    ca-certificates \
    --no-install-recommends

# See: <https://2019.www.torproject.org/docs/debian.html.en>
RUN curl --verbose -k https://deb.torproject.org/torproject.org/A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89.asc | gpg --import
RUN gpg --export A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89 | apt-key add -

RUN printf "deb https://deb.torproject.org/torproject.org stable main\n" >> /etc/apt/sources.list.d/tor

# Install remaining dependencies.
RUN apt-get update && apt-get install -y \
    tor \
    tor-geoipdb \
    obfs4proxy \
    --no-install-recommends

# Allow obfs4proxy to bind to ports < 1024.
RUN setcap cap_net_bind_service=+ep /usr/bin/obfs4proxy

# Our torrc is generated at run-time by the script start-tor.sh.
RUN rm /etc/tor/torrc
RUN chown debian-tor:debian-tor /etc/tor
RUN chown debian-tor:debian-tor /var/log/tor

COPY start-tor.sh /usr/local/bin
RUN chmod 0755 /usr/local/bin/start-tor.sh

COPY get-bridge-line /usr/local/bin
RUN chmod 0755 /usr/local/bin/get-bridge-line

USER debian-tor

CMD [ "/usr/local/bin/start-tor.sh" ]
