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

echo "installing client-connector-hub-updater systemd service ..."
if cp cc-hub-updater.service /etc/systemd/system/cc-hub-updater.service; then
    if chmod 664 /etc/systemd/system/cc-hub-updater.service; then
        echo "successfully installed"
        echo "reloading daemon ..."
        if systemctl daemon-reload; then
            echo "enabling client-connector-hub-updater systemd service ..."
            if systemctl enable cc-hub-updater.service; then
                echo "successfully enabled"
            else
                echo "enabling service failed"
            fi
        else
            echo "reloading daemon failed"
        fi
    else
        echo "setting premissions failed"
    fi
else
    echo "copying service failed"
fi
