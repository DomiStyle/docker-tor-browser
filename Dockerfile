FROM jlesage/baseimage-gui:ubuntu-16.04

# Set environment variables
ENV APP_NAME="Tor Browser" \
    TOR_VERSION=8.0.8 \
    TOR_BINARY=https://www.torproject.org/dist/torbrowser/$TOR_VERSION/tor-browser-linux64-$TOR_VERSION_en-US.tar.xz \
    TOR_SIGNATURE=https://www.torproject.org/dist/torbrowser/$TOR_VERSION/tor-browser-linux64-$TOR_VERSION_en-US.tar.xz.asc \
    TOR_FINGERPRINT=0x4E2C6E8793298290

# Install Tor onion icon
RUN install_app_icon.sh "https://github.com/DomiStyle/docker-tor-browser/raw/master/icon.png"

# Add wget and Tor browser dependencies
RUN apt-get update && \
    apt-get install -y wget libdbus-glib-1-2 libgtk-3-0 && \
    rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Download binary and signature
RUN wget $TOR_BINARY && \
    wget $TOR_SIGNATURE

# Verify GPG signature
RUN gpg --keyserver pool.sks-keyservers.net --recv-keys $TOR_FINGERPRINT && \
    gpg --fingerprint $TOR_FINGERPRINT && \
    gpg --verify "${TOR_SIGNATURE##*/}"

# Extract browser & cleanup
RUN tar --strip 1 -xvJf "${TOR_BINARY##*/}" && \
    chown -R ${USER_ID}:${GROUP_ID} /app && \
    rm "${TOR_BINARY##*/}" "${TOR_SIGNATURE##*/}"

# Add start script
COPY startapp.sh /startapp.sh
