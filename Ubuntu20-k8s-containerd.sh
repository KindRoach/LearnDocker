#! /bin/bash

##########################################################
# Disable swap & add kernel settings
##########################################################

sudo swapoff -a

sudo nano /etc/fstab

cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

# sysctl params required by setup, params persist across reboots
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

# Apply sysctl params without reboot
sudo sysctl --system

# Fix ubuntu bug for resovling hostname on LAN
# refer to: https://askubuntu.com/a/1041631
sudo unlink /etc/resolv.conf
sudo ln -s /run/systemd/resolve/resolv.conf /etc/resolv.conf

##########################################################
# Install Containerd 
##########################################################

sudo apt-get update

sudo apt-get install -y docker.io

sudo apt-mark hold docker.io

# Install CNI network plugins
curl -fsSLo cni-plugins-linux-amd64-v1.1.1.tgz \
https://github.com/containernetworking/plugins/releases/download/v1.1.1/cni-plugins-linux-amd64-v1.1.1.tgz

sudo rm -rf /opt/cni/bin
sudo mkdir -p /opt/cni/bin
sudo tar Cxzvf /opt/cni/bin cni-plugins-linux-amd64-v1.1.1.tgz

##########################################################
# Install Kubernetes components Kubectl, kubeadm & kubelet
##########################################################

sudo apt-get install -y apt-transport-https ca-certificates curl

sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg

echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list

sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl ipvsadm
sudo apt-mark hold kubelet kubeadm kubectl ipvsadm

# Pull k8s Container
sudo kubeadm config images pull
