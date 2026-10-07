# chromium-kiosk

Container that shows a web page full screen on the display of a device: the Wayland kiosk compositor [cage](https://github.com/cage-kiosk/cage) with Chromium, touch input and an optional splash page that waits until the target page answers. Built for Raspberry Pi (`linux/arm64`), developed for a heating-controller panel on [CuOS](https://github.com/cuos-dev).

**Status: draft.** On x86 the image builds and `cage` with Chromium starts headless. It has not yet run on a real display or a Raspberry Pi.

## Configuration (environment)

| Variable | Default | Meaning |
|---|---|---|
| `HMI_KIOSK_URL` | required | Page to show; the splash opens it once it answers |
| `HMI_KIOSK_VT` | `7` | Virtual terminal to run on |
| `HMI_KIOSK_ZOOM` | `1` | Device scale factor |
| `HMI_KIOSK_DRM_DEVICE` | auto | e.g. `/dev/dri/card1` if the board has several |
| `HMI_KIOSK_FLAGS` | empty | Extra Chromium flags |

Splash branding: mount an SVG at `/opt/splash/logo.svg` and a one-line text at `/opt/splash/title.txt`.

## Run

```yaml
services:
  kiosk:
    image: ghcr.io/kbe-solvis/chromium-kiosk:latest
    restart: always
    init: true
    environment:
      - HMI_KIOSK_URL=http://nginx/
    devices: ["/dev/tty0:/dev/tty0", "/dev/tty7:/dev/tty7"]
    device_cgroup_rules: ["c 226:* rmw", "c 13:* rmw", "c 4:* rmw"]
    cap_add: [SYS_TTY_CONFIG]
    volumes: ["/dev/dri:/dev/dri", "/dev/input:/dev/input", "/run/udev:/run/udev:ro"]
    tmpfs: ["/tmp", "/run/user"]
```

If the compositor cannot start under AppArmor, try `security_opt: [apparmor=unconfined]` for this service.

## Security note

Chromium runs as root without its sandbox (required in this container). Only point it at pages you control.

## License

MIT, see `LICENSE`. Chromium, cage and Debian packages in the image keep their own licenses.
