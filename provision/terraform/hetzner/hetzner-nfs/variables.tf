variable "network_id" {
  type = string
}

variable "location" {
  type = string
  default = "nbg1"
}

variable "server_count" {
  type = number
  default = 1
}

variable "server_type" {
  type = string
  default = "cx21"
}

variable "image" {
  type = string
  default = "ubuntu-20.04"
}

variable "hostname_prefix" {
  type = string
  default = "nfs-"
}

variable "private_ip_offset" {
    type = number
    default = 100
}

variable "volume_size" {
    type = number
    default = 10
}