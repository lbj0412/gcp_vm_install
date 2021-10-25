### VPC 생성 ###
module "vpc-module" {
  source       = "./module/network"
  project_id   = var.project_id
  network_name = var.network_name
  routing_mode = "REGIONAL" ## (default = GLOBAL)
  subnets      = local.subnets
}

### Firewall ###
module "firewall-module" {
  source       = "./module/firewall"
  network      = module.vpc-module.network_name
  custom_rules = local.custom_rules
}



### Service account ###
resource "google_service_account" "service_account" {
  account_id   = var.account_id
  display_name = var.account_id
}

### 인스턴스 템플릿 생성 ###
module "instance_template" {
  source          = "./module/instance_template"
  for_each        = local.instance_tpl
  name_prefix     = each.key
  depends_on      = [module.vpc-module]
  region          = each.value.region
  project_id      = var.project_id
  subnetwork      = each.value.subnetwork
  service_account = each.value.service_account
  startup_script  = each.value.startup_script
  machine_type    = each.value.machine_type
  tags            = each.value.tags
}

## 인스턴스 생성 ###
module "compute_instance" {
  source              = "./module/compute_instance"
  depends_on          = [module.instance_template]
  project_id          = var.project_id
  region              = var.region
  zone                = var.zone
  subnetwork          = module.vpc-module.subnets_names[0]
  num_instances       = var.num_instances
  hostname            = var.instance_name
  add_hostname_suffix = var.add_hostname_suffix
  instance_template   = module.instance_template["instance-tpl01"].self_link
  access_config = [{
    nat_ip       = var.nat_ip
    network_tier = var.network_tier
  }]
}