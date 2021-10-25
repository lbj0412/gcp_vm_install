locals {
  hostname      = var.hostname == "" ? "default" : var.hostname
  num_instances = length(var.static_ips) == 0 ? var.num_instances : length(var.static_ips)

  static_ips = concat(var.static_ips, ["NOT_AN_IP"])
  project_id = var.project_id
}

###############
# Data Sources
###############

data "google_compute_zones" "available" {
  project = local.project_id
  region  = var.region
}

### external -ip ###
resource "google_compute_address" "external-ip" {
  count  = var.num_instances
  name   = var.add_hostname_suffix ? "${local.hostname}-${count.index}" : local.hostname
  region = var.region
}

#############
# Instances
#############

resource "google_compute_instance_from_template" "compute_instance" {
  count   = local.num_instances
  name    = var.add_hostname_suffix ? "${local.hostname}-${format("%02d", count.index + 1)}" : local.hostname
  project = local.project_id
  zone    = var.zone == null ? data.google_compute_zones.available.names[count.index % length(data.google_compute_zones.available.names)] : var.zone

  network_interface {
    network            = var.network
    subnetwork         = var.subnetwork
    subnetwork_project = var.subnetwork_project
    network_ip         = length(var.static_ips) == 0 ? "" : element(local.static_ips, count.index)
    dynamic "access_config" {
      for_each = var.access_config
      content {
        nat_ip       = google_compute_address.external-ip[count.index].address
        network_tier = access_config.value.network_tier
      }
    }
  }

  source_instance_template = var.instance_template
}

