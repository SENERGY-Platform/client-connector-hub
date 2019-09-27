client-connector-hub
================

Manage client-connectors via docker compose.

----------

+ [List of managed client-connectors](#list-of-managed-client-connectors)
+ [Deployment](#deployment)
+ [Hub structure](#hub-structure)
+ [Configure](#configure)
+ [Manage](#manage)
+ [Troubleshoot](#troubleshoot)

----------

### List of managed client-connectors:

+ [blebox-cc](https://github.com/SENERGY-Platform/blebox-connector/tree/dev)
+ [hue-bridge-cc](https://github.com/SENERGY-Platform/hue-bridge-connector/tree/dev)
+ [lifx-cc](https://github.com/SENERGY-Platform/lifx-connector/tree/dev)
+ [smart-meter-cc](https://github.com/SENERGY-Platform/smart-meter-connector/tree/dev)
+ [test-cc](https://github.com/SENERGY-Platform/test-client-connector)
+ [z-way-cc](https://github.com/SENERGY-Platform/zway-connector)

### Deployment

Replace `####` with one of the names listed above or with a service name from `docker-compose.yml`.

#### Build client-connector

`docker-compose build --no-cache #### && docker image prune -f`

#### Run client-connector

`docker-compose up -d ####`

#### Build and run client-connector

`docker-compose build --no-cache #### && docker-compose up -d #### && docker image prune -f`


### Hub structure

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


### Configure

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

Device / service types and other device specific configurations are stored in `####.conf`. The fields will vary depending on the client-connector but Device / service types can be set under the `[Senergy]` section. Device types can be identified by a `dt_` prefix and service types by `st_`.

    [Senergy]
    dt_actuator =
    st_actuate =


### Manage

For easy client-connector management `portainer` can be used to start, stop, restart and delete containers.
All client-connectors logs can be accessed via `docker logs` or `portainer`.


### Troubleshoot

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
