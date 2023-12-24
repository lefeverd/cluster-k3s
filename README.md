# K3s cluster

This repository contains the necessary tools to operate the k3s cluster.  
It was built based on the [k8s-at-home flux-cluster-template](https://github.com/k8s-at-home/flux-cluster-template).

The [master group_vars](./provision/ansible/inventory/group_vars/master/k3s.yml) was modified (`node-ip`, `node-external-ip`, `node-taint`).  
The `hetzner` module was added in `provision/terraform` to provision VMs.

## 👋 Introduction

The following components are installed :

- [flux](https://toolkit.fluxcd.io/) - GitOps operator for managing Kubernetes clusters from a Git repository
- [metallb](https://metallb.universe.tf/) - Load balancer for Kubernetes services
- [cert-manager](https://cert-manager.io/) - Operator to request SSL certificates and store them as Kubernetes resources
- [calico](https://www.tigera.io/project-calico/) - Container networking interface for inter pod and service networking
- [traefik](https://traefik.io) - Kubernetes ingress controller used for a HTTP reverse proxy of Kubernetes ingresses

For provisioning the following tools will be used:

- [Ansible](https://www.ansible.com) - Provision the Ubuntu OS and install k3s
- [Terraform](https://www.terraform.io) - Provision an already existing Cloudflare domain and certain DNS records to be used with your k3s cluster

## 2023-06 Debugging network

I had some issue with the previous k3s cluster, where ingresses could not be reached anymore.  
Maybe metallb speakers should only be on the master, which is the only one connected to the public network (see https://stackoverflow.com/a/62459192)

Update 2023-06-18: after some investigations, it seems like metallb was not correctly set up.  
I upgraded to a new version, and defined a better configuration.  
First the chart and CRD's definitions are installed (see core/metallb-system), then the configuration is created (using the CRD's, see apps/metallb-system).  
We first declare an `IPAddressPool` using our floating IP, then a `L2Advertisement`, stating that the IP's must be advertised from our master node.  
We also ensure that metallb controller and traefik both run on the master node.

Here are a few debugging tips :

- https://metallb.universe.tf/configuration/troubleshooting/
  kubectl get endpoints -A
  Verify that the loadbalancer service has endpoints, or metallb will not respond to ARP requests for that service's external IP.
  arping and tcpdump to verify that the requests pass through the network.
- tcpdump :
  sudo tcpdump -i any -nnvvS -w tcpdump.pcap
  then analyze it with wireshark
- iptables tracing :
  # Add a trace in the prerouting table
  sudo iptables -t raw -A PREROUTING -p tcp --destination <public-ip> --dport 443 -j TRACE
  # Analyze dmesg logs
  dmesg -w
  # Focus on a specific request with its ID
  dmesg | grep "ID=5435" | cut -d ' ' -f 3
  # In parallel, list all the rules with line numbers
  sudo iptables -t raw -L -v -n --line-numbers
  # When finished, delete the tracing rule (check its number)
  sudo iptables -t raw -D PREROUTING <rule-number>

## Recreate master node

You can delete the node in Hetzner, then recreate it with terraform `task terraform:plan` followed by `task terraform:apply`.  
The only issue was to recreate the floating IP configuration, as a workaround you can delete it with `cd provision/terraform/hetzner/ && terraform taint module.hetzner_nodes.null_resource.floating_ip_setup && terraform plan && terraform apply`.

## 2023-12 Upgrade k3s and calico

Bumped k3s version, then triggered the ansible install task.  
Had to comment out the feature gate `MixedProtocolLBService` (went GA).  
Had issues with calico, upgraded by following docs at https://docs.tigera.io/calico/latest/operations/upgrading/kubernetes-upgrade :

```
curl https://raw.githubusercontent.com/projectcalico/calico/v3.27.0/manifests/tigera-operator.yaml -O
kubectl replace -f tigera-operator.yaml
```

Had issues with some CRD's, so needed to trigger :

`kubectl apply --server-side --force-conflicts -f https://raw.githubusercontent.com/projectcalico/calico/v3.27.0/manifests/operator-crds.yaml`

Then redo `kubectl replace -f tigera-operator.yaml`.

## 2023-12 Upgrade flux

Followed https://fluxcd.io/flux/installation/upgrade/#upgrade-with-git :

```
flux install --export > ./cluster/flux/flux-system/gotk-components.yaml
```

Commit and wait for sync.  
Then, upgrade manifests by following https://github.com/fluxcd/flux2/releases/tag/v2.0.0.
