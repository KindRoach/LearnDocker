#! /bin/bash

sudo kubeadm reset

rm -rf $HOME/.kube
sudo rm -rf /etc/cni/net.d
sudo ipvsadm --clear
sudo iptables -F
sudo iptables -t nat -F
sudo iptables -t mangle -F
sudo iptables -X
