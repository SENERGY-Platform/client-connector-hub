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
        else
            echo "(hub-updater) up-to-date" | log
            return 2
        fi
    else
        echo "(hub-updater) checking for updates - failed" | log
        return 1
    fi
}


pullImage() {
    if docker-compose pull "$1" > /dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}


containerRunningState() {
    status=$(curl -G --silent --unix-socket "/var/run/docker.sock" --data-urlencode 'filters={"name": ["'$1'"]}' "http:/v1.40/containers/json" | jq -r '.[0].State')
    if [[ $status = "running" ]]; then
        return 0
    else
        return 1
    fi
}


redeployContainer() {
    if docker-compose up -d "$1" > /dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}


updateImages() {
    if curl --silent --fail --unix-socket "/var/run/docker.sock" "http:/v1.40/info" > /dev/null; then
        echo "(hub-updater) checking for images to update ..." | log
        images=$(curl --silent --unix-socket "/var/run/docker.sock" "http:/v1.40/images/json")
        num=$(echo $images | jq -r 'length')
        for ((i=0; i<=$num-1; i++)); do
            img_info=$(echo $images | jq -r ".[$i].RepoTags[0],.[$i].Id")
            docker_reg=$(echo $img_info | cut -d' ' -f1 | cut -d'/' -f1)
            if [[ $docker_reg == *"uni-leipzig.de"* ]]; then
                img_hash=$(echo $img_info | cut -d' ' -f2)
                img_name=$(echo $img_info | cut -d' ' -f1 | cut -d'/' -f2 | cut -d':' -f1)
                img_tag=$(echo $img_info | cut -d' ' -f1 | cut -d'/' -f2 | cut -d':' -f2)
                if curl --silent --fail "https://$docker_reg/v2" > /dev/null; then
                    echo "($img_name) checking for updates ..." | log
                    remote_img_hash=$(curl --silent --header "Accept: application/vnd.docker.distribution.manifest.v2+json" "https://$docker_reg/v2/$img_name/manifests/$img_tag" | jq -r '.config.digest')
                    if ! [ "$img_hash" = "$remote_img_hash" ]; then
                        echo "($img_name) pulling new image ..." | log
                        if pullImage "$img_name"; then
                            echo "($img_name) pulling new image successful" | log
                            if containerRunningState "$img_name"; then
                                echo "($img_name) redeploying container ..." | log
                                if redeployContainer $img_name; then
                                    echo "($img_name) redeploying container successful" | log
                                    docker image prune -f > /dev/null 2>&1
                                else
                                    echo "($img_name) redeploying container failed" | log
                                fi
                            fi
                        else
                            echo "($img_name) pulling new image failed" | log
                        fi
                    else
                        echo "($img_name) up-to-date" | log
                    fi
                else
                    echo "($img_name) can't reach docker registry '$docker_reg'" | log
                fi
            fi
        done
        return 0
    else
      echo "(hub-updater) docker engine not running" | log
      return 1
    fi
}


delay=600

if ! [ -z "$1" ]; then
    delay=$1
fi

hub_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

cd $hub_dir

echo "***************** starting client-connector-hub-updater *****************" | log
echo "(hub-updater) running in '$hub_dir' with PID: '$$'" | log

while true; do
    sleep $delay
    if updateSelf; then
        ./updater.sh $delay &
        echo "(hub-updater) restarting ..." | log
        break
    fi
    updateImages
done

exit 0
