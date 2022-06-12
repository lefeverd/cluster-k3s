output "server_hostnames" {
  value = ["${hcloud_server.hosts.*.name}"]
}

output "server_public_ips" {
  value = ["${hcloud_server.hosts.*.ipv4_address}"]
}
