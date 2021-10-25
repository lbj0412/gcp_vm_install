// Subnet name
locals {
  subnet_01 = "${var.network_name}-subnet-01"
  subnet_02 = "${var.network_name}-subnet-02"
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
    # }
  ]
}

// Custom firewall rules
locals {
  custom_rules = {
    // Example of custom tcp/udp rule
    lbj-terraform = {
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
      #   {
      #     protocol = "udp"
      #     ports    = ["6534-6566"]
      # }
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
      tags           = ["allow-all"]
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
