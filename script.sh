#!/usr/bin/env bash

# Verify AWS CLI prerequisite
aws_path="/usr/local/bin/aws"
if [ ! -x ${aws_path} ]
then
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
    eval $(wget https://releases.hashicorp.com/terraform/1.11.1/terraform_1.11.1_linux_amd64.zip)
    eval $(unzip terraform_1.11.1_linux_amd64.zip)
    eval $(mv terraform/ ${terraform_path})
    eval $(terraform -install-autocomplete)
else
    echo "[INFO]: Terraform CLI Already installed"
fi

# Sets Terraform folder structure
folder_list=("terraform" "terraform/dev" "terraform/test" "terraform/prod" "terraform/modules")
for folder in ${folder_list[@]}
do
    if [ ! -d "${PWD}/${folder}" ]
    then
        mkdir "${PWD}/${folder}"
    else
        echo "[INFO]: ${PWD}/${folder} already exists"
    fi
done

# S3 bucket to store TF state
TF_VAR_BUCKET="cralonso-tfpipeline-eks-project"
aws_region="us-east-1"
if [ ! $(aws s3 ls | grep ${TF_VAR_BUCKET}) ] 
then
    aws s3 mb s3://${TF_VAR_BUCKET}
    aws s3api put-bucket-versioning --bucket ${TF_VAR_BUCKET} --versioning-configuration Status=Enabled
else
    echo "[INFO]: ${TF_VAR_BUCKET} already exists"
fi

