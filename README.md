# Tor browser

![](https://github.com/DomiStyle/docker-tor-browser/raw/master/screenshot.png)
*Tor browser running inside of Firefox*

## About

This image allows running a [Tor browser](https://www.torproject.org/) instance on any headless server. The browser can be accessed via either a web interface or directly from any VNC client.

Container is based on [baseimage-gui](https://github.com/jlesage/docker-baseimage-gui) by [jlesage](https://github.com/jlesage)

Both amd64 and arm64 container runtimes are supported, but only the amd64 image uses an official build of the Tor Browser. The arm64 image uses an [unofficial build via tor-browser-ports](https://sourceforge.net/projects/tor-browser-ports/) because the Tor Project does not have an official arm build of the Tor Browser. Both the official and unofficial builds are signed, and the signatures are verified when building this container.

# Usage

See the docker-compose [here](https://github.com/DomiStyle/docker-tor-browser/blob/master/docker-compose.yml) or use this command:

    docker run -d -p 5800:5800 domistyle/tor-browser

The web interface will be available on port 5800.

## Platform configuration

No special configuration is necessary, however some recommended variables are available:

| Variable  | Description | Default  | Required |
|-----------|-------------|----------|----------|
| `DISPLAY_WIDTH` | Set the width of the virtual screen | ``1280`` | No |
| `DISPLAY_HEIGHT` | Set the height of the virtual screen | ``768`` | No |
| `KEEP_APP_RUNNING` | Automatically restarts the Tor browser if it exits | ``0`` | No |
| `TZ` | Set the time zone for the container | - | No |

** For advanced configuration options please take a look [here](https://github.com/jlesage/docker-baseimage-gui#environment-variables).**

## Browser configuration

You may install the browser with your own configuration. Copy the template configuration to get started.
If `mozilla.cfg` is available then it is used, otherwise no browser changes are made.
```
cd browser-cfg
cp mozilla.cfg.template mozilla.cfg
```
** For more information on the available options: http://kb.mozillazine.org/About:config_entries

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

## Audio

This implementation uses PulseAudio which comes on Linux but can be installed on OSX.
If on Linux you can use it natively by:
   cp run/pulse-client.linux-native.conf run/pulse-client.conf
The OSX version uses sound over TCP with:
   cp run/pulse-client.any-tcp.conf run/pulse-client.conf

## Configuration

All the defaults are in run/tor.opts.default.sh, create run/tor.opts.sh and override the values you need for display size, memory and if you are using PulseAudio on OSX HOST_IP.
To run:
   run/tor

