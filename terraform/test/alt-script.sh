#!/usr/bin/env bash

# Access key and secret Key for TERRAFOM AWS Provider 

aws_user=$(aws iam get-user | jq -r '.User.UserName')
aws_region="us-east-1"
aws_output=$(aws iam create-access-key --user-name ${aws_user} --region ${aws_region}) 
TF_VAR_AWS_ACCESS_KEY=$(echo "${aws_output}" | jq -r '.AccessKey.AccessKeyId') # Env
TF_VAR_AWS_SECRET_KEY=$(echo "${aws_output}" | jq -r '.AccessKey.SecretAccessKey') # Env