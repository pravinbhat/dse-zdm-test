#
# The local directory where the SSH key files are stored
#
variable "ssh_key_localpath" {
  default = "~/.ssh"
}

variable "cloudgate_aws_profile" {
  default = "default"
}

#
# The local private SSH key file name 
#
variable "ssh_key_filename" {
  default = "origin_key"
}

#
# AWS EC2 key-pair name
#
variable "keyname" {
  default = "dse-zdm-test-sshkey"
}

#
# Default AWS region
#
variable "region" {
  default = "us-east-1"
}

#
# Default OS image: Ubuntu
#
variable "ami_id" {

  # Ubuntu Server 18.04 LTS (HVM), SSD Volume Type (64-bit x86)

  // us-east-1
  default = "ami-0bcc094591f354be2"


  // us-east-2
  //default = "ami-0e82959d4ed12de3f"

  // eu-west-1
  //default = "ami-0e66021c377d8c8b4"

  // us-west-1
  //default = "ami-0e17790f211795d99"
}

variable "proxy_ami" {
  description = "AMI to be used for this EC2 instance"
  type        = map(string)
  default = {
    "us-east-1" = "ami-0bb5a904861ec247f"
    "us-east-2" = "ami-025227bc8f4c2cbdd"
    "us-west-1" = "ami-0558dde970ca91ee5"
    "us-west-2" = "ami-0bdef2eb518663879"

    "eu-west-1"    = "ami-0c259a97cbf621daf"
    "eu-west-2"    = "ami-013fadefd0ab548ef"
    "eu-west-3"    = "ami-0e34a9addd905132f"
    "eu-central-1" = "ami-073375fc9e17516d6"
    "eu-north-1"   = "ami-09f07498568488979"
    "eu-south-1"   = "ami-016e7e862dbd5eb59"
  }
}


#
# AWS resource tag identifier
#
variable "tag_identifier" {
  default = "origin"
}

#
# Environment description
#
variable "env" {
  default = "zdm_test_automation"
}

## CIDR for VPC and subnets
variable "vpc_cidr_str_vpc" {
  default = "191.100.0.0/16"
}
variable "vpc_cidr_str_core" {
  default = "191.100.20.0/24"
}
variable "vpc_cidr_str_zdm_proxy" {
  default = "191.100.30.0/24"
}
variable "vpc_cidr_str_olap" {
  default = "191.100.40.0/24"
}

variable "dse_core_dc1_type" {
  default = "dse_core_dc1"
}

variable "zdm_proxy_dc1_type" {
  default = "zdm_proxy_dc1"
}

variable "zdm_proxy_monitoring_dc1_type" {
  default = "zdm_proxy_monitoring_dc1"
}

variable "dse_olap_dc1_type" {
  default = "dse_olap_dc1"
}

variable "instance_count" {
  type = map(any)
  default = {
    dse_core_dc1  = 3
    zdm_proxy_dc1 = 3
    dse_olap_dc1  = 3
  }
}

variable "instance_type" {
  type = map(any)
  default = {
    dse_core_dc1             = "t2.2xlarge"
    zdm_proxy_dc1            = "c5.xlarge"
    zdm_proxy_monitoring_dc1 = "c5.2xlarge"
    dse_olap_dc1             = "t2.2xlarge"
  }
}

variable "whitelisted_inbound_ip_ranges" {
  type = list(any)
  # defaults to Santa Clara VPN IP range
  default = ["38.99.104.112/28"]
}

variable "whitelisted_outbound_ip_ranges" {
  type = list(any)
  # defaults to everything (unrestricted)
  default = ["0.0.0.0/0"]
}
