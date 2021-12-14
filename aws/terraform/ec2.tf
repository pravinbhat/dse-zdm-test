#
# EC2 instances for DSE core cluster, DC1
# 
resource "aws_instance" "dse_core_dc1" {
  ami           = var.ami_id
  instance_type = lookup(var.instance_type, var.dse_core_dc1_type)
  root_block_device {
    volume_size = 100
  }
  count     = lookup(var.instance_count, var.dse_core_dc1_type)
  key_name  = aws_key_pair.dse-zdm-test-sshkey.key_name
  subnet_id = aws_subnet.sn_dse_core_zdm_test.id

  vpc_security_group_ids = [
    aws_security_group.sg_dse_zdm_test_internal_only.id,
    aws_security_group.sg_dse_zdm_test_ssh.id,
    aws_security_group.sg_dse_zdm_test_node.id
  ]

  tags = {
    Name        = "${var.tag_identifier}-${var.dse_core_dc1_type}-${count.index}"
    Environment = var.env
  }

}

#
# EC2 instances for ZDM Proxy cluster, DC1
# 

resource "aws_instance" "zdm_proxy_dc1" {
  ami = lookup(var.proxy_ami, var.region)

  instance_type = lookup(var.instance_type, var.zdm_proxy_dc1_type)
  count         = lookup(var.instance_count, var.zdm_proxy_dc1_type)
  key_name      = aws_key_pair.dse-zdm-test-sshkey.key_name
  subnet_id     = aws_subnet.sn_zdm_proxy_zdm_test.id

  vpc_security_group_ids = [
    aws_security_group.sg_dse_zdm_test_internal_only.id,
    aws_security_group.sg_dse_zdm_test_ssh.id,
    aws_security_group.sg_dse_zdm_test_node.id,
    aws_security_group.sg_dse_zdm_test_proxy.id
  ]

  root_block_device {
    volume_size = 100
    volume_type = "gp3"
  }

  tags = {
    Name        = "${var.tag_identifier}-${var.zdm_proxy_dc1_type}-${count.index}"
    Environment = var.env
  }

}

#
# EC2 instance for ZDM Proxy Monitoring, DC1
# 

resource "aws_instance" "zdm_proxy_monitoring_dc1" {
  ami = lookup(var.proxy_ami, var.region)

  instance_type = lookup(var.instance_type, var.zdm_proxy_monitoring_dc1_type)
  key_name      = aws_key_pair.dse-zdm-test-sshkey.key_name
  subnet_id     = aws_subnet.sn_zdm_proxy_zdm_test.id

  vpc_security_group_ids = [
    aws_security_group.sg_dse_zdm_test_internal_only.id,
    aws_security_group.sg_dse_zdm_test_ssh.id,
    aws_security_group.sg_dse_zdm_test_proxy.id
  ]

  root_block_device {
    volume_size = 200
    volume_type = "gp3"
  }

  tags = {
    Name        = "${var.tag_identifier}-${var.zdm_proxy_monitoring_dc1_type}"
    Environment = var.env
  }

}


#
# EC2 instances for DSE olap cluster, DC1
#
resource "aws_instance" "dse_olap_dc1" {
  ami           = var.ami_id
  instance_type = lookup(var.instance_type, var.dse_olap_dc1_type)
  root_block_device {
    volume_size = 100
  }
  count     = lookup(var.instance_count, var.dse_olap_dc1_type)
  key_name  = aws_key_pair.dse-zdm-test-sshkey.key_name
  subnet_id = aws_subnet.sn_dse_olap_zdm_test.id

  vpc_security_group_ids = [
    aws_security_group.sg_dse_zdm_test_internal_only.id,
    aws_security_group.sg_dse_zdm_test_ssh.id,
    aws_security_group.sg_dse_zdm_test_node.id
  ]

  tags = {
    Name        = "${var.tag_identifier}-${var.dse_olap_dc1_type}-${count.index}"
    Environment = var.env
  }

}

###################################
## Generation of Ansible inventory
###################################
resource "local_file" "ansible_inventory" {
  content = templatefile("${path.module}/templates/cloudgate_inventory.tpl",
    {
      cloudgate_proxy_private_ips = aws_instance.zdm_proxy_dc1.*.private_ip
      monitoring_private_ip       = aws_instance.zdm_proxy_monitoring_dc1.private_ip
    }
  )
  filename = "cloudgate_inventory"
}

######################################################
## Generation of Cloudgate SSH config file for ProxyJump
######################################################
resource "local_file" "cloudgate_ssh_config" {
  content = templatefile("${path.module}/templates/cloudgate_ssh_config.tpl",
    {
      cloudgate_proxy_private_ips = aws_instance.zdm_proxy_dc1.*.private_ip
      jumphost_private_ip         = aws_instance.zdm_proxy_monitoring_dc1.private_ip
      jumphost_public_ip          = aws_instance.zdm_proxy_monitoring_dc1.public_ip
      keypath                     = var.ssh_key_localpath
      keyname                     = var.ssh_key_filename
    }
  )
  filename = "cloudgate_ssh_config"
}
