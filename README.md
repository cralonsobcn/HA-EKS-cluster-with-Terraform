# **Introduction**
This repo deploys a highly available EKS cluster with an Autoscaling Group in region *`us-east-1`* across 3 different Availability Zones.

Since I've used [AWS Kodekloud Playgrounds](https://kodekloud.com/cloud-playgrounds/aws) to elaborate the contents of this repo, some actions and resources were restricted or had technical limitations.

Actions such as using specific terraform modules, selecting instance types other than *`t2.micro`*, setting custom EKS cluster naming or using an up to date EKS optimized ami, were either restricted or not possible.

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

## **Technologies**:
- AWS: VPCs, Subnetting, Routing Tables, VPC Peering, EKS, Autoscaling Group, EC2, S3, IAM Roles, IAM Policies.
- Git
- Bash
- Kubernetes
- Terraform AWS Provider 

## **Diagram**
![HA-EKS Diagram](HA-EKS.webp)

# **Prerequisites**
- [AWS CLI with your AWS account](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-sso.html#sso-configure-profile-token-auto-sso).
- [Terraform with an access key](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/aws-build#prerequisites).
- [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/#install-kubectl-on-linux)

Run *`$ ./script.sh`* to verify if you meet all the prerequisites. The script must be executable *`$ sudo chmod u+x script.sh`*.

The script checks if:
- [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) is installed and downdloads if it's not.
- [Terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli) is installed and downdloads if it's not.
- [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/#install-using-native-package-management) is installed and downdloads if it's not.
- Creates an AWS S3 Bucket with versioning enabled to store the Terraform State. Feel free to modify the var *`BUCKET`* but remember it must match the name of the bucket in the S3 backend, within the *`providers.tf`* file
- Generates a key pair *`dataplane-kp.pem`* and *`dataplane-kp.pem.pub`* for the EC2 Autoscaling Group.

# **Deployment**
Make sure that the script generates a key pair. Alternatively you can generate a new key pair with the commands below.
- *`$ ssh-keygen -t rsa -N "" -f ${HOME}/dataplane-kp.pem`*
- *`$ export TF_VAR_dataplane_public_key=$(cat "${HOME}/dataplane-kp.pem.pub")`*

Navigate into the *`/terraform`* directory and start the terraform deployment cycle. It will take time, so grab a cup of coffee and let it work for 8 minutes or so.

- *`$ terraform init`*
- *`$ terraform plan`*
- *`$ terraform apply`*

Once the deployment is completed, you need to copy the output value *`dataplane-role-arn`* shown in the console and paste it in the *`aws-auth-cm.yaml > rolearn`* field. 

Update kube-config to access the EKS control plane with:
- *`$ aws eks update-kubeconfig --region us-east-1 --name eks-demo`*

Join the dataplane nodes with the Controlplane with *`kubectl`* and allow EKS 60 seconds to detect the autoscaling group.
- *`$ kubectl apply -f aws-auth-cm.yaml`*

# Observations
- The worker nodes of the dataplane use an EKS optimized ami that comes with *`bootstrap.sh`* pre installed. However, since this EKS deployment is using kubernetes 1.32 the ami needs an upgrade.

- The script *`userdata.sh`* that is passed to the EC2 launch template contains a workaround to make communications between the dataplane and EKS controlplane possible.

- The AWS LoadBalancer Controller creates an AWS Application Load Balancer (ALB) when you create a Kubernetes Ingress resource and creates Network Load Balancer (NLB) when you create a Kubernetes service of type LoadBalancer.

# Future plans
In time, I will refactor the contents of this repo and implement them as part of a CI/CD pipeline using Jenkins.

## **Terraform Documentation**

| Networking | **IAM** | **Pipeline** | **Compute** |
| :----- | :----- | :----- | :----- |
| [Resource: aws\_vpc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc) | [Resource: aws\_iam\_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | [Resource: aws\_codestarconnections\_connection](https://registry.terraform.io/providers/hashicorp/aws/5.90.0/docs/resources/codestarconnections_connection) | [Resource: aws\_eks\_cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_cluster) |
| [Resource: aws\_subnet](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet#availability_zone-1) | [Resource: aws\_iam\_role\_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | `--` | [Resource: aws\_launch\_template](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/launch_template#instance-profile) |
| [Resource: aws\_default\_vpc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_vpc) | [Resource: aws\_iam\_user\_policy\_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_user_policy_attachment) | `--` | [Resource: aws\_autoscaling\_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_group) |
| [Resource: aws\_default\_subnet](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_subnet) | `--` | `--` | [Resource: aws\_key\_pair](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/key_pair) |
| [Resource: aws\_security\_group](https://registry.terraform.io/providers/hashicorp/aws/5.90.1/docs/resources/security_group) | `--` | `--` | `--` |
| [Resource: aws\_security\_group\_rule](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | `--` | `--` | `--` |
| [Resource: aws\_default\_security\_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_security_group) | `--` | `--` | `--` |
| [Resource: aws\_internet\_gateway](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway) | `--` | `--` | `--` |
| [Resource: aws\_route\_table](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | `--` | `--` | `--` |
| [Resource: aws\_route\_table\_association](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | `--` | `--` | `--` |
| [Resource: aws\_default\_route\_table](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_route_table) | `--` | `--` | `--` |
| [Resource: aws\_vpc\_peering\_connection](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_peering_connection) | `--` | `--` | `--` |

## **AWS Documentation**

| Networking | Compute | Pipeline | Misc. |
| :----- | :----- | :----- | :----- |
| [IPv4 VPC CIDR blocks](https://docs.aws.amazon.com/vpc/latest/userguide/vpc-cidr-blocks.html#vpc-sizing-ipv4) | [Prerequisites for EC2 Instance Connect](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-instance-connect-prerequisites.html) | [CodeStarSourceConnection for GitHub](https://docs.aws.amazon.com/codepipeline/latest/userguide/action-reference-CodestarConnectionSource.html) | [amazon-elastic-kubernetes-service-course](https://github.com/kodekloudhub/amazon-elastic-kubernetes-service-course) |
| [EKS Loadbalancing](https://docs.aws.amazon.com/eks/latest/best-practices/load-balancing.html) | [Customize managed nodes with launch templates](https://docs.aws.amazon.com/eks/latest/userguide/launch-templates.html#launch-template-custom-ami) | `--` | [Create EKS Cluster with Terraform](https://kodekloud.com/community/t/create-eks-cluster-with-terraform/474374) |
| [Route internet traffic with AWS Load Balancer Controller](https://docs.aws.amazon.com/eks/latest/userguide/aws-load-balancer-controller.html) | [How do I get my worker nodes to join my Amazon EKS cluster?](https://repost.aws/knowledge-center/eks-worker-nodes-cluster) | `--` | [Get default AWS network resources using Terraform](https://blog.pesky.moe/posts/2025-01-16-default-network/) |
| `--` | [How do I troubleshoot Amazon EKS managed node group creation failures?](https://repost.aws/knowledge-center/resolve-eks-node-failures) | `--` | [Remove container-runtime flag from later versions \#16124](https://github.com/kubernetes/minikube/pull/16124) |
| `--` | [How do I troubleshoot Amazon EKS managed node group creation failures?](https://repost.aws/knowledge-center/resolve-eks-node-failures) | `--` | `--` |