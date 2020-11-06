#!/bin/bash

chmod 0600 ~/.ssh/id_rsa
chmod 0644 ~/.ssh/id_rsa.pub

cat >> ~/.ssh/config << EOF
Host *
	StrictHostKeyChecking no
EOF

echo -e "\nmaster01 192.168.0.2\nnode01 192.168.0.3\nnode02 192.168.0.4" | sudo tee -a /etc/hosts

sudo apt update
sudo apt install software-properties-common apt-transport-https curl -y
sudo apt install ansible -y

sudo sed -i '0,/^#inventory.*/s//inventory = \/home\/master\/.ansible\/inventory/' /etc/ansible/ansible.cfg

mkdir -p ~/.ansible/inventory

cat >> ~/.ansible/inventory/hosts << EOF
[kube-cluster:children]
master
node

[master]
master01

[node]
node01
node02
EOF

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

scp deploy_node.sh node01:/home/master
scp deploy_node.sh node02:/home/master

ssh node01 sudo bash deploy_node.sh
ssh node02 sudo bash deploy_node.sh

sudo kubeadm init
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

kubectl taint nodes --all node-role.kubernetes.io/master-

kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"

join="$(kubeadm token create --print-join-command)"

ssh node01 sudo $join 
ssh node02 sudo $join 
