terraform {
  required_providers {
    alicloud = {
      source  = "hashicorp/alicloud"
      version = "1.153.0"
    }
  }
}

resource "random_uuid" "this" {}
locals {
  default_description = "Auto created by serverless devs with terraform"
  default_name = "terraform-test-${random_uuid.this.result}"
}

resource "alicloud_sae_application" "auto" {
  count = 1
  app_name = "app-202201131323" #local.default_name
  app_description = local.default_description
  auto_config = true
  image_url = "registry-vpc.cn-hangzhou.aliyuncs.com/sae-demo-image/provider:1.0"

  package_type = "Image"
  timezone = "Asia/Beijing"
  replicas = "2"
  cpu = "500"
  memory = "2048"
#  vpc_id = "${alicloud_vpc.vpc.id}"
#  vswitch_id = "${alicloud_vswitch.vsw.id}"
}

resource "alicloud_sae_namespace" "default" {
  namespace_description = local.default_description
  namespace_id = "cn-hangzhou:pocdemo"
  namespace_name = local.default_name
}

resource "alicloud_vpc" "vpc" {
  vpc_name   = local.default_name
  cidr_block = "172.16.0.0/12"
}
data "alicloud_zones" "default" {}

resource "alicloud_vswitch" "vsw" {
  vpc_id            = alicloud_vpc.vpc.id
  cidr_block        = "172.16.0.0/21"
  zone_id           = data.alicloud_zones.default.zones.0.id
}

resource "alicloud_slb_load_balancer" "slb" {
  load_balancer_name = local.default_name
  address_type       = "intranet"
  load_balancer_spec = "slb.s2.small"
  vswitch_id         = alicloud_vswitch.vsw.id
  tags = {
    info = "create for internet"
  }
}


resource "alicloud_vswitch" "vsw1" {
  vpc_id            = alicloud_vpc.vpc.id
  cidr_block        = "172.20.0.0/21"
  zone_id           = data.alicloud_zones.default.zones.1.id
}

resource "alicloud_security_group" "group" {
  name   = local.default_name
  vpc_id = alicloud_vpc.vpc.id
}


variable "name" {
  default = "tf-demo"
}
