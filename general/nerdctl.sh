#!/bin/bash

latest_version=$(curl -s https://api.github.com/repos/containerd/nerdctl/releases/latest | grep -o '"tag_name": "v.*"' | cut -d'"' -f4 | cut -c 2-)

wget https://github.com/containerd/nerdctl/releases/download/v$latest_version/nerdctl-$latest_version-linux-amd64.tar.gz

mkdir nerdctl
tar -xvf nerdctl-$latest_version-linux-amd64.tar.gz -C nerdctl

sudo mv nerdctl/nerdctl /usr/bin/

rm -rf nerdctl
rm -rf nerdctl-$latest_version-linux-amd64.tar.gz
