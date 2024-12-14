### Build stage
FROM jlesage/baseimage-gui:ubuntu-22.04-v4 AS builder

ARG LOCALE="en-US"

ENV WATERFOX_VERSION_X64="5.7.2"
ENV WATERFOX_VERSION_ARM64="5.7.2"

ARG TARGETARCH
# x64 Tor Browser official build
ENV WATERFOX_BINARY="https://cdn1.waterfox.net/waterfox/releases/6.5.2/Linux_x86_64/waterfox-6.5.2.tar.bz2"
ENV WATERFOX_GPG_KEY="https://download.opensuse.org/repositories/home:/hawkeye116477:/waterfox:/build-depends/xUbuntu_22.04/Release.gpg"
# arm64 Tor Browser unofficial build
# Generate Tor onion favicons
ENV WATERFOX_ICON_URL="https://raw.githubusercontent.com/DomiStyle/docker-tor-browser/master/icon.png"
RUN install_app_icon.sh "${WATERFOX_ICON_URL}"

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
      curl -sSLO "${WATERFOX_BINARY}" 
    else \
      echo "CRITICAL: Architecture '${TARGETARCH}' not in [amd64, arm64]" && \
      exit 1; \
    fi

# Verify GPG signature of the Tor Browser binary
RUN if [ "$TARGETARCH" = "amd64" ]; then \
      curl -fsSL "${ WATERFOX_GPG_KEY}" |  sudo gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/home_hawkeye116477_waterfox.gpg > /dev/null gpg --import - && \
      curl -fsSL https://download.opensuse.org/repositories/home:hawkeye116477:waterfox/xUbuntu_22.04/Release.key | 
      echo 'deb http://download.opensuse.org/repositories/home:/hawkeye116477:/waterfox/xUbuntu_22.04/ /' | sudo tee /etc/apt/sources.list.d/home:hawkeye116477:waterfox.list
# automatic; passed in by Docker buildx
      
    else \
      echo "CRITICAL: Architecture '${TARGETARCH}' not in [amd64, arm64]" && \
      exit 1; \
    fi

# Install Tor Browser
RUN if [ "$TARGETARCH" = "amd64" ]; then \
      tar --strip 1 -xf "${WATERFOX_BINARY##*/}" && \
      chown -R "${USER_ID}":"${GROUP_ID}" /app && \
      rm "${WATERFOX_BINARY##*/}" \
    elif [ "$TARGETARCH" = "arm64" ]; then \      
    else \
      echo "CRITICAL: Architecture '${TARGETARCH}' not in [amd64, arm64]" && \
      exit 1; \
    fi

### Final image
FROM jlesage/baseimage-gui:ubuntu-22.04-v4

ENV APP_NAME= "Waterfox Browser"

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
