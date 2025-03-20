# **Introduction**
This repo deploys a highly available EKS cluster with an Autoscaling Group in region *`us-east-1`* across 3 different Availability Zones.
Because I've used Kodekloud Playgrounds to elaborate this repo, some actions and resources were restricted or had technical limitations to avoid an excessive billing charge.

As consequence using specific module providers, machine types other than *`t2.micro`* or an up to date EKS optimized ami, for example, was not entirely possible.

**Technologies**:
- AWS
  - Networking
    -  VPC, Subnetting, Routing Tables, VPC Peering
 -  Compute
    -  EKS, Autoscaling Group, EC2
 -  Storage
    -  S3
 -  Security & Identity
    -  IAM Roles, IAM Policies
-  Git
-  Bash
-  Kubernetes
-  Terraform AWS Provider

![Diagram](HA-EKS.webp)

# **Prerequisites**

Run *`./script.sh`* to verify if you meet all the prerequisites. The script must be executable *`sudo chmod u+x script.sh`*.

The script checks if:
- [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) is installed.
- [Terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli) is installed.
- [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/#install-using-native-package-management) is installed.
- Defines the project structure.

```
📁 /
 ├──📁 terraform/
 |    ├── aws-auth-cm.yaml
 |    ├── controlplane.tf
 |    ├── dataplane.tf
 |    ├── iam.tf
 |    ├── networking.tf
 |    ├── providers.tf
 |    ├── variables.tf
 |    ├── userdata.sh
 ├── script.sh
 ├── kubelet.service
 ├── README.md
```


# Deployment
Generate SSH Key and pass it to the dataplane aws_launch_template through aws_key_pair.dataplane-kp by using TF_VAR_dataplane_key_pair.
`$ ssh-keygen -t rsa -N "" -f ${HOME}/dataplane-kp.pem`
`$ export TF_VAR_dataplane_public_key=$(cat "dataplane-kp.pem.pub")` 

Update kube-config to access the control plane via AWS CLI:
`$ aws eks update-kubeconfig --region us-east-1 --name my-cluster`

Join the dataplane nodes with the Controlplane with:
`$ kubectl apply -f aws-auth.yaml`



error: open /var/lib/kubelet/config.yaml: no such file or directory

/etc/systemd/system/kubelet.service
unknown flag: --container-runtime
unknown flag: --network-plugin

/etc/kubernetes/kubelet/kubelet-config.json
containerRuntimeEndpoint: "unix:///var/run/docker.sock"



# Prerequisites


```
- Create a S3 bucket to store the tfstate backend. Versioning must be enabled
- Create an AWS Access Key and Secret Key to allow Terraform deploy resources in AWS

# Best Practices


# Diagram

# **AWS High-Availability Portfolio Project: Step-by-Step Deployment Guide**

## **📌 Overview**

This guide outlines how to deploy a **high-availability AWS application** with **EKS, RDS, ECR, AWS Secrets Manager, and CodePipeline** using **Terraform and GitHub Actions**.

## **🚀 Step 1: Prerequisites**

### ✅ **Install Required Tools**

Ensure you have the following installed:

- [AWS CLI](https://aws.amazon.com/cli/)
- [kubectl](https://kubernetes.io/docs/tasks/tools/)
- [Terraform](https://developer.hashicorp.com/terraform/downloads)
- [GitHub CLI](https://cli.github.com/)

### ✅ **AWS IAM Setup**

- Create an **IAM User** with `AdministratorAccess`.
- Configure your AWS CLI:
  ```sh
  aws configure
  ```

## **🚀 Step 2: Set Up Terraform Backend**

Each environment (`dev`, `test`, `prod`) uses an **S3 bucket + DynamoDB for Terraform state**.

### **Create S3 Bucket and DynamoDB Table**

```sh
aws s3api create-bucket --bucket my-private-terraform-state --region us-east-1 --create-bucket-configuration LocationConstraint=us-east-1
aws dynamodb create-table --table-name terraform-locks --attribute-definitions AttributeName=LockID,AttributeType=S --key-schema AttributeName=LockID,KeyType=HASH --billing-mode PAY_PER_REQUEST
```

## **🚀 Step 3: Deploy Infrastructure with Terraform**

### **1️⃣ Clone the Repository**

```sh
git clone https://github.com/YOUR_GITHUB/aws-portfolio-project.git
cd aws-portfolio-project/terraform/dev
```

### **2️⃣ Initialize Terraform**

```sh
terraform init
```

### **3️⃣ Apply Terraform (Deploy AWS Services)**

```sh
terraform apply -var-file=terraform.tfvars -auto-approve
```

🔹 **This will create:** ✅ **VPC, Subnets, and Security Groups** ✅ **Amazon EKS Cluster** ✅ **Amazon RDS Aurora Database** ✅ **Amazon ECR Repository** ✅ **AWS Secrets Manager Entry for DB Credentials** ✅ **AWS CodePipeline for CI/CD**

## **🚀 Step 4: Push Docker Image to ECR**

### **1️⃣ Authenticate Docker to ECR**

```sh
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin <AWS_ACCOUNT_ID>.dkr.ecr.us-east-1.amazonaws.com
```

### **2️⃣ Build, Tag, and Push Image**

```sh
docker build -t my-app .
docker tag my-app:latest <AWS_ACCOUNT_ID>.dkr.ecr.us-east-1.amazonaws.com/my-app-repo:latest
docker push <AWS_ACCOUNT_ID>.dkr.ecr.us-east-1.amazonaws.com/my-app-repo:latest
```

## **🚀 Step 5: Deploy Application on EKS**

### **1️⃣ Configure kubeconfig**

```sh
aws eks update-kubeconfig --region us-east-1 --name dev-eks-cluster
```

### **2️⃣ Deploy to Kubernetes**

```sh
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
```

## **🚀 Step 6: Set Up GitHub Actions for CI/CD**

### **1️⃣ Add GitHub Secrets**

- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`
- `AWS_REGION`

### \*\*2️⃣ Create \*\*\`\`

```yaml
name: Deploy to AWS

on:
  push:
    branches:
      - main

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout Code
        uses: actions/checkout@v3

      - name: Set Up AWS Credentials
        uses: aws-actions/configure-aws-credentials@v1
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: ${{ secrets.AWS_REGION }}

      - name: Login to ECR
        run: |
          aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin <AWS_ACCOUNT_ID>.dkr.ecr.us-east-1.amazonaws.com

      - name: Build and Push Docker Image
        run: |
          docker build -t my-app .
          docker tag my-app:latest <AWS_ACCOUNT_ID>.dkr.ecr.us-east-1.amazonaws.com/my-app-repo:latest
          docker push <AWS_ACCOUNT_ID>.dkr.ecr.us-east-1.amazonaws.com/my-app-repo:latest

      - name: Deploy to EKS
        run: |
          aws eks update-kubeconfig --region us-east-1 --name dev-eks-cluster
          kubectl apply -f k8s/deployment.yaml
          kubectl apply -f k8s/service.yaml
```

## **🎯 Summary**

✅ **Multi-region HA EKS + RDS Aurora setup** ✅ **S3-based Terraform backend (private)** ✅ **GitHub Actions + AWS CodePipeline for CI/CD** ✅ **Prometheus + CloudWatch for monitoring** ✅ **Secrets Manager for DB credentials security**

💡 **Next Steps?** Let me know if you need additional features or optimizations! 🚀

