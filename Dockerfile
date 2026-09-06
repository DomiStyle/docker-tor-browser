### Build stage
FROM jlesage/baseimage-gui:ubuntu-22.04-v4 AS builder

ARG LOCALE="en-US"

ENV TOR_VERSION_X64="15.0.21"
ENV TOR_VERSION_ARM64="16.0a11"

# automatic; passed in by Docker buildx
ARG TARGETARCH
# x64 Tor Browser official build
ENV TOR_BINARY_X64="https://www.torproject.org/dist/torbrowser/${TOR_VERSION_X64}/tor-browser-linux-x86_64-${TOR_VERSION_X64}.tar.xz"
ENV TOR_SIGNATURE_X64="https://www.torproject.org/dist/torbrowser/${TOR_VERSION_X64}/tor-browser-linux-x86_64-${TOR_VERSION_X64}.tar.xz.asc"
ENV TOR_GPG_KEY_X64="https://openpgpkey.torproject.org/.well-known/openpgpkey/torproject.org/hu/kounek7zrdx745qydx6p59t9mqjpuhdf"
ENV TOR_FINGERPRINT_X64="0xEF6E286DDA85EA2A4BA7DE684E2C6E8793298290"
# arm64 Tor Browser official build
ENV TOR_BINARY_ARM64="https://www.torproject.org/dist/torbrowser/${TOR_VERSION_ARM64}/tor-browser-linux-aarch64-${TOR_VERSION_ARM64}.tar.xz"
ENV TOR_SIGNATURE_ARM64="https://www.torproject.org/dist/torbrowser/${TOR_VERSION_ARM64}/tor-browser-linux-aarch64-${TOR_VERSION_ARM64}.tar.xz.asc"
ENV TOR_GPG_KEY_ARM64="https://openpgpkey.torproject.org/.well-known/openpgpkey/torproject.org/hu/kounek7zrdx745qydx6p59t9mqjpuhdf"
ENV TOR_FINGERPRINT_ARM64="0xEF6E286DDA85EA2A4BA7DE684E2C6E8793298290"

ARG DEBIAN_FRONTEND="noninteractive"
# The base image points /etc/passwd, /etc/group, /etc/shadow, /run and /var/log
# at locations that only exist once the container starts. Package maintainer
# scripts that add a system user/group or write to /run or /var/log therefore
# fail during the build (here: imagemagick -> fontconfig). Materialise the
# paths; this stage is discarded, so nothing needs restoring.
RUN mkdir -p /tmp/run /config/log /config/var/tmp \
  && rm -f /etc/passwd /etc/group /etc/shadow \
  && cp /usr/share/base-passwd/passwd.master /etc/passwd \
  && cp /usr/share/base-passwd/group.master /etc/group \
  && touch /etc/shadow \
  && chmod 640 /etc/shadow

RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    gnupg \
    gpg \
    xz-utils \
  && rm -rf /var/lib/apt/lists/*

# Generate Tor onion favicons (needs curl)
ENV ONION_ICON_URL="https://raw.githubusercontent.com/DomiStyle/docker-tor-browser/master/icon.png"
RUN install_app_icon.sh "${ONION_ICON_URL}"


WORKDIR /app

RUN if [ "$TARGETARCH" = "amd64" ]; then \
      echo "Downloading Tor Browser for amd64" && \
      curl -sSLO "${TOR_BINARY_X64}" && \
      curl -sSLO "${TOR_SIGNATURE_X64}" && \
      echo "Verifying GPG signature for amd64" && \
      curl -sSL "${TOR_GPG_KEY_X64}" | gpg --import - && \
      gpg --output ./tor.keyring --export "${TOR_FINGERPRINT_X64}" && \
      gpgv --keyring ./tor.keyring "${TOR_SIGNATURE_X64##*/}" "${TOR_BINARY_X64##*/}" && \
      du -sh "${TOR_BINARY_X64##*/}" "${TOR_SIGNATURE_X64##*/}" && \
      echo "Installing Tor Browser for amd64" && \
      tar --strip 1 -xvJf "${TOR_BINARY_X64##*/}" && \
      chown -R "${USER_ID}:${GROUP_ID}" /app && \
      rm "${TOR_BINARY_X64##*/}" "${TOR_SIGNATURE_X64##*/}"; \
    elif [ "$TARGETARCH" = "arm64" ]; then \
      set -x && \
      echo "Downloading Tor Browser for arm64" && \
      curl -sSLO "${TOR_BINARY_ARM64}" && \
      curl -sSLO "${TOR_SIGNATURE_ARM64}" && \
      echo "Verifying GPG signature for arm64" && \
      curl -sSL "${TOR_GPG_KEY_ARM64}" | gpg --import - && \
      echo "export fingerprint" && \
      gpg --output ./tor.keyring --export "${TOR_FINGERPRINT_ARM64}" && \
      echo "verify file" && \
      gpgv --keyring ./tor.keyring "${TOR_SIGNATURE_ARM64##*/}" "${TOR_BINARY_ARM64##*/}" && \
      echo "show files" && \
      du -sh "${TOR_BINARY_ARM64##*/}" "${TOR_SIGNATURE_ARM64##*/}" && \
      echo "Installing Tor Browser for arm64" && \
      tar --strip 1 -xvJf "${TOR_BINARY_ARM64##*/}" && \
      chown -R "${USER_ID}:${GROUP_ID}" /app && \
      rm "${TOR_BINARY_ARM64##*/}" "${TOR_SIGNATURE_ARM64##*/}"; \
    else \
      echo "CRITICAL: Architecture '${TARGETARCH}' not in [amd64, arm64]" && \
      exit 1; \
    fi

### Final image
FROM jlesage/baseimage-gui:ubuntu-22.04-v4

ENV APP_NAME="Tor Browser"

ENV show_output=1

# Stream the application's audio to the browser (noVNC only, not VNC clients).
ENV WEB_AUDIO=1

ARG DEBIAN_FRONTEND="noninteractive"
# Same base image path problem as the builder stage. dbus-x11 is listed
# explicitly to satisfy libgtk-3-0's "default-dbus-session-bus | dbus-session-bus"
# dependency: without it apt selects dbus-user-session, which drags in systemd,
# whose postinst cannot run in this image. The symlinks are restored afterwards
# so the base image's runtime user setup still works.
RUN mkdir -p /tmp/run /config/log /config/var/tmp \
  && rm -f /etc/passwd /etc/group /etc/shadow \
  && cp /usr/share/base-passwd/passwd.master /etc/passwd \
  && cp /usr/share/base-passwd/group.master /etc/group \
  && touch /etc/shadow \
  && chmod 640 /etc/shadow \
  && apt-get update \
  && apt-get install -y --no-install-recommends \
    file \
    libdbus-glib-1-2 \
    libgtk-3-0 \
    libx11-xcb1 \
    libxt6 \
    libasound2 \
    libpulse0 \
    dbus-x11 \
    vlc \
    xterm \
  && rm -rf /var/lib/apt/lists/* \
  && rm -f /etc/passwd /etc/group /etc/shadow \
  && ln -s /tmp/.passwd /etc/passwd \
  && ln -s /tmp/.group /etc/group \
  && ln -s /tmp/.shadow /etc/shadow \
  && rm -rf /tmp/run /config/log /config/var

COPY --from=builder /app /app
COPY --from=builder /opt/noVNC/app/images/icons/* /opt/noVNC/app/images/icons/
COPY --from=builder /opt/noVNC/index.html /opt/noVNC/index.html

# Openbox root menu, for launching VLC and a terminal alongside the browser.
# The baseimage ships an empty menu.xml and an empty "Root" mouse context, so
# the menu needs both a definition and a right-click binding. rc.xml is
# regenerated from this template on every start, so the template is patched
# rather than the generated file. sed-patch fails the build if the expression
# matches nothing, which catches the anchor disappearing in a future baseimage.
# Identify the browser as the "main" window. Without this file the baseimage
# falls back to matching type="normal", which applies the main-window rule
# (undecorated, maximized, layer below) to *every* window, leaving VLC and
# xterm stuck fullscreen and unresizable.
# Give the 'app' user a real shell and a home directory, so a terminal opened
# from the desktop menu starts bash in /app rather than sh in /.
COPY cont-init/11-app-user.sh /etc/cont-init.d/11-app-user.sh
# Docker defaults HOME to "/" for the container, and internal (cont-env.d)
# variables do not override one that is already set, so this has to be an ENV.
# Tor Browser sets its own HOME (/app/Browser) at launch and is unaffected.
ENV HOME="/app"

COPY openbox/main-window-selection.xml /etc/openbox/main-window-selection.xml
COPY openbox/menu.xml /opt/base/etc/openbox/menu.xml
RUN sed-patch 's|<context name="Root">|<context name="Root">\n    <mousebind button="Right" action="Press"><action name="ShowMenu"><menu>root-menu</menu></action></mousebind>|' \
      /opt/base/etc/openbox/rc.xml.template

COPY browser-cfg /browser-cfg
COPY startapp.sh /startapp.sh

EXPOSE 5800
EXPOSE 5900

