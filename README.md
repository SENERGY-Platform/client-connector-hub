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
+ [smart-meter-cc](https://github.com/SENERGY-Platform/smart-meter-connector)
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



### Configure


### Manage


### Troubleshoot
