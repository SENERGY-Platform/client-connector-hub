client-connector-hub
================

Manage client-connectors via docker compose.

----------

+ [List of managed client-connectors](#list-of-managed-client-connectors)
+ [Installation](#installation)
+ [Deployment](#deployment)
+ [Hub structure](#hub-structure)
+ [Configure](#configure)
+ [Manage](#manage)
+ [Updater](#updater)
+ [Troubleshoot](#troubleshoot)

----------


List of managed client-connectors:
-----------------

+ [blebox-cc](https://github.com/SENERGY-Platform/blebox-connector)
+ [hue-bridge-cc](https://github.com/SENERGY-Platform/hue-bridge-connector)
+ [lifx-cc](https://github.com/SENERGY-Platform/lifx-connector)
+ [smart-meter-cc](https://github.com/SENERGY-Platform/smart-meter-connector)
+ [test-cc](https://github.com/SENERGY-Platform/test-client-connector)
+ [z-way-cc](https://github.com/SENERGY-Platform/zway-connector)


Installation
-----------------

Clone this repository to `/opt/client-connector-hub` (with root privileges) or your preferred location:

`cd /opt && git clone https://github.com/SENERGY-Platform/client-connector-hub.git`

Next setup the following environment variables (e.g. `/etc/environment`):

`CC_REPO` address of docker registry.

`CC_HUB_ENVIRONMENT` set to either `dev` or `prod`.

For automatic updates please see the [Updater](#updater) section.


Deployment
-----------------

Replace `####` with one of the names listed above or with a service name from `docker-compose.yml`.

#### Build client-connector

`docker-compose build --no-cache #### && docker image prune -f`

#### Run client-connector

`docker-compose up -d ####`

#### Build and run client-connector

`docker-compose build --no-cache #### && docker-compose up -d #### && docker image prune -f`


Hub structure
-----------------

    client-connector-hub
        |
        |--- docker-compose.yml
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


Configure
-----------------

All client-connectors except the Z-Way client-connector can be configured via the two config files `connector.conf` and `####.conf`.
Configuration files will be generated on container startup. The container will restart after a config file is created.

For configuration changes to take effect the corresponding client-connector container must be restarted.

#### Communication configuration

Communication and platform related configurations are stored in `connector.conf`. The following fields must be set by the user:

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

#### Specific configuration

Device types and other device specific configurations are stored in `####.conf`. The fields will vary depending on the client-connector but device types can be set under the `[Senergy]` section. Device types can be identified via the `dt_` prefix.

    [Senergy]
    dt_actuator =


Manage
-----------------

For easy client-connector management `portainer` can be used to start, stop, restart and delete containers.
All client-connectors logs can be accessed via `docker logs` or `portainer`.


Updater
-----------------

Client-connectors and the local client-connector-hub repository can be automatically updated with the provided `updater.sh` script. The script will run in the background and periodically check if new client-connector versions are available or if the client-connector-hub repository needs to be updated. If the client-connector-hub repository has been updated the script will restart for changes to take effect. New client-connector versions will be downloaded and if a client-connector is currently running it will be redeployed.

To install the updater execute `./updater.sh install` with root privileges.

If desired users can control how often the script will check for updates via the environment variable: `CC_HUB_UPDATER_DELAY`


Troubleshoot
-----------------

+ z-way-cc
  + The Z-Way client-connector can only be configured via the Z-Way web ui.
  + When in- / or excluding Z-Wave devices disable the client-connector plugin.
+ blebox-cc
  + If devices have been removed from the platform delete the local database at `client-connector-hub/blebox-cc/storage/devices.sqlite3` and restart the container.
+ smart-meter-cc
  + If a device is offline but connected locally the local serial port names might have changed. A local system reboot should fix the issue.
+ connecting a device not allowed after adding device
  + Log message: "ERROR: [connector.client] connecting device ‘xyz’ to platform failed - not allowed"
  + Restart the container.
