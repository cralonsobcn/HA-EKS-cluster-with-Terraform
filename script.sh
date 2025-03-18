#!/usr/bin/env bash

# Verify AWS CLI prerequisite
aws_path="/usr/local/bin/aws"
if [ ! -x ${aws_path} ]
then
    echo "[INFO]: Downloading and installing AWS CLI"
    eval $(curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip")
    eval $(unzip awscliv2.zip)
    eval $(./aws/install)
else
    echo "[INFO]: AWS CLI Already installed"
fi

# Verify Terraform CLI prerequisite
terraform_path="/usr/local/bin/terraform"
if [ ! -x ${terraform_path} ]
then
    echo "[INFO]: Downloading and installing Terraform"
    eval $(wget https://releases.hashicorp.com/terraform/1.11.1/terraform_1.11.1_linux_amd64.zip)
    eval $(unzip terraform_1.11.1_linux_amd64.zip)
    eval $(mv terraform/ ${terraform_path})
    eval $(terraform -install-autocomplete)
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

# Sets Terraform folder structure
folder_list=("terraform" "terraform/dev" "terraform/test" "terraform/prod" "terraform/modules")
for folder in ${folder_list[@]}
do
    if [ ! -d "${PWD}/${folder}" ]
    then
        mkdir "${PWD}/${folder}"
        echo "[INFO]:  Adding ${PWD}/${folder} folder."
    else
        echo "[INFO]: ${PWD}/${folder} already exists"
    fi
done

# S3 bucket to store TF state
BUCKET="cralonso-tfpipeline-eks-project"
aws_region="us-east-1"
if [ ! $(aws s3 ls | grep ${BUCKET}) ] 
then
    aws s3 mb s3://${BUCKET}
    aws s3api put-bucket-versioning --bucket ${BUCKET} --versioning-configuration Status=Enabled
else
    echo "[INFO]: ${BUCKET} already exists"
fi

# Generate key pair if necessary and export it to the Terraform variable
if [ ! "${HOME}/.ssh/id_rsa" ]
then
    echo "[INFO]: Generating a new key pair and exporting the public key to TF_VAR"
    ssh-keygen -t rsa -N "" -f "${HOME}/.ssh/id_rsa"
    export TF_VAR_dataplane_public_key="$(cat ${HOME}/.ssh/id_rsa.pub)"
else
    export TF_VAR_dataplane-public-key="$(cat ${HOME}/.ssh/id_rsa.pub)"
    echo "[INFO]: Key already present. Exporting the public key to TF_VAR"
fi
