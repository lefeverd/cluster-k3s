variable "network_id" {
  type = string
}

variable "location" {
  type = string
  default = "nbg1"
}

variable "worker_count" {
  type = number
  default = 3
}

variable "server_type" {
  type = string
  default = "cx21"
}

variable "master_count" {
  type = number
  default = 1
}

variable "master_server_type" {
  type = string
  default = "cx21"
}

variable "image" {
  type = string
  default = "ubuntu-20.04"
}

variable "master_hostname_prefix" {
  type = string
  default = "k8s-master-"
}


variable "hostname_prefix" {
  type = string
  default = "k8s-"
}
