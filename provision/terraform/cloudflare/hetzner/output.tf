
output "network" {
  value = "${hcloud_network.k3snet.id}"
}

output "subnet" {
  value = "${hcloud_network_subnet.k3ssubnet.id}"
}

output "nodes" {
  value = module.hetzner_nodes
}

output "nfs" {
  value = module.hetzner_nfs
}
