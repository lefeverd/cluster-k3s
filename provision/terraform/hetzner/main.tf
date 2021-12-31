terraform {
  required_providers {
    hcloud = {
      source = "hetznercloud/hcloud"
    }
    null = {
      source = "hashicorp/null"
    }
    sops = {
      source  = "carlpett/sops"
      version = "0.6.3"
    }
  }
}

data "sops_file" "hetzner_secrets" {
  source_file = "secret.sops.yaml"
}

provider "hcloud" {
  token = data.sops_file.hetzner_secrets.data["hetzner_token"]
}

data "hcloud_ssh_keys" "all_keys" {
}

resource "hcloud_server" "masters" {
  name        = "${var.hetzner_master_hostname_prefix}${(count.index + 1)}"
  location    = "${var.hetzner_location}"
  image       = "${var.hetzner_image}"
  server_type = "${var.hetzner_master_server_type}"
  ssh_keys    = data.hcloud_ssh_keys.all_keys.ssh_keys.*.name

  count = "${var.hetzner_master_count}"

  #lifecycle {
  #  prevent_destroy = true
  #}

}

resource "hcloud_server" "workers" {
  name        = "${var.hetzner_hostname_prefix}${(count.index + 1)}"
  location    = "${var.hetzner_location}"
  image       = "${var.hetzner_image}"
  server_type = "${var.hetzner_server_type}"
  ssh_keys    = data.hcloud_ssh_keys.all_keys.ssh_keys.*.name

  count = "${var.hetzner_worker_count}"

  #lifecycle {
  #  prevent_destroy = true
  #}

}

resource "hcloud_floating_ip" "master" {
  type = "ipv4"
  home_location = "${var.hetzner_location}"
  description = "k3s floating ip"
}

locals {
  floating_ip = "${ join(" ", hcloud_floating_ip.master.*.ip_address) }"
}

resource "null_resource" "floating_ip_setup" {

  connection {
    host  = "${hcloud_server.masters.0.ipv4_address}"
    user  = "root"
    agent = false
    private_key = "${file("~/.ssh/id_rsa")}"
  }

  provisioner "file" {
    source      = "${path.module}/setup-floating-ip.sh"
    destination = "/tmp/setup-floating-ip.sh"
  }

  # Setup floating IP
  provisioner "remote-exec" {
    inline = [
        "chmod +x /tmp/setup-floating-ip.sh",
        "/tmp/setup-floating-ip.sh \"${local.floating_ip}\"",
        "netplan apply"
    ]
  }
}

resource "hcloud_floating_ip_assignment" "main" {
  floating_ip_id = "${hcloud_floating_ip.master.id}"
  server_id = "${hcloud_server.masters.0.id}"
}

resource "hcloud_network" "k3snet" {
  name     = "k3snet"
  ip_range = "10.0.0.0/16"
}

resource "hcloud_network_subnet" "k3ssubnet" {
  network_id   = hcloud_network.k3snet.id
  type         = "cloud"
  network_zone = "eu-central"
  ip_range     = "10.0.0.0/24"
}

resource "hcloud_server_network" "mastersnetwork" {
  count = "${var.hetzner_master_count}"
  server_id = "${element(hcloud_server.masters.*.id, count.index)}"
  network_id = hcloud_network.k3snet.id
  ip         = "10.0.0.${count.index + 2}"
}

resource "hcloud_server_network" "workersnetwork" {
  count = "${var.hetzner_worker_count}"
  server_id = "${element(hcloud_server.workers.*.id, count.index)}"
  network_id = hcloud_network.k3snet.id
  ip         = "10.0.0.${var.hetzner_master_count + count.index + 2}"
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
