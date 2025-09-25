# Tor browser

<img width="1919" height="893" alt="image" src="https://github.com/user-attachments/assets/839ee12d-ffea-4391-a2d8-d8dc4c2bc22c" />

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

It is not recommended to add persistent volumes to your Tor Browser. We do not support any issues that arise from persistent volumes.

## Ports

| Port       | Description                                  |
|------------|----------------------------------------------|
| `5800` | Provides a web interface to access the Tor browser |
| `5900` | Provides direct access to the VNC server |

## Issues & limitations

* shm_size might need to be set to 2GB or more if you experience crashes
