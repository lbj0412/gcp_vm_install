variable "project_id" {
  default = "iaas-demo-208601"
}
variable "network_name" {
  default = "lbj-network"
}

variable "region" {
  default = "asia-northeast3"
}

variable "account_id" {
  default = "lbj-terraform-test-sa"
}

variable "zone" {
  default = "asia-northeast3-b"
}

variable "num_instances" {
  default = 1
}

variable "instance_name" {
  default = "lbj-test-1"
}

variable "add_hostname_suffix" {
  default = true
}
variable "network_tier" {
  default = "PREMIUM"
}

variable "nat_ip" {
  default = null
}