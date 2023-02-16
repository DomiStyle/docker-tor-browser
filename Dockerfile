### Build stage
FROM jlesage/baseimage-gui:ubuntu-20.04-v4 AS builder

ARG LOCALE="en-US"

ENV TOR_VERSION_X64="12.0.3"
ENV TOR_VERSION_ARM64="12.0.2"

# automatic; passed in by Docker buildx
ARG TARGETARCH
# x64 Tor Browser official build
ENV TOR_BINARY_X64="https://www.torproject.org/dist/torbrowser/${TOR_VERSION_X64}/tor-browser-linux64-${TOR_VERSION_X64}_ALL.tar.xz"
ENV TOR_SIGNATURE_X64="https://www.torproject.org/dist/torbrowser/${TOR_VERSION_X64}/tor-browser-linux64-${TOR_VERSION_X64}_ALL.tar.xz.asc"
ENV TOR_GPG_KEY_X64="https://openpgpkey.torproject.org/.well-known/openpgpkey/torproject.org/hu/kounek7zrdx745qydx6p59t9mqjpuhdf"
ENV TOR_FINGERPRINT_X64="0xEF6E286DDA85EA2A4BA7DE684E2C6E8793298290"
# arm64 Tor Browser unofficial build
ENV TOR_BINARY_ARM64="https://sourceforge.net/projects/tor-browser-ports/files/${TOR_VERSION_ARM64}/tor-browser-linux-arm64-${TOR_VERSION_ARM64}_${LOCALE}.tar.xz"
ENV TOR_SIGNATURE_ARM64="https://sourceforge.net/projects/tor-browser-ports/files/${TOR_VERSION_ARM64}/tor-browser-linux-arm64-${TOR_VERSION_ARM64}_${LOCALE}.tar.xz.asc"
ENV TOR_GPG_KEY_ARM64="https://h-lindholm.net/pubkey"
ENV TOR_FINGERPRINT_ARM64="0x24F141A3B988B6C350B937586AF15D1E45FDCEC9"

# Generate Tor onion favicons
ENV ONION_ICON_URL="https://raw.githubusercontent.com/DomiStyle/docker-tor-browser/master/icon.png"
RUN install_app_icon.sh "${ONION_ICON_URL}"

ARG DEBIAN_FRONTEND="noninteractive"
RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    gnupg \
    gpg \
    xz-utils \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Download Tor Browser
RUN if [ "$TARGETARCH" = "amd64" ]; then \
      curl -sSLO "${TOR_BINARY_X64}" && \
      curl -sSLO "${TOR_SIGNATURE_X64}"; \
    elif [ "$TARGETARCH" = "arm64" ]; then \
      curl -sSLO "${TOR_BINARY_ARM64}" && \
      curl -sSLO "${TOR_SIGNATURE_ARM64}"; \
    else \
      echo "CRITICAL: Architecture '${TARGETARCH}' not in [amd64, arm64]" && \
      exit 1; \
    fi

# Verify GPG signature of the Tor Browser binary
RUN if [ "$TARGETARCH" = "amd64" ]; then \
      curl -sSL "${TOR_GPG_KEY_X64}" | gpg --import - && \
      gpg --output ./tor.keyring --export "${TOR_FINGERPRINT_X64}" && \
      gpgv --keyring ./tor.keyring "${TOR_SIGNATURE_X64##*/}" "${TOR_BINARY_X64##*/}"; \
    elif [ "$TARGETARCH" = "arm64" ]; then \
      curl -sSL "${TOR_GPG_KEY_ARM64}" | gpg --import - && \
      gpg --output ./tor.keyring --export "${TOR_FINGERPRINT_ARM64}" && \
      gpgv --keyring ./tor.keyring "${TOR_SIGNATURE_ARM64##*/}" "${TOR_BINARY_ARM64##*/}"; \
    else \
      echo "CRITICAL: Architecture '${TARGETARCH}' not in [amd64, arm64]" && \
      exit 1; \
    fi

# Install Tor Browser
RUN if [ "$TARGETARCH" = "amd64" ]; then \
      tar --strip 1 -xvJf "${TOR_BINARY_X64##*/}" && \
      chown -R "${USER_ID}":"${GROUP_ID}" /app && \
      rm "${TOR_BINARY_X64##*/}" "${TOR_SIGNATURE_X64##*/}"; \
    elif [ "$TARGETARCH" = "arm64" ]; then \
      tar --strip 1 -xvJf "${TOR_BINARY_ARM64##*/}" && \
      chown -R "${USER_ID}":"${GROUP_ID}" /app && \
      rm "${TOR_BINARY_ARM64##*/}" "${TOR_SIGNATURE_ARM64##*/}"; \
    else \
      echo "CRITICAL: Architecture '${TARGETARCH}' not in [amd64, arm64]" && \
      exit 1; \
    fi

### Final image
FROM jlesage/baseimage-gui:ubuntu-20.04-v4

ENV APP_NAME="Tor Browser"

ENV show_output=1

ARG DEBIAN_FRONTEND="noninteractive"
RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    file \
    libdbus-glib-1-2 \
    libgtk-3-0 \
    libx11-xcb1 \
    libxt6 \
    libasound2 \
  && rm -rf /var/lib/apt/lists/*

COPY --from=builder /app /app
COPY --from=builder /opt/noVNC/app/images/icons/* /opt/noVNC/app/images/icons/
COPY --from=builder /opt/noVNC/index.html /opt/noVNC/index.html

COPY browser-cfg /browser-cfg
COPY startapp.sh /startapp.sh

EXPOSE 5800
EXPOSE 5900
