# Kubernetes no AWS com Spot Instances

Cluster Kubeadm com spot instances para reduzir custos.

## Deploy

```bash
terraform init
terraform plan
terraform apply
```

## Setup do Cluster

### Master
```bash
# SSH no master
ssh -i ~/.ssh/key.pem ubuntu@<master-ip>

# Init cluster
sudo kubeadm init --pod-network-cidr=10.244.0.0/16

# Config kubectl
mkdir -p $HOME/.kube
sudo cp /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Install CNI
kubectl apply -f https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml
```

### Worker
```bash
# SSH no worker
ssh -i ~/.ssh/key.pem ubuntu@<worker-ip>

# Join cluster (comando do kubeadm init)
sudo kubeadm join <master-ip>:6443 --token <token> --discovery-token-ca-cert-hash sha256:<hash>
```

## Custos

- t3.small spot: ~$0.006/hora
- 1 master + 1 worker: ~$4-5/mês

## Destroy

```bash
terraform destroy
```
