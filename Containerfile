# SPDX-License-Identifier: MIT
# SPDX-FileCopyrightText: 2026 Karsten Brozat-Essen
FROM debian:trixie-slim

ENV DEBIAN_FRONTEND=noninteractive

# cage:        Wayland compositor for a single full screen application
# chromium:    the browser
# libgl1-mesa-dri, libegl1, libgles2, libgbm1: GPU drivers and libraries (vc4/v3d on Raspberry Pi)
# kbd:         openvt, to run the compositor on a virtual terminal
# procps:      pgrep (health check)
RUN apt-get update && apt-get install -y --no-install-recommends \
    cage \
    chromium \
    libgl1-mesa-dri \
    libegl1 \
    libgles2 \
    libgbm1 \
    kbd \
    procps \
    ca-certificates \
    tzdata \
    fonts-dejavu-core \
    fonts-liberation \
    && rm -rf /var/lib/apt/lists/*

COPY ./entrypoint.sh /usr/local/bin/hmi-kiosk
COPY ./splash/ /opt/splash/
RUN chmod +x /usr/local/bin/hmi-kiosk

ENTRYPOINT ["/usr/local/bin/hmi-kiosk"]
