# Tor browser
![](https://github.com/DomiStyle/docker-tor-browser/blob/master/screenshot.png)
*Tor browser running inside of Firefox*

## About

This image allows running a [Tor browser](https://www.torproject.org/) instance on any headless server. The browser can be accessed via either a web interface or directly from any VNC client.

Container is based on [baseimage-gui](https://github.com/jlesage/docker-baseimage-gui) by [jlesage](https://github.com/jlesage)

Both amd64 and arm64 (aarch64) container runtimes are supported. Both builds are signed, and the signatures are verified when building this container.

# Usage

See the [docker-compose](https://github.com/DomiStyle/docker-tor-browser/blob/master/docker-compose.yml) or use this command:

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

** For advanced configuration options please take a look at the [jlesage baseimage environment variable documentation](https://github.com/jlesage/docker-baseimage-gui#environment-variables).**

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
| `9150` | SOCK5 Proxy (not exposed by default) |


## Using Curl

Under the Tor Browser there is a SOCK5 proxy which may be use separately. You can EXPOSE port 9150 in [docker-compose.yml] to use the proxy externally or use it inside the container, like so:

```
docker compose exec tor_browser /bin/bash
curl --socks5-hostname localhost:9150 https://...
```

Many Tor sites have broken or out-of-date SSL certificates on their web site, so if you want to ignore those errors then add **--insecure** to the `curl` command.

## Issues & limitations

* shm_size might need to be set to 2GB or more if you experience crashes
