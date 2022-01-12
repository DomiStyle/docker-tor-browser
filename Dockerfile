### Build stage
FROM jlesage/baseimage-gui:ubuntu-20.04 AS builder

ENV TOR_VERSION="11.0.4"
ENV ONION_ICON_URL="https://raw.githubusercontent.com/DomiStyle/docker-tor-browser/master/icon.png"
ENV TOR_BINARY="https://www.torproject.org/dist/torbrowser/${TOR_VERSION}/tor-browser-linux64-${TOR_VERSION}_en-US.tar.xz"
ENV TOR_SIGNATURE="https://www.torproject.org/dist/torbrowser/${TOR_VERSION}/tor-browser-linux64-${TOR_VERSION}_en-US.tar.xz.asc"
ENV TOR_GPG_KEY="https://openpgpkey.torproject.org/.well-known/openpgpkey/torproject.org/hu/kounek7zrdx745qydx6p59t9mqjpuhdf"
ENV TOR_FINGERPRINT="0xEF6E286DDA85EA2A4BA7DE684E2C6E8793298290"

# Generate Tor onion favicons
RUN install_app_icon.sh "${ONION_ICON_URL}"

ARG DEBIAN_FRONTEND="noninteractive"
RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    curl \
    gnupg \
    gpg \
    xz-utils \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /app

RUN curl -sLO "${TOR_BINARY}"
RUN curl -sLO "${TOR_SIGNATURE}"

# Verify GPG signature of the Tor Browser binary
RUN curl -sL "${TOR_GPG_KEY}" | gpg --import -
RUN gpg --output ./tor.keyring --export "${TOR_FINGERPRINT}"
RUN gpgv --keyring ./tor.keyring "${TOR_SIGNATURE##*/}" "${TOR_BINARY##*/}"

# Install Tor Browser
RUN tar --strip 1 -xvJf "${TOR_BINARY##*/}"
RUN chown -R "${USER_ID}":"${GROUP_ID}" /app
RUN rm "${TOR_BINARY##*/}" "${TOR_SIGNATURE##*/}"

### Final image
FROM jlesage/baseimage-gui:ubuntu-20.04

ENV TOR_VERSION="11.0.4"
ENV APP_NAME="Tor Browser ${TOR_VERSION}"

ARG DEBIAN_FRONTEND="noninteractive"
RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    libdbus-glib-1-2 \
    libgtk-3-0 \
  && rm -rf /var/lib/apt/lists/*

COPY --from=builder /app /app
COPY --from=builder /opt/novnc/images/icons/* /opt/novnc/images/icons/
COPY --from=builder /opt/novnc/index.vnc /opt/novnc/index.vnc

COPY browser-cfg /browser-cfg
COPY startapp.sh /startapp.sh

EXPOSE 5800
EXPOSE 5900
