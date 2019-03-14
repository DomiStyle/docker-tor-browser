# Tor browser

![](https://github.com/DomiStyle/docker-tor-browser/raw/master/screenshot.png)
*Tor browser running inside of Firefox*

## About

This image allows running a [Tor browser](https://www.torproject.org/) instance on any headless server. The browser can be accessed via either a web interface or directly from any VNC client.

Container is based on [baseimage-gui](https://github.com/jlesage/docker-baseimage-gui) by [jlesage](https://github.com/jlesage)

# Usage

See the docker-compose [here](https://github.com/DomiStyle/docker-tor-browser/blob/master/docker-compose.yml) or use this command:

    docker run -d -p 5800:5800 domistyle/tor-browser

The web interface will be available on port 5800.

## Configuration

No special configuration is necessary, however some recommended variables are available:

| Variable  | Description | Default  | Required |
|-----------|-------------|----------|----------|
| `DISPLAY_WIDTH` | Set the width of the virtual screen | ``1280`` | No |
| `DISPLAY_HEIGHT` | Set the height of the virtual screen | ``768`` | No |
| `KEEP_APP_RUNNING` | Automatically restarts the Tor browser if it exits | ``0`` | No |
| `TZ` | `Set the time zone for the container | - | No |

**For advanced configuration options please take a look [here](https://github.com/jlesage/docker-baseimage-gui#environment-variables).**

## Volumes

| Path       | Description                                  | Required |
|------------|----------------------------------------------|----------|
| `/app/Browser/TorBrowser/Data/Tor` | Add a volume for the Tor settings to speedup container startup when the container gets recreated | No |

Make sure the container user has read & write permission to these folders on the host. [More info here](https://github.com/jlesage/docker-baseimage-gui#usergroup-ids).

## Ports

| Port       | Description                                  |
|------------|----------------------------------------------|
| `5800` | Provides a web interface to access the Tor browser |
| `5900` | Provides direct access to the VNC server |

## Issues & limitations

* shm_size might need to be set to 2GB or more if you experience crashes
