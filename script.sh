#!/usr/bin/env bash

# Sets Terraform folder structure
folder_list=("terraform" "terraform/dev" "terraform/test" "terraform/prod" "terraform/modules")

for folder in ${folder_list[@]}
do
    if [ ! -d "${HOME}/${folder}" ]
    then
        mkdir "${HOME}/${folder}"
    else
        echo "${HOME}/${folder} already exists"
    fi
done

# S3 bucket to store TF state
bucket="cralonso-tfpipeline-eks-project"
region="us-east-1"

if [ ! eval $(aws s3 ls) ]
then
    eval $(aws s3 mb s3://${bucket} --region ${region})
    eval $(aws s3api put-bucket-versioning --bucket ${bucket} --versioning-configuration Status=Enabled)
else
    echo "${bucket} already exists"
fi

