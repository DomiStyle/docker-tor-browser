FROM jlesage/baseimage-gui:ubuntu-18.04

ENV TOR_VERSION="11.0.3"
ENV APP_NAME="Tor Browser ${TOR_VERSION}"
ENV ONION_ICON_URL="https://raw.githubusercontent.com/DomiStyle/docker-tor-browser/master/icon.png"
ENV TOR_BINARY="https://www.torproject.org/dist/torbrowser/${TOR_VERSION}/tor-browser-linux64-${TOR_VERSION}_en-US.tar.xz"
ENV TOR_SIGNATURE="https://www.torproject.org/dist/torbrowser/${TOR_VERSION}/tor-browser-linux64-${TOR_VERSION}_en-US.tar.xz.asc"
ENV TOR_GPG_KEY="https://openpgpkey.torproject.org/.well-known/openpgpkey/torproject.org/hu/kounek7zrdx745qydx6p59t9mqjpuhdf"
ENV TOR_FINGERPRINT="0xEF6E286DDA85EA2A4BA7DE684E2C6E8793298290"
ENV DEBIAN_FRONTEND="noninteractive"

# Generate Tor onion favicons
RUN install_app_icon.sh "${ONION_ICON_URL}"

RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    curl \
    gpg \
    gnupg \
    libdbus-glib-1-2 \
    libgtk-3-0 \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /app

RUN curl -sLO "${TOR_BINARY}" \
  && curl -sLO "${TOR_SIGNATURE}"

# Verify GPG signature of the Tor Browser binary
RUN curl -sL "${TOR_GPG_KEY}" | gpg --import - \
  && gpg --output ./tor.keyring --export "${TOR_FINGERPRINT}" \
  && gpgv --keyring ./tor.keyring "${TOR_SIGNATURE##*/}" "${TOR_BINARY##*/}"

# Install Tor Browser
RUN tar --strip 1 -xvJf "${TOR_BINARY##*/}" \
  && chown -R "${USER_ID}":"${GROUP_ID}" /app \
  && rm "${TOR_BINARY##*/}" "${TOR_SIGNATURE##*/}"

COPY browser-cfg /browser-cfg
COPY startapp.sh /startapp.sh

EXPOSE 5800
EXPOSE 5900
