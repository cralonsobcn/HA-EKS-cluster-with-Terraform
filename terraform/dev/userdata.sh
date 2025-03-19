#!/usr/bin/env bash
set -o xtrace
mkdir -p /etc/eks
wget https://github.com/dbt-labs/amazon-eks-ami/blob/master/files/bootstrap.sh -O /etc/eks/bootstrap.sh # Amazon Linux 2 does not have this script
bash /etc/eks/bootstrap.sh eks-demo

# container runtime
yum install -y docker
systemctl --now enable docker

# kubectl
cat <<EOF | sudo tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://pkgs.k8s.io/core:/stable:/v1.32/rpm/
enabled=1
gpgcheck=1
gpgkey=https://pkgs.k8s.io/core:/stable:/v1.32/rpm/repodata/repomd.xml.key
exclude=kubelet kubectl cri-tools kubernetes-cni
EOF
yum install -y kubelet kubeadm kubectl --disableexcludes=kubernetes
yum install bash-completion
echo 'source <(kubectl completion bash)' >>~/.bashrc
echo 'alias k=kubectl' >>~/.bashrc
echo 'complete -o default -F __start_kubectl k' >>~/.bashrc
systemctl enable --now kubelet
systemctl daemon-reload