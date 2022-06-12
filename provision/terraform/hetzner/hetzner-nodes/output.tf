output "floating_ip" {
  value = "${local.floating_ip}"
}

output "master_hostnames" {
  value = ["${hcloud_server.masters.*.name}"]
}

output "master_public_ips" {
  value = ["${hcloud_server.masters.*.ipv4_address}"]
}

output "worker_hostnames" {
  value = ["${hcloud_server.workers.*.name}"]
}

output "worker_public_ips" {
  value = ["${hcloud_server.workers.*.ipv4_address}"]
}
