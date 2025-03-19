#!/usr/bin/env bash
set -o xtrace
export CLUSTER_NAME="eks-demo"
export REGION="us-east-1"

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

yum install -y kubelet kubectl --disableexcludes=kubernetes
yum install bash-completion
echo 'source <(kubectl completion bash)' >>~/.bashrc
echo 'alias k=kubectl' >>~/.bashrc
echo 'complete -o default -F __start_kubectl k' >>~/.bashrc

aws eks update-kubeconfig --region us-east-1 --name ${CLUSTER_NAME}



# Overwrites the kubelet services to remove the flag --container-runtime and --network-cni
cat <<EOF > /etc/systemd/system/kubelet.service
    [Unit]
    Description=Kubernetes Kubelet
    Documentation=https://github.com/kubernetes/kubernetes
    After=docker.service iptables-restore.service
    Requires=docker.service

    [Service]
    ExecStartPre=/sbin/iptables -P FORWARD ACCEPT -w 5
    ExecStart=/usr/bin/kubelet \
        --config /etc/kubernetes/kubelet/kubelet-config.json \
        --kubeconfig /var/lib/kubelet/kubeconfig \
        --image-credential-provider-config /etc/eks/image-credential-provider/config.json \
        --image-credential-provider-bin-dir /etc/eks/image-credential-provider \
        $KUBELET_ARGS \
        $KUBELET_EXTRA_ARGS

    Restart=always
    RestartSec=5
    KillMode=process

    [Install]
    WantedBy=multi-user.target
EOF

# Overwrites the kubelet-config.json to add the containerRuntimeEndpoint
cat <<EOF > /etc/kubernetes/kubelet/kubelet-config.json
    {
    "kind": "KubeletConfiguration",
    "apiVersion": "kubelet.config.k8s.io/v1beta1",
    "address": "0.0.0.0",
    "containerRuntimeEndpoint": "unix:///var/run/docker.sock",
    "authentication": {
      "anonymous": {
        "enabled": false
      },
      "webhook": {
        "cacheTTL": "2m0s",
        "enabled": true
      },
      "x509": {
        "clientCAFile": "/etc/kubernetes/pki/ca.crt"
      }
    },
    "authorization": {
      "mode": "Webhook",
      "webhook": {
        "cacheAuthorizedTTL": "5m0s",
        "cacheUnauthorizedTTL": "30s"
      }
    },
    "clusterDomain": "cluster.local",
    "hairpinMode": "hairpin-veth",
    "readOnlyPort": 0,
    "cgroupDriver": "cgroupfs",
    "cgroupRoot": "/",
    "featureGates": {
      "RotateKubeletServerCertificate": true
    },
    "protectKernelDefaults": true,
    "serializeImagePulls": false,
    "serverTLSBootstrap": true,
    "tlsCipherSuites": ["TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256", "TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256", "TLS_ECDHE_ECDSA_WITH_CHACHA20_POLY1305", "TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384", "TLS_ECDHE_RSA_WITH_CHACHA20_POLY1305", "TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384", "TLS_RSA_WITH_AES_256_GCM_SHA384", "TLS_RSA_WITH_AES_128_GCM_SHA256"]
}
EOF

export CLUSTER_IP=$(aws eks describe-cluster --query "cluster.kubernetesNetworkConfig.serviceIpv4Cidr" --output text --name ${CLUSTER_NAME} --region ${REGION})
export APISERVER_ENDPOINT=$(aws eks describe-cluster --query "cluster.endpoint" --output text --name ${CLUSTER_NAME} --region ${REGION})
export CLUSTER_CA_CERTIFICATE=$(aws eks describe-cluster --query "cluster.certificateAuthority.data" --output text --name ${CLUSTER_NAME} --region ${REGION})

bash /etc/eks/bootstrap.sh ${CLUSTER_NAME} --b64-cluster-ca ${CLUSTER_CA_CERTIFICATE} --apiserver-endpoint ${APISERVER_ENDPOINT} --dns-cluster-ip ${CLUSTER_IP}

swapoff -a
systemctl enable --now kubelet
systemctl daemon-reload


# wget https://raw.githubusercontent.com/dbt-labs/amazon-eks-ami/refs/heads/master/files/bootstrap.sh -O /etc/eks/bootstrap.sh # Amazon Linux 2 does not have this script