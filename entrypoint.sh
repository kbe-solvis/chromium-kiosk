#!/bin/sh
# SPDX-License-Identifier: MIT
# SPDX-FileCopyrightText: 2026 Karsten Brozat-Essen
# Starts the cage kiosk compositor with Chromium on a virtual terminal.
# DRAFT: the hand-over of the virtual terminal and the GPU flags are not tested on a device.
set -eu

URL="${HMI_KIOSK_URL:?HMI_KIOSK_URL is not set}"
VT="${HMI_KIOSK_VT:-7}"
ZOOM="${HMI_KIOSK_ZOOM:-1}"
EXTRA_FLAGS="${HMI_KIOSK_FLAGS:-}"

# The splash page is copied to a writable place together with a small config file:
# it waits until the start page answers and then opens it.
SPLASH=/tmp/splash
mkdir -p "$SPLASH"
cp -r /opt/splash/. "$SPLASH"/
TITLE=""
[ -r /opt/splash/title.txt ] && TITLE="$(head -n 1 /opt/splash/title.txt)"
js_escape() { printf '%s' "$1" | sed -e 's/\\/\\\\/g' -e 's/"/\\"/g'; }
printf 'window.HMI = { target: "%s", title: "%s" };\n' "$(js_escape "$URL")" "$(js_escape "$TITLE")" > "$SPLASH/config.js"

export XDG_RUNTIME_DIR=/run/user/0
mkdir -p "$XDG_RUNTIME_DIR"
chmod 700 "$XDG_RUNTIME_DIR"

# wlroots / libseat: use the built-in seat backend (we are root and own the terminal), start without input devices
export LIBSEAT_BACKEND=builtin
export WLR_LIBINPUT_NO_DEVICES=1
[ -n "${HMI_KIOSK_DRM_DEVICE:-}" ] && export WLR_DRM_DEVICES="$HMI_KIOSK_DRM_DEVICE"

# Chromium: root needs --no-sandbox in a container. Profile in /tmp (tmpfs): nothing is written to the disk.
# shellcheck disable=SC2086
set -- chromium \
  --kiosk \
  --no-sandbox \
  --user-data-dir=/tmp/chromium \
  --ozone-platform=wayland \
  --force-device-scale-factor="$ZOOM" \
  --touch-events=enabled \
  --noerrdialogs \
  --disable-infobars \
  --disable-session-crashed-bubble \
  --hide-crash-restore-bubble \
  --no-first-run \
  --disable-pinch \
  --overscroll-history-navigation=0 \
  --password-store=basic \
  --disable-background-networking \
  --disable-sync \
  --disable-component-update \
  --disable-features=Translate,MediaRouter \
  $EXTRA_FLAGS \
  "file://$SPLASH/index.html"

# -s: allow switching away from the terminal (CuOS console menu, failure screen); -d: no client side decorations
exec openvt -c "$VT" -s -f -w -- cage -s -d -- "$@"
