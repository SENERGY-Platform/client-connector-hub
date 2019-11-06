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

log() {
    first=1
    while read -r line; do
        if [ "$first" -eq "1" ]; then
            echo "[$(date +"%m.%d.%Y %I:%M:%S %p")] $line" >> $hub_dir/updater.log 2>&1
            first=0
        else
            echo "$line" >> $hub_dir/updater.log 2>&1
        fi
    done
}


hub_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $hub_dir
echo "(hub-updater) running in '$hub_dir'" | log


checkUrl() {
    if curl --silent --fail "$1" > /dev/null; then
        return 0
    else
        return 1
    fi
}


updateSelf() {
    echo "(hub-updater) checking for updates ..." | log
    update_result=$(git remote update 3>&1 1>&2 2>&3 >/dev/null)
    if ! [[ $update_result = *"fatal"* ]] || ! [[ $update_result = *"error"* ]]; then
        status_result=$(git status)
        if [[ $status_result = *"behind"* ]]; then
            echo "(hub-updater) downloading and applying updates ..." | log
            pull_result=$(git pull 3>&1 1>&2 2>&3 >/dev/null)
            if ! [[ $pull_result = *"fatal"* ]] || ! [[ $pull_result = *"error"* ]]; then
                echo "(hub-updater) update success" | log
                return 0
            else
                echo "(hub-updater) $pull_result" | log
                return 1
            fi
        fi
    else
        echo "(hub-updater) checking for updates - failed" | log
        return 1
    fi
}


pullImage() {
    if docker-compose pull "$1" > /dev/null; then
        return 0
    else
        return 1
    fi
}


containerRunningState() {
    status=$(curl -G --silent --unix-socket "/var/run/docker.sock" --data-urlencode "filters={""name"": [""$1""]}" "http:/v1.40/containers/json" | jq -r '.[0].State')
    if [[ $status = "running" ]]; then
        return 0
    else
        return 1
    fi
}

updateImages() {
    echo "(hub-updater) checking docker engine ..." | log
    if curl --silent --fail --unix-socket /var/run/docker.sock http:/v1.40/info; then
        echo "(hub-updater) checking for images to update ..." | log
        images=$(curl --silent --unix-socket /var/run/docker.sock http:/v1.40/images/json)
        num=$(echo $images | jq -r 'length')
        for ((i=0; i<=$num-1; i++)); do
            img_info=$(echo $images | jq -r ".[$i].RepoTags[0],.[$i].Id")
            docker_reg=$(echo $img_info | cut -d' ' -f1 | cut -d'/' -f1)
            if [[ $docker_reg == *"uni-leipzig.de"* ]]; then
                img_hash=$(echo $img_info | cut -d' ' -f2)
                img_name=$(echo $img_info | cut -d' ' -f1 | cut -d'/' -f2 | cut -d':' -f1)
                img_tag=$(echo $img_info | cut -d' ' -f1 | cut -d'/' -f2 | cut -d':' -f2)
                remote_img_hash=$(curl --silent --header "Accept: application/vnd.docker.distribution.manifest.v2+json" "https://$docker_reg/v2/$img_name/manifests/$img_tag" | jq -r '.config.digest')
                if ! [ "$img_hash" = "$remote_img_hash" ]; then
                    $(cd client-connector-hub && docker-compose pull "$img_name" && docker-compose up -d "$img_name" && docker image prune -f)
                fi
            fi
        done
    else
      echo "(hub-updater) docker engine not running" | log
      return 1
    fi
}

updateSelf
