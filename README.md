# client-connector-hub

 - [Hub](#hub)
	 - [Structure](#structure)
	 - [Installation](#installation)
	 - [Configuration](#configuration)
	 - [Update](#update)
	 - [Environment](#environment)
 - [Client-Connectors](#client-connectors)
	 - [List of managed client-connectors](#list-of-managed-client-connectors)
	 - [Deployment](#deployment)
	 - [Configuration](#configuration)
	 - [Management](#management)
	 - [Troubleshoot](#troubleshoot)

## Hub

### Structure

    client-connector-hub
        |
        |--- docker-compose.yml
        |
        |--- updater.sh
        |
        |--- load_env.sh
        |
        |--- hub.conf
        |
        |--- logs
        |        |
        |        |--- updater.log
        |        |
        |        |--- ...
        |
        |--- ####-cc
        |        |
        |        |--- cc-lib
        |        |        |
        |        |        |--- connector.conf
        |        |
        |        |--- storage
        |                 |
        |                 |--- ####.conf
        |                 |
        |                 |--- ...
        |
        |--- ...

### Installation

Clone this repository to your preferred location (for example `/opt/client-connector-hub`):

`git clone https://github.com/SENERGY-Platform/client-connector-hub.git`

Navigate to the repository you just created and choose **one** of the options below.

 - Install automatic updates and hub environment:
	 - With root privileges run `./updater.sh install`.
 - Install hub environment only:
	 - With root privileges run `./load_env.sh install`.

Reboot or reload your session for changes to take effect.

---

### Configuration

The hub environment and updater can be configured via the `$CC_HUB_PATH/hub.conf` file:

 - `CC_HUB_ENVIRONMENT` set to either `dev` or `prod`.
 - `CC_REGISTRY` address of docker registry.
 - `CC_HUB_UPDATER_DELAY` control how often automatic updates run.
 - `CC_HUB_UPDATER_LOG_LVL` set logging level for automatic updater. (`0`: debug, `1`: info, `2`: warning, `3`: error)

---

### Update

**Automatic**

Client-connectors and the local client-connector-hub repository can be automatically updated with the provided `updater.sh` script. The script will run in the background and periodically check if new client-connector versions are available or if the client-connector-hub repository needs to be updated. If the client-connector-hub repository has been updated the script will restart for changes to take effect. New client-connector versions will be downloaded and redeployed.

To start automatic updates execute: `sudo systemctl start cc-hub-updater.service`.

Logs will be written to `$CC_HUB_PATH/logs/updater.log` and rotated every 24h.

**Manual**

If updates are handled manually run `$CC_HUB_PATH/load_env.sh update` after every `git pull` and reload your session.

---

### Environment

The following environment variables are provided by the hub and can be used by developers:

 - `CC_HUB_HOST_IP` the IP address assigned to the docker host.
 - `CC_HUB_PATH` path to hub.

---

## Client-Connectors

### List of managed client-connectors

- [blebox-cc](https://github.com/SENERGY-Platform/blebox-connector)
- [hue-bridge-cc](https://github.com/SENERGY-Platform/hue-bridge-connector)
- [lifx-cc](https://github.com/SENERGY-Platform/lifx-connector)
- [smart-meter-cc](https://github.com/SENERGY-Platform/smart-meter-connector)
- [test-cc](https://github.com/SENERGY-Platform/test-client-connector)
- [z-way-cc](https://github.com/SENERGY-Platform/zway-connector)

---

### Deployment

Navigate to the client-connector-hub dictionary `cd $CC_HUB_PATH` and replace `####` with one of the names listed above or with a service name from `docker-compose.yml`.

 - Install client-connector: `docker-compose pull ####`
 - Run client-connector: `docker-compose up -d ####`
 - Install and run client-connector: `docker-compose pull #### && docker-compose up -d ####`
 - Cleanup old images: `docker image prune -f`

---

### Configuration

All client-connectors except the Z-Way client-connector can be configured via the two config files `connector.conf` and `####.conf`.
Configuration files will be generated on container startup. The container will restart after a config file is created.

For configuration changes to take effect the corresponding client-connector container must be restarted.

**Communication configuration**

Communication and platform related configurations are stored in `$CC_HUB_PATH/####-cc/cc-lib/connector.conf`. The following fields must be set by the user:

    [connector]
    host =
    port =
    tls = False

    [auth]
    host =
    path =
    id =

    [credentials]
    user =
    pw =

    [api]
    host =
    hub_endpt =
    device_endpt =

    [hub]
    id = #leave blank for new ID or use ID of existing hub

    [device]
    id_prefix = #leave blank for new prefix or use an existing prefix

**Specific configuration**

Device types and other device specific configurations are stored in `$CC_HUB_PATH/####-cc/storage/####.conf`. The fields will vary depending on the client-connector but device types can be set under the `[Senergy]` section. Device types can be identified via the `dt_` prefix.

    [Senergy]
    dt_actuator =

---

### Management

For easy client-connector management `portainer` can be used to start, stop, restart and delete containers.
All client-connectors logs can be accessed via `docker logs` or `portainer`.

---

### Troubleshoot

- z-way-cc
	- The Z-Way client-connector can only be configured via the Z-Way web ui.
	- When in- / or excluding Z-Wave devices disable the client-connector plugin.
- blebox-cc
	- If devices have been removed from the platform delete the local database at `$CC_HUB_PATH/blebox-cc/storage/devices.sqlite3` and restart the container.
- smart-meter-cc
	- If a device is offline but connected locally the local serial port names might have changed. A local system reboot should fix the issue.
- connecting a device not allowed after adding device
	- Log message: "ERROR: [connector.client] connecting device ‘xyz’ to platform failed - not allowed"
	- Restart the container.
