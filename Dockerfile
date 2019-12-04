FROM jlesage/baseimage-gui:ubuntu-18.04

# Set environment variables
ENV APP_NAME="Tor Browser" \
    TOR_VERSION=9.0.2 \
    TOR_BINARY=https://www.torproject.org/dist/torbrowser/9.0.2/tor-browser-linux64-9.0.2_en-US.tar.xz \
    TOR_SIGNATURE=https://www.torproject.org/dist/torbrowser/9.0.2/tor-browser-linux64-9.0.2_en-US.tar.xz.asc \
    TOR_FINGERPRINT=0xEF6E286DDA85EA2A4BA7DE684E2C6E8793298290 \
    DEBIAN_FRONTEND=noninteractive

# Install Tor onion icon
RUN install_app_icon.sh "https://github.com/DomiStyle/docker-tor-browser/raw/master/icon.png"

# Add wget and Tor browser dependencies
RUN apt-get update && \
    apt-get install -y wget gpg libdbus-glib-1-2 libgtk-3-0 && \
    rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Download binary and signature
RUN wget $TOR_BINARY && \
    wget $TOR_SIGNATURE

# Verify GPG signature
RUN gpg --auto-key-locate nodefault,wkd --locate-keys torbrowser@torproject.org && \
    gpg --output ./tor.keyring --export $TOR_FINGERPRINT && \
    gpgv --keyring ./tor.keyring "${TOR_SIGNATURE##*/}" "${TOR_BINARY##*/}"

# Extract browser & cleanup
RUN tar --strip 1 -xvJf "${TOR_BINARY##*/}" && \
    chown -R ${USER_ID}:${GROUP_ID} /app && \
    rm "${TOR_BINARY##*/}" "${TOR_SIGNATURE##*/}"

# Add start script
COPY startapp.sh /startapp.sh
