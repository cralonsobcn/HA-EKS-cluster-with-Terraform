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
    if [ ! -d "${HOME}/${folder}" ]
    then
        mkdir "${HOME}/${folder}"
    else
        echo "[INFO]: ${HOME}/${folder} already exists"
    fi
done

# At this point you should have an AWS account and have that account logged in with the AWS CLI

# TODO Create an AWS Access Key and Secret Key to allow Terraform deploy resources in AWS
aws_user=$(aws iam get-user | jq -r '.User.UserName')
aws_region="us-east-1"
aws_output=$(aws iam create-access-key --user-name ${aws_user} --region ${aws_region}) 
TF_VAR_AWS_ACCESS_KEY=$(echo "${aws_output}" | jq -r '.AccessKey.AccessKeyId') # Env
TF_VAR_AWS_SECRET_KEY=$(echo "${aws_output}" | jq -r '.AccessKey.SecretAccessKey') # Env


# S3 bucket to store TF state
bucket="cralonso-tfpipeline-eks-project"
aws_region="us-east-1"
if [ ! eval $(aws s3 ls) ] # TODO filter json output
then
    eval $(aws s3 mb s3://${bucket})
    eval $(aws s3api put-bucket-versioning --bucket ${bucket} --versioning-configuration Status=Enabled)
else
    echo "[INFO]: ${bucket} already exists"
fi

