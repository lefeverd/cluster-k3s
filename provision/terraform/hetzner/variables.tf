variable "hetzner_location" {
  type = string
  default = "nbg1"
}

variable "hetzner_worker_count" {
  type = number
  default = 2
}

variable "hetzner_server_type" {
  type = string
  default = "cx21"
}

variable "hetzner_master_count" {
  type = number
  default = 1
}

variable "hetzner_master_server_type" {
  type = string
  default = "cx21"
}

variable "hetzner_image" {
  type = string
  default = "ubuntu-20.04"
}

variable "hetzner_master_hostname_prefix" {
  type = string
  default = "k8s-master-"
}


variable "hetzner_hostname_prefix" {
  type = string
  default = "k8s-"
}
