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

module "hetzner_nodes" {
  source = "./hetzner-nodes"
  network_id = "${hcloud_network.k3snet.id}"
  server_type = "${var.hetzner_server_type}"
  master_server_type = "${var.hetzner_server_type}"
  image = "${var.hetzner_image}"
}

module "hetzner_nfs" {
    source = "./hetzner-nfs"
    network_id = "${hcloud_network.k3snet.id}"
    server_type = "${var.hetzner_server_type}"
    image = "${var.hetzner_image}"
}
