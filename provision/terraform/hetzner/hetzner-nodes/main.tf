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
      version = "0.7.2"
    }
  }
}

data "hcloud_ssh_keys" "all_keys" {
}

resource "hcloud_server" "masters" {
  name        = "${var.master_hostname_prefix}${(count.index + 1)}"
  location    = "${var.location}"
  image       = "${var.image}"
  server_type = "${var.master_server_type}"
  ssh_keys    = data.hcloud_ssh_keys.all_keys.ssh_keys.*.name

  count = "${var.master_count}"

  #lifecycle {
  #  prevent_destroy = true
  #}

}

resource "hcloud_server" "workers" {
  name        = "${var.hostname_prefix}${(count.index + 1)}"
  location    = "${var.location}"
  image       = "${var.image}"
  server_type = "${var.server_type}"
  ssh_keys    = data.hcloud_ssh_keys.all_keys.ssh_keys.*.name

  count = "${var.worker_count}"

  #lifecycle {
  #  prevent_destroy = true
  #}

}

resource "hcloud_floating_ip" "master" {
  type = "ipv4"
  home_location = "${var.location}"
  description = "k3s floating ip"
}

locals {
  floating_ip = "${ join(" ", hcloud_floating_ip.master.*.ip_address) }"
}

resource "null_resource" "floating_ip_setup" {
  triggers = {
    script_hash = sha256("${path.module}/setup-floating-ip.sh")
  }

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

resource "hcloud_server_network" "mastersnetwork" {
  count = "${var.master_count}"
  server_id = "${element(hcloud_server.masters.*.id, count.index)}"
  network_id = "${var.network_id}"
  ip         = "10.0.0.${count.index + 2}"
}

resource "hcloud_server_network" "workersnetwork" {
  count = "${var.worker_count}"
  server_id = "${element(hcloud_server.workers.*.id, count.index)}"
  network_id = "${var.network_id}"
  ip         = "10.0.0.${var.master_count + count.index + 2}"
}
