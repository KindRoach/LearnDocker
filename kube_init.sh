#! /bin/bash

MASERT_IP=192.168.50.143
sudo kubeadm init \
    --apiserver-advertise-address=$MASERT_IP \
    --control-plane-endpoint=$MASERT_IP \
    --pod-network-cidr=10.244.0.0/16 

mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

kubectl get nodes

kubectl get pods --all-namespaces -o wide

kubectl apply -f https://raw.githubusercontent.com/flannel-io/flannel/master/Documentation/kube-flannel.yml