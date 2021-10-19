module "vpc-module" {
  source       = "./module/network"
  project_id   = var.project_id
  network_name = var.network_name
  routing_mode = "REGIONAL" ## (default = GLOBAL)

  subnets = [
    {
      subnet_name           = local.subnet_01
      subnet_ip             = "10.10.10.0/24"
      subnet_region         = "us-west1"
      subnet_private_access = "true"
    },
    {
      subnet_name           = local.subnet_02
      subnet_ip             = "10.10.20.0/24"
      subnet_region         = "us-west1"
      subnet_private_access = "true"
    },
  ]
}

module "firewall-module" {
  source       = "./module/firewall"
  network      = module.vpc-module.network_name
  custom_rules = local.custom_rules
}
