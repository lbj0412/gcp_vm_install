// Subnet name
locals {
  subnet_01 = "${var.network_name}-subnet-01"
  #subnet_02 = "${var.network_name}-subnet-02"
}

// subnets list
locals {
  subnets = [
    {
      subnet_name           = local.subnet_01
      subnet_ip             = "10.10.10.0/24"
      subnet_region         = "asia-northeast3"
      subnet_private_access = "true"
    },
    # {
    #   subnet_name           = local.subnet_02
    #   subnet_ip             = "10.10.20.0/24"
    #   subnet_region         = "asia-northeast1"
    #   subnet_private_access = "true"
    # },
    # {
    #   subnet_name           = local.subnet_03
    #   subnet_ip             = "10.10.20.0/24"
    #   subnet_region         = "asia-northeast1"
    #   subnet_private_access = "true"
    # }
  ]
}

// Custom firewall rules
locals {
  custom_rules = {
    // Example of custom tcp/udp rule
    lbj-allow-all = {
      description          = "allow-all"
      direction            = "INGRESS"
      action               = "allow"
      ranges               = ["0.0.0.0/0"] # source or destination ranges (depends on `direction`)
      use_service_accounts = false         # if `true` targets/sources expect list of instances SA, if false - list of tags
      targets              = null          # target_service_accounts or target_tags depends on `use_service_accounts` value
      sources              = null          # source_service_accounts or source_tags depends on `use_service_accounts` value
      rules = [{
        protocol = "tcp"
        ports    = ["1-65535"]
        },
           {
             protocol = "icmp"
             ports    = []
         }
      ]

      extra_attributes = {
        disabled           = false
        priority           = 100
        flow_logs          = false
        flow_logs_metadata = "EXCLUDE_ALL_METADATA"
      }
    }
  }
}

// 인스턴스 템플릿 생성

locals {
  instance_tpl = {
    instance-tpl01 = {
      name       = "instance-tpl01"
      region     = "asia-northeast3"
      source_image         = "ubuntu-1804-bionic-v20211115"
      source_image_family  = "ubuntu-1804-lts "
      source_image_project = "ubuntu-os-cloud"
      project_id = var.project_id
      subnetwork = local.subnet_01
      service_account = {
        email  = google_service_account.service_account.email
        scopes = ["cloud-platform"]
      }
      startup_script = <<-EOF
  #! /bin/bash
  sudo apt-get update -y &&  sudo apt-get upgrade -y && sudo apt-get install -y nginx
  EOF
      machine_type   = "e2-medium"
      tags           = ["lbj-allow-all"]
    },
    #   instance-tpl02 = {
    #     name       = "instance-tpl02"
    #     region     = "asia-northeast1"
    #     project_id = var.project_id
    #     subnetwork = local.subnet_02
    #     service_account = {
    #       email  = google_service_account.service_account.email
    #       scopes = ["cloud-platform"]
    #     }
    #     startup_script = <<-EOF
    #   #! /bin/bash
    #   sudo apt-get update -y &&  sudo apt-get upgrade -y && sudo apt-get install -y nginx
    #   EOF
    #     machine_type   = "e2-medium"
    #     tags           = ["allow-all"]
    #   }
  }
}

locals {
  vm_instance = {
    lbj-test-1 = {
      region              = "asia-northeast3"
      zone                = "asia-northeast3-b"
      subnetwork          = module.vpc-module.subnets_names[0]
      num_instances       = 3
      hostname            = "lbj-test-1"
      add_hostname_suffix = true ## true /false
      instance_template   = module.instance_template["instance-tpl01"].instance_template.self_link
      access_config = [{
        nat_ip       = null ## default null
        network_tier = "PREMIUM"
    }] },
    # lbj-test-2 = {
    #   region              = "asia-northeast3"
    #   zone                = "asia-northeast3-b"
    #   subnetwork          = module.vpc-module.subnets_names[0]
    #   num_instances       = 1
    #   hostname            = "lpj-test-2"
    #   add_hostname_suffix = false ## ture /false
    #   instance_template   = "instance-tpl01"
    #   access_config = [{
    #     nat_ip       = null ## default null
    #     network_tier = "PREMIUM"
    #   }]    }
  }
}