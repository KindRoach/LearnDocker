#! /bin/bash

nano ~/.bashrc
~/.bashrc

# add proxy to .bashrc
# export http_proxy=http://192.168.50.62:10811
# export https_proxy=http://192.168.50.62:10811
# export no_proxy="localhost,127.0.0.1"

# add proxy to visudo
# Defaults env_keep="http_proxy https_proxy no_proxy"
sudo visudo

sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl

#####################################
# Install containerd
#####################################

# create configuration file
curl -fsSLo containerd-config.toml \
https://gist.githubusercontent.com/oradwell/31ef858de3ca43addef68ff971f459c2/raw/5099df007eb717a11825c3890a0517892fa12dbf/containerd-config.toml

sudo mkdir /etc/containerd
sudo mv containerd-config.toml /etc/containerd/config.toml

# Extract the binaries
curl -fsSLo containerd-1.6.6-linux-amd64.tar.gz \
https://github.com/containerd/containerd/releases/download/v1.6.6/containerd-1.5.13-linux-amd64.tar.gz

sudo tar Cxzvf /usr/local containerd-1.6.6-linux-amd64.tar.gz

# Install containerd as a service
sudo curl -fsSLo /etc/systemd/system/containerd.service \
https://raw.githubusercontent.com/containerd/containerd/main/containerd.service

sudo systemctl daemon-reload
sudo systemctl enable --now containerd

# Install runc
curl -fsSLo runc.amd64 \
https://github.com/opencontainers/runc/releases/download/v1.1.3/runc.amd64

sudo install -m 755 runc.amd64 /usr/local/sbin/runc

# Install CNI network plugins
curl -fsSLo cni-plugins-linux-amd64-v1.1.1.tgz \
https://github.com/containernetworking/plugins/releases/download/v1.1.1/cni-plugins-linux-amd64-v1.1.1.tgz

sudo mkdir -p /opt/cni/bin
sudo tar Cxzvf /opt/cni/bin cni-plugins-linux-amd64-v1.1.1.tgz

# Install nerdctl (CLI)
wget https://github.com/containerd/nerdctl/releases/download/v0.22.0/nerdctl-0.22.0-linux-amd64.tar.gz
sudo tar Cxzvf /usr/local/bin nerdctl-0.22.0-linux-amd64.tar.gz

#####################################
# Forward IPv4 and let iptables see bridged network traffic
#####################################

cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

sudo modprobe -a overlay br_netfilter

# sysctl params required by setup, params persist across reboots
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

# Apply sysctl params without reboot
sudo sysctl --system

#####################################
# Install kubeadm, kubelet & kubectl
#####################################

# Add Kubernetes GPG key
sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg \
  https://packages.cloud.google.com/apt/doc/apt-key.gpg

# Add Kubernetes apt repository
echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" \
  | sudo tee /etc/apt/sources.list.d/kubernetes.list

# Fetch package list
sudo apt-get update

sudo apt-get install -y kubelet kubeadm kubectl

# Prevent them from being updated automatically
sudo apt-mark hold kubelet kubeadm kubectl

#####################################
# Ensure swap is disabled
#####################################

# See if swap is enabled
swapon --show

# Turn off swap
sudo swapoff -a

# Disable swap completely
sudo sed -i -e '/swap/d' /etc/fstab