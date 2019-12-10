#!/bin/bash

#   Copyright 2019 InfAI (CC SES)
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.


if ! command -v truncate >/dev/null 2>&1; then
    echo "dependency 'truncate' not installed"
    exit 1
fi
if ! command -v ip >/dev/null 2>&1; then
    echo "dependency 'ip' not installed"
    exit 1
fi


hub_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

conf_file="hub.conf"

conf_vars=(
    "CC_HUB_ENVIRONMENT=prod"
    "CC_REGISTRY="
    "CC_HUB_UPDATER_DELAY=600"
    "CC_HUB_UPDATER_LOG_LVL=1"
)

env_vars=(
    "CC_HUB_HOST_IP=$(ip -o -4 addr list eth0 | awk '{print $4}' | cut -d/ -f1)"
)


initHubConf() {
    truncate -s 0 $hub_dir/$conf_file
    for var in "${conf_vars[@]}"; do
        echo "$var" >> $hub_dir/$conf_file
    done
}


updateHubConf() {
    truncate -s 0 $hub_dir/$conf_file
    for var in "${conf_vars[@]}"; do
        var_name=$(echo "$var" | cut -d'=' -f1)
        if [[ -z "${!var_name}" ]]; then
            echo "$var" >> $hub_dir/$conf_file
        else
            echo "$var_name=${!var_name}" >> $hub_dir/$conf_file
        fi
    done
}


loadHubConf() {
    while IFS= read -r line; do
        export "$line"
    done < $hub_dir/$conf_file
}


loadHubEnv() {
  for var in "${env_vars[@]}"; do
      export "$var"
  done
}


if [[ -z "$1" ]]; then
    loadHubConf
    loadHubEnv
else
    case "$1" in
        install)
            echo "creating $conf_file ..."
            initHubConf
            exit 0
            ;;
        update)
            echo "updating $conf_file ..."
            loadHubConf
            updateHubConf
            exit 0
            ;;
        *)
            echo "unknown argument: '$1'"
            exit 1
    esac
fi
