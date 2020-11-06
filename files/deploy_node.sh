#!/bin/bash

echo -e "\nmaster01 192.168.0.2\nnode01 192.168.0.3\nnode02 192.168.0.4" | sudo tee -a /etc/hosts

sudo apt update
sudo apt install apt-transport-https curl -y

cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sudo sysctl --system

sudo swapoff -a
echo "vm.swappiness=0" | sudo tee -a /etc/sysctl.conf

curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
cat <<EOF | sudo tee /etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF

sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl

sudo curl https://get.docker.com | bash
sudo gpasswd -a master docker
