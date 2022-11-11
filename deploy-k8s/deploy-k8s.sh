#!/bin/bash

# CTRL=${CTRL:-10.0.0.46}
# WORKER=${WORKER:-"10.0.0.25 10.0.0.51 10.0.0.5"}
if [ "x$CTRL" == "x" ] || [ "x$WORKER" == "x" ]
then
	echo "You must specify CTRL and WORKER to deploy kubernetes"
	echo "CTRL=\"192.168.0.1\" WORKER=\"192.168.0.2 192.168.0.3\" ./deploy-k8s.sh"
	exit 1
else
	echo "Deploy kubernetes on nodes master: $CTRL worker: $WORKER"
fi

# Settings
kubesprayversion="master"
export KUBE_MASTERS_MASTERS=1

# Install required packages
sudo apt install -y python3-pip python3-venv

# setup the kubespray run virtual env
python3 -m venv venv
source venv/bin/activate
git clone https://github.com/kubernetes-sigs/kubespray
cd kubespray
pip3 install -r requirements.txt
cp -rfp inventory/sample inventory/testbed
declare -a IPS=($CTRL $WORKER)
# echo ${IPS[@]}
CONFIG_FILE=inventory/testbed/hosts.yaml python3 contrib/inventory_builder/inventory.py ${IPS[@]}
ansible-playbook -i inventory/testbed/hosts.yaml  --become --become-user=root cluster.yml

# Set up the access config
scp $CTRL:/usr/local/bin/kubectl /tmp/
sudo mv /tmp/kubectl /usr/local/bin/
mkdir ~/.kube
ssh $CTRL sudo cat /etc/kubernetes/admin.conf > ~/.kube/config 
chmod 600 ~/.kube/config

kubectl get nodes -owide
