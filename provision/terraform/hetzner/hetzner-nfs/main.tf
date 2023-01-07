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

resource "hcloud_server" "hosts" {
  name        = "${var.hostname_prefix}${(count.index + 1)}"
  location    = "${var.location}"
  image       = "${var.image}"
  server_type = "${var.server_type}"
  ssh_keys    = data.hcloud_ssh_keys.all_keys.ssh_keys.*.name

  count = "${var.server_count}"

  #lifecycle {
  #  prevent_destroy = true
  #}

}

resource "hcloud_volume" "volume" {
    count = "${var.server_count}"
    name = "volume-${element(hcloud_server.hosts.*.name, count.index)}"
    size = "${var.volume_size}"
    server_id = "${element(hcloud_server.hosts.*.id, count.index)}"
}

resource "hcloud_server_network" "hostsnetwork" {
  count = "${var.server_count}"
  server_id = "${element(hcloud_server.hosts.*.id, count.index)}"
  network_id = "${var.network_id}"
  ip         = "10.0.0.${count.index + var.private_ip_offset}"
}
