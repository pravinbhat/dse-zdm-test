- [1. NOTES](#1-notes)
- [2. Terraform Introduction and Cluster Topology](#2-terraform-introduction-and-cluster-topology)
- [3. Use Terraform to Launch Infrastructure Resources](#3-use-terraform-to-launch-infrastructure-resources)
  - [3.1. Pre-requisites](#31-pre-requisites)
  - [3.2. Provision AWS Resources](#32-provision-aws-resources)
    - [3.2.1. Custom VPC and Subnet](#321-custom-vpc-and-subnet)
    - [3.2.2. EC2 Count and Type](#322-ec2-count-and-type)
    - [3.2.3. AWS Key-Pair](#323-aws-key-pair)
    - [3.2.4. Security Group](#324-security-group)
    - [3.2.5. User Data](#325-user-data)
- [4. Generate Ansible Inventory File Automatically](#4-generate-ansible-inventory-file-automatically)
- [5. Extended Ansible Framework for DSE and OpsCenter Installation and Configuration](#5-extended-ansible-framework-for-dse-and-opscenter-installation-and-configuration)

---
---

# 1. NOTES

**Updates on ***08/08/2021*****

* Retested with: 
  * Terraform 1.0.3
  * Ansible version: 2.11.3

* Updates
  * Add Terraform support for custom VPC and subnets 

---
---

This repository was forked from Yabin Meng's excellent repository  [here](https://github.com/yabinmeng/terradse). The original version contains a much more comprehensive automation suite
to provision, install and configure a multi-DC DSE cluster monitored by OpsCenter (which stores its monitoring data into a dedicated metrics cluster). I highly recommend to use Yabin's repo
for general DSE installations that follow the recommended configuration and deployment guidelines.

The automation in this repository has been simplified to provision a simple, single-DC DSE cluster without OpsCenter. This is useful for testing purposes, when a full installation would not be necessary
and reducing the installation footprint is preferable.

The scripts in this repository have 3 major parts:
1. Terraform scripts to launch the required AWS resources (EC2 instances, security groups, etc.) based on the target DSE cluster topology.
2. Ansible playbooks to install and configure DSE on the provisioned AWS EC2 instances.
3. Linux bash scripts to 
   1. generate the ansible host inventory file (required by the ansible playbooks) from the terraform state output
   2. launch the terraform scripts and ansible playbooks

---
---

# TL;DR

First generated an ssh keypair

```
ssh-keygen -t rsa
```

File for generated key should be `~/.ssh/origin_key`

```
cd aws
# run terraform script to create aws infrastructure
./runterra.sh

# generate ansible inventory based on terraform created servers
./genansinv.sh

# run ansible to install dse cluster
./runansi.sh

# connect to instance to check nodetool status for instance
ssh -i ~/.ssh/origin_key ubuntu@xx.xx.xx.xx

# open cqlsh
cqlsh `hostname -I` -u cassandra -p cassandra
```


---
---

# 2. Terraform Introduction and Cluster Topology

The Terraform script will provision one DSE cluster with a single DC with a default of three nodes (the number of nodes per DC is configurable through Terraform variables). 
The script could support a second DC but for the moment this has been commented out for simplicity. 

# 3. Use Terraform to Launch Infrastructure Resources

**NOTE:** a linux bash script, ***runterra.sh***, is provided to automate the execution the terraform scripts.

## 3.1. Pre-requisites

In order to run the Terraform script successfully, the following procedures need to be executed in advance:

1. Install Terraform software on the computer to run the script
2. Install and configure AWS CLI properly. Make sure you have an AWS account that have the enough privilege to create and configure AWS resources.
3. Create a SSH key-pair. The script automatically uploads the public key to AWS (to create an AWS key pair resource), so the launched AWS EC2 instances can be connected through SSH. The names of the SSH key-pair, by default, should be “origin_key" and "origin_key.pub”. If you choose other names, please make sure to update the Terraform configuration variable accordingly.

## 3.2. Provision AWS Resources 

### 3.2.1. Custom VPC and Subnet

All the provisioned AWS resources are created under a custom VPC called **vpc_dse**. If a different custom VPC name is needed, please change it in *vpc.tf* file, as below:

```
resource "aws_vpc" "vpc_dse" {
   cidr_block           = var.vpc_cidr_str_vpc
   enable_dns_hostnames = true

   tags = {
     Name = "${var.tag_identifier}-vpc_dse"  
   }
}
```

There are 2 subnets created under the VPC. The associated IP range of the subnets are listed below:

| Subnet | IP Range |
| ------ | -------- |
| Subnet for DSE application cluster (DC1) | 191.100.20.0/24 |
| Subnet for DSE application Cluster (DC2) (not currently used)| 191.100.30.0/24 |

If you want to change the IP range of the subnets, you can change the following variables:

```
## CIDR for VPC and subnets
variable "vpc_cidr_str_vpc" {
   default = "191.100.0.0/16"
}
variable "vpc_cidr_str_cassapp" {
   default = "191.100.20.0/24"
}
```

### 3.2.2. EC2 Count and Type

The number and type of AWS EC2 instances are determined at DataCenter (DC) level through terraform variable mappings.
```
variable "instance_count" {
   type = map
   default = {
      dse_app_dc1 = 3
      // dse_app_dc2 = 3
   }
}

variable "instance_type" {
   type = map
   default = {
      // t2.2xlarge is the minimal DSE requirement
      dse_app_dc1 = "t2.2xlarge"
      // dse_app_dc2 = "t2.2xlarge"
   }
}
```

### 3.2.3. AWS Key-Pair

The script also creates an AWS key-pair resource that can be associated with the EC2 instances. The AWS key-pair resource is created from a locally generated SSH public key and the corresponding private key can be used to log into the EC2 instances.
Please note the naming convention of the key (see pre-requisites)
```
resource "aws_key_pair" "dse_terra_ssh" {
    key_name = var.keyname
    public_key = file("${var.ssh_key_localpath}/${var.ssh_key_filename}.pub")

    tags = {
        Name         = "${var.tag_identifier}-dse_terra_ssh"
        Environment  = var.env 
   }
}

resource "aws_instance" "dse_app_dc1" {
   ... ...
   key_name          = aws_key_pair.dse_terra_ssh.key_name
   ... ... 
}
```

### 3.2.4. Security Group

In order for the DSE cluster to work properly, certain ports on the ec2 instances have to be open, as per the following DataStax documents:
* [Securing DataStax Enterprise ports](https://docs.datastax.com/en/security/6.8/security/secFirewallPorts.html)

The script does so by creating the following AWS security group resources:
1. sg_ssh: allows SSH access from public
4. sg_dse_node: allows DSE node specific communication

Please note that the cluster nodes have a public IP and are reachable from the outside world. 

The code snippet below describes how a security group resource is defined and associated with EC2 instances.
```
resource "aws_security_group" "sg_ssh" {
   name = "sg_ssh"

   ingress {
      from_port = 22
      to_port = 22
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
   }

   egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
   }
}

... ... // other security group definitions

resource "aws_instance" "dse_app_dc1" {
   ... ...
   vpc_security_group_ids = [aws_security_group.sg_internal_only.id,aws_security_group.sg_ssh.id,aws_security_group.sg_dse_node.id]
   ... ...
}
```

### 3.2.5. User Data

One of the key requirements to run DSE cluster is to enable NTP service. The script achieves this through EC2 instance user data. which is provided through a terraform template file. 
```
data "template_file" "user_data" {
   template = <<-EOF
              #!/bin/bash
              apt-get update -y
              apt-get install python-minimal -y
              apt-get install ntp -y
              apt-get install ntpstat -y
              ntpq -pcrv
              EOF
}

resource "aws_instance" "dse_app_dc1" {
   ... ...
   user_data = data.template_file.user_data.rendered
   ... ...
}
```

Other than NTP service, python (minimal version) is also installed in order for Ansible to work properly. Please note that Java, as another essential software required by DSE and OpsCenter software, 
is currently installed through Ansible and therefore not listed here as part of the User Data installation. 

# 4. Generate Ansible Inventory File Automatically

After the infrastructure instances have been provisioned, we need to install and configure DSE on these instances accordingly, which is through the Ansible framework at [here](https://github.com/yabinmeng/dseansible). 
One key item in the Ansible framework is the Ansible inventory file which determines key DSE node characteristics such as node IP, seed node, VNode, workload type, and so on. 

A linux script file, ***genansinv.sh***, is providied for this purpose. The script has 3 input parameters, either through input arguments or script variables. These parameters will impact the target DSE cluster topology information (as presented in the Ansible inventory file) a bit. Please adjust accordingly for your own case.

1. Script input argument: number of seed nodes per DC, default at 1
```
  genansinv.sh [<number_of_seeds_per_dc>]
```
2. Script variable: the name of the application DSE cluster: 
```
  DSE_APPCLUSTER_NAME="OriginCluster"
```
---

The script can be run without any command-line parameters as the defaults are suitable to create a simple Origin cluster.

A template of the generated Ansible inventory file looks like [this](aws//ansible/hosts.template).


# 5. Extended Ansible Framework for DSE and OpsCenter Installation and Configuration

The Ansible framework contains two playbooks:

1. *osparm_change.yaml*: configures OS/Kernel parameters on each node where DSE is installed, as per [Recommended production settings](https://docs.datastax.com/en/dse/6.8/dse-dev/datastax_enterprise/config/configRecommendedSettings.html) from DataStax documentation.
2. *dse_install.yml*: installs and configures a DSE cluster.

For operational simplicity, a linux script file, ***runansi.sh***, is provided to execute these Ansible playbooks. This can be executed without parameters.