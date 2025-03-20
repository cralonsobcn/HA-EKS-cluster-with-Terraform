#!/usr/bin/env bash
set -o xtrace
set -o pipefail
set -o nounset
set -o errexit

export CLUSTER_NAME="eks-demo"
export REGION="us-east-1"
export BUCKET="cralonso-tfpipeline-eks-project"
export TERRAFORM_PATH="/usr/local/bin/terraform"
export AWS_PATH="/usr/local/bin/aws"

# Verify AWS CLI prerequisite
if [ ! -x ${AWS_PATH} ]
then
    echo "[INFO]: Downloading and installing AWS CLI"
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip awscliv2.zip
    ./aws/install
else
    echo "[INFO]: AWS CLI Already installed"
fi

# Verify Terraform CLI prerequisite
if [ ! -x ${TERRAFORM_PATH} ]
then
    echo "[INFO]: Downloading and installing Terraform"
    wget https://releases.hashicorp.com/terraform/1.11.1/terraform_1.11.1_linux_amd64.zip
    unzip terraform_1.11.1_linux_amd64.zip
    mv terraform/ ${TERRAFORM_PATH}
    terraform -install-autocomplete
else
    echo "[INFO]: Terraform CLI Already installed"
fi

# Verify kubectl requirement
if [ ! -f "/etc/yum.repos.d/kubernetes.repo" ]
then
    cat <<EOF | sudo tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://pkgs.k8s.io/core:/stable:/v1.32/rpm/
enabled=1
gpgcheck=1
gpgkey=https://pkgs.k8s.io/core:/stable:/v1.32/rpm/repodata/repomd.xml.key
exclude=kubelet kubectl kubeadm cri-tools kubernetes-cni
EOF

    sudo dnf install -y kubelet kubeadm kubectl --disableexcludes=kubernetes
    dnf install bash-completion
    echo 'source <(kubectl completion bash)' >>~/.bashrc
    echo 'alias k=kubectl' >>~/.bashrc
    echo 'complete -o default -F __start_kubectl k' >>~/.bashrc
    systemctl enable --now kubelet
else
    echo "[INFO]: Kubernetes repo already installed."
fi

# S3 bucket to store TF state
if [ ! $(aws s3 ls | grep ${BUCKET}) ]  # Impreve this conditional
then
    aws s3 mb s3://${BUCKET}
    aws s3api put-bucket-versioning --bucket ${BUCKET} --versioning-configuration Status=Enabled
else
    echo "[INFO]: ${BUCKET} already exists"
fi

# Generate key pair if necessary and export it to the Terraform variable
if [ ! -f "${PWD}/dataplane-kp.pem" ]
then
    echo "[INFO]: Generating a new key pair and exporting the public key to TF_VAR_dataplane_public_key"
    ssh-keygen -t rsa -N "" -f ${PWD}/dataplane-kp.pem
    export TF_VAR_dataplane_public_key=$(cat ${PWD}/dataplane-kp.pem.pub)
else
    export TF_VAR_dataplane-public_key="$(cat ${PWD}/dataplane-kp.pem.pub)"
    echo "[INFO]: Key already present. Exporting the public key to TF_VAR_dataplane_public_key"
fi
