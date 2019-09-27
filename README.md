client-connector-hub
================

Manage client-connectors via docker compose.

----------

+ [List of current client-connectors](#list-of-current-client-connectors)
+ [Deployment](#deployment)
+ [Hub structure](#hub-structure)
+ [Configure](#configure)
+ [Manage](#manage)
+ [Troubleshoot](#troubleshoot)

----------

### List of current client-connectors:

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

    [hub]
    name =

    [api]
    host =
    hub_endpt =
    device_endpt =

#### Specific configuration

Device / service types and other device specific configurations are stored in `####.conf`. The fields will vary depending on the client-connector but Device / service types can be set under the `[Senergy]` section. Device types can be identified by a `dt_` prefix and service types by `st_`.

    [Senergy]
    dt_actuator =
    st_actuate =

### Manage


### Troubleshoot
