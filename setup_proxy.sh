#! /bin/bash

# add proxy to .bashrc
cat <<EOF >> ~/.bashrc

export http_proxy=http://192.168.50.62:10811
export https_proxy=http://192.168.50.62:10811
EOF

source ~/.bashrc

# add proxy to visudo
# Defaults env_keep="http_proxy https_proxy no_proxy"
sudo visudo

# add proxy to containerd systemd
sudo mkdir -p /etc/systemd/system/containerd.service.d
sudo cat <<EOF | sudo tee /etc/systemd/system/containerd.service.d/override.conf
[Service]
Environment="http_proxy=http://192.168.50.62:10811"
Environment="https_proxy=http://192.168.50.62:10811"
EOF
