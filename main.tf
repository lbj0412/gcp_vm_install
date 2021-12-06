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
  source_image         = each.value.source_image
  source_image_family  = each.value.source_image_family
  source_image_project = each.value.source_image_project
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
  for_each            = local.vm_instance
  depends_on          = [module.instance_template]
  project_id          = var.project_id
  region              = each.value.region
  zone                = each.value.zone
  subnetwork          = each.value.subnetwork
  num_instances       = each.value.num_instances
  hostname            = each.value.hostname
  add_hostname_suffix = each.value.add_hostname_suffix
  instance_template   = each.value.instance_template
  access_config       = each.value.access_config
}