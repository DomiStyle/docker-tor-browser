# Tor
<p align="center">
  <img width="300px" src="https://upload.wikimedia.org/wikipedia/commons/8/8f/Tor_project_logo_hq.png">
</p

# Table of Contents
   
<details><summary>Docker</summary>

- [Docker Compose Script](#Docker-Compose-Script)
- [Docker Container Commands](#Docker-Container-Commands)
- [Docker Installation](#How-to-install-Docker)

</details>
   
<details><summary>Configuration</summary>

- [Platform configuration](#Platform-configuration)
- [Browser configuration](#Browser-configuration)
 
</details>

<details><summary>Others</summary>
   
- [Volumes](#Volumes)
- [Port](#Port)
- [Issues And limitations](#Issues-And-limitations)

</details>

![](https://github.com/DomiStyle/docker-tor-browser/raw/master/screenshot.png)
*Tor browser running inside of Firefox*

## About

This image allows running a [Tor browser](https://www.torproject.org/) instance on any headless server. The browser can be accessed via either a web interface or directly from any VNC client.

Container is based on [baseimage-gui](https://github.com/jlesage/docker-baseimage-gui) by [jlesage](https://github.com/jlesage)

Both amd64 and arm64 container runtimes are supported, but only the amd64 image uses an official build of the Tor Browser. The arm64 image uses an [unofficial build via tor-browser-ports](https://sourceforge.net/projects/tor-browser-ports/) because the Tor Project does not have an official arm build of the Tor Browser. Both the official and unofficial builds are signed, and the signatures are verified when building this container.

# Usage

See the docker-compose [here](https://github.com/DomiStyle/docker-tor-browser/blob/master/docker-compose.yml) or use this command

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
# Docker Compose Script
```yaml
version: '3.9'

services:
  tor:
    image: domistyle/tor-browser
    container_name: tor
    restart: unless-stopped
    ports:
      - 5800:5800
      - 5900:5900
    environment:
      DISPLAY_WIDTH: 1920
      DISPLAY_HEIGHT: 1080
      KEEP_APP_RUNNING: 1
      TZ: Europe/Vienna
```

# Docker Container Commands
 To install tor browser using docker compose, copy and paste the command in your terminal
```bash
docker compose up
```
To stop the docker container do
```bash
docker stop tor
```
To start the container again, put the following command below and paste it in your terminal 
```bash
docker start tor
```
To remove the container you can do 
```bash
docker compose down
```
or you can do this
``` 
docker rm tor
```
# How to install Docker
First update all your packages by doing
```bash
sudo apt update
```
After you update all your packages then it is time to install docker.io by doing 
```bash
sudo apt install -y docker.io
```
To add systemctl to docker do this
```bash
sudo systemctl enable docker --now
```
To verify that you docker put the following command below
```bash
docker
```
To use docker without doing sudo every time do this
```bash
sudo usermod -aG docker $USER
```


## Port

| Port       | Description                                  |
|------------|----------------------------------------------|
| `5800` | Provides a web interface to access the Tor browser |
| `5900` | Provides direct access to the NoVNC server |

## Issues And limitations

* shm_size might need to be set to 2GB or more if you experience crashes
### Github user who updated this markdown:
[GitXpresso](https://github.com/GitXpresso)
